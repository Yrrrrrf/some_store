from fastapi import Depends, HTTPException, APIRouter
from fastapi.params import Query
from sqlalchemy.orm import Session
from sqlalchemy import Integer
from pydantic import BaseModel
from typing import *
from src.api.database import *


# todo: CHECK THE 'schema_dt_routes' & 'schema_view_routes' METHODS
# todo: They're probably the same, so I should merge them into one method
# todo: fn schema_dr_routes -> (...)

# * Add `get_tables` to the router & `get_columns` for each table
def schema_dt_routes(
    db_dependency: Callable,
    router: APIRouter,
    models: Dict[str, Tuple[Type[Base], Type[BaseModel]]]  # type: ignore
):
    """
    Add the routes to get the tables and columns of the database.

    - GET /tables -> Get all the tables in the database.
    - GET /{table}/columns -> Get all the columns of a table.
    - GET /{table}/all -> Get all the resources of a table.

    Args:
        db_dependency (Callable): The dependency function to get the database session.
    """
    @router.get("/tables", response_model=List[str], tags=["Tables"])
    def get_tables(): return [model[0].__tablename__ for model in models.values()]

    def get_columns_route(model: Type[Base]):  # type: ignore
        @router.get(f"/{model.__tablename__}/columns", response_model=List[str], tags=[model.__tablename__.capitalize()])
        def get_columns(): return [c.name for c in model.__table__.columns]
        return get_columns

    def get_all_route(model: Tuple[Type[Base], Type[BaseModel]]):  # type: ignore
        @router.get(f"/{model[0].__tablename__}", tags=[model[0].__tablename__.capitalize()], response_model=List[model[1]])
        def get_all(
            db: Session = Depends(db_dependency),
            filters: model[1] = Depends()  # type: ignore
        ):
            query = db.query(model[0])
            for attr, value in filters.dict().items():
                if value is not None:  # if the value is not None, filter by it
                    query = query.filter(getattr(model[0], attr) == value)
            return query.all()

        return get_all

    # Add the 'get_columns' & 'get_all' routes for each table
    for model in models.values():
        get_columns_route(model[0])
        get_all_route(model)

# * Add the routes to get the views and columns of the database
def schema_view_routes(
    db_dependency: Callable,
    router: APIRouter,
    models: Dict[str, Tuple[Type[Base], Type[BaseModel]]]  # type: ignore
):
    # todo: Complete & fix this method to add the views routes for the db!
    def generate_get_all_route(
        model: Type[Base],  # type: ignore
        pydantic_model: Type[BaseModel], 
        db_dependency: Callable
    ):
        @router.get(f"/views", response_model=List[str], tags=["Views"])
        def get_views(): return [model.__tablename__ for model, _ in models.values()]

        # get vews columns
        @router.get(f"/view/{model.__tablename__}/columns", response_model=List[str], tags=["Views"])
        def get_columns(): return [c.name for c in model.__table__.columns]

        @router.get(f"/view/{model.__tablename__}", response_model=List[pydantic_model], tags=["Views"])
        def get_all(
            filters: pydantic_model = Depends(),
            db: Session = Depends(db_dependency)
        ):
            query = db.query(model)
            filters_dict: Dict[str, Any] = filters.model_dump()

            # * If any of the values is not None, filter by it
            if any(value is not None for value in filters_dict.values()):
                print("Filtering by:")
                for attr, value in filters_dict.items():
                    if value is not None:
                        print(f"\t{attr:>20} -> {value}")
                        query = query.filter(getattr(model, attr) == value)

                # * Same as above, but using a list comprehension... (same but it's less readable)
                # query = query.filter(*[getattr(model, attr) == value for attr, value in filters_dict.items() if value is not None])

            results = query.all()
            print(f"Query results: {len(results)}")
            return results

        return get_all

    for _, (sqlalchemy_model, pydantic_model) in models.items():
        generate_get_all_route(sqlalchemy_model, pydantic_model, db_dependency)


# * CRUD Operations Routes (GET, POST, PUT, DELETE)
def crud_routes(
    sqlalchemy_model: Type[Base],  # type: ignore
    pydantic_model: Type[BaseModel],
    router: APIRouter,
    db_dependency: Callable,
    excluded_attributes: List[str] = ["id", "created_at", "password", "additional_info"]
):
    # * POST (Create)
    @router.post(f"/{sqlalchemy_model.__tablename__.lower()}", tags=[sqlalchemy_model.__name__], response_model=pydantic_model)
    def create_resource(
        resource: pydantic_model, 
        db: Session = Depends(db_dependency)
    ) -> Base:  # type: ignore
        db_resource: Base = sqlalchemy_model(**resource.model_dump())
        db.add(db_resource)

        try:
            db.commit()
            db.refresh(db_resource)
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=400, detail=str(e))

        return db_resource

    # * DELETE (Delete) (with query parameters)
    @router.delete(f"/{sqlalchemy_model.__tablename__.lower()}", tags=[sqlalchemy_model.__name__])
    def delete_resource(
        db: Session = Depends(db_dependency),
        filters: pydantic_model = Depends()
    ) -> None:
        query = db.query(sqlalchemy_model)
        filters_dict: Dict[str, Any] = filters.model_dump()

        if any(value is not None for value in filters_dict.values()):
            for attr, value in filters_dict.items():
                if value is not None:
                    query = query.filter(getattr(sqlalchemy_model, attr) == value)

            deleted_resources = query.all()
            try:
                query.delete()
                db.commit()
            except Exception as e:
                db.rollback()
                raise HTTPException(status_code=400, detail=str(e))
            
            return {
                "deleted_resources": len(deleted_resources),
                "resources": deleted_resources
            }

        else:
            raise HTTPException(status_code=400, detail="No filters provided.")

    # * PUT (Update) (with query parameters)
    @router.put(f"/{sqlalchemy_model.__tablename__.lower()}", tags=[sqlalchemy_model.__name__], response_model=List[pydantic_model])
    def update_resource(
        resource: pydantic_model,
        db: Session = Depends(db_dependency),
        filters: pydantic_model = Depends()
    ):
        query = db.query(sqlalchemy_model)
        filters_dict: Dict[str, Any] = filters.model_dump(exclude_unset=True)

        if not filters_dict:
            raise HTTPException(status_code=400, detail="No filters provided.")

        # * Filter by the provided filters
        for attr, value in filters_dict.items():
            if value is not None:
                query = query.filter(getattr(sqlalchemy_model, attr) == value)

        updated_resources = query.all()

        # * Update the resource with the provided data
        update_data = resource.model_dump(exclude_unset=True)
        if 'id' in update_data: del update_data['id']  # Remove id from update data

        try:
            query.update(update_data)
            db.commit()

            return updated_resources
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=400, detail=str(e))
    