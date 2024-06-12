from fastapi import Depends, HTTPException, APIRouter
from sqlalchemy.orm import Session
from sqlalchemy import Integer, text
from pydantic import BaseModel
from typing import *
from src.api.database import *


# * Add `get_tables` to the router & `get_columns` for each table
def schema_dt_routes(
    db_dependency: Callable,
    router: APIRouter
):
    """
    Add routes for the tables to the basic_dt router.

    Args:
        db_dependency (Callable): The dependency function to get the database session.
    """
    @router.get("/tables", response_model=List[str], tags=["Tables"])
    def get_tables(): return [model[0].__tablename__ for model in all_models.values()]

    def create_column_route(model):
        @router.get(f"/{model.__tablename__}/columns", response_model=List[str], tags=[model.__tablename__.capitalize()])
        def get_columns(): return [c.name for c in model.__table__.columns]
        return get_columns

    def get_all_resources_route(model, db_dependency):
        @router.get(f"/{model[0].__tablename__}/all", tags=[model[0].__tablename__.capitalize()], response_model=List[model[1]])
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


    for model in all_models.values():
        create_column_route(model[0])
        get_all_resources_route(model, db_dependency)

# # * Add all views to the router
def schema_view_routes(
    db_dependency: Callable,
    router: APIRouter,
):
    @router.get("/views", tags=['Views'], response_model=List[str])
    def get_views(db: Session = Depends(db_dependency)):
        query = text("SELECT table_name FROM information_schema.views WHERE table_schema = 'public'")
        result = db.execute(query).fetchall()
        return [row[0] for row in result]

    def create_view_route(view: str):
        QueryParamModel: Type[BaseModel] = create_pydantic_model(
            next(db_dependency()),
            view,
            f"{view}QueryParams"
        )

        @router.get(f"/view/{view}", tags=["Views"], response_model=List[QueryParamModel])
        def get_view(
            db: Session = Depends(db_dependency),
            # filters: QueryParamModel = Depends()  # type: ignore
        ):
            base_query: str = f"SELECT * FROM {view}"
            result = db.execute(text(base_query)).fetchall()
            return result

    views = next(db_dependency()).execute(
        text("SELECT table_name FROM information_schema.views WHERE table_schema = 'public'")
    ).fetchall()

    for view in [row[0] for row in views]:
        print(f'\n{view}')
        create_view_route(view)

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
    def create_resource(resource: pydantic_model, db: Session = Depends(db_dependency)):
        db_resource: Base = sqlalchemy_model(**resource.dict())  # type: ignore
        db.add(db_resource)
        try:
            db.commit()
            db.refresh(db_resource)
        except Exception as e:
            db.rollback()
            raise e
        return db_resource

    def _create_route(attribute: str, attribute_type: Any, route_type: str):
        match route_type:
            case "GET":
                @router.get(f"/{sqlalchemy_model.__tablename__.lower()}/{attribute}={{value}}", tags=[sqlalchemy_model.__name__], response_model=List[pydantic_model])
                def get_resource(value: attribute_type, db: Session = Depends(db_dependency)):  # type: ignore
                    result = db.query(sqlalchemy_model).filter(getattr(sqlalchemy_model, attribute) == value).all()
                    if not result:
                        raise HTTPException(status_code=404, detail=f"No {sqlalchemy_model.__name__} with {attribute} '{value}' found.")
                    return result

            case "PUT":
                @router.put(f"/{sqlalchemy_model.__tablename__.lower()}/{attribute}={{value}}", tags=[sqlalchemy_model.__name__], response_model=pydantic_model)
                def update_resource(value: attribute_type, resource: pydantic_model, db: Session = Depends(db_dependency)):  # type: ignore
                    db_resource = db.query(sqlalchemy_model).filter(getattr(sqlalchemy_model, attribute) == value).first()
                    if not db_resource:
                        raise HTTPException(status_code=404, detail=f"No {sqlalchemy_model.__name__} with {attribute} '{value}' found.")

                    for key, value in resource.dict(exclude_unset=True).items():
                        setattr(db_resource, key, value)

                    try:
                        db.commit()
                        db.refresh(db_resource)
                    except Exception as e:
                        db.rollback()
                        raise e

                    return db_resource

            case "DELETE":
                @router.delete(f"/{sqlalchemy_model.__tablename__.lower()}/{attribute}={{value}}", tags=[sqlalchemy_model.__name__])
                def delete_resource(value: attribute_type, db: Session = Depends(db_dependency)):  # type: ignore
                    db_resource = db.query(sqlalchemy_model).filter(getattr(sqlalchemy_model, attribute) == value).first()
                    if not db_resource:
                        raise HTTPException(status_code=404, detail=f"No {sqlalchemy_model.__name__} with {attribute} '{value}' found.")

                    try:
                        db.delete(db_resource)
                        db.commit()
                    except Exception as e:
                        db.rollback()
                        raise e

                    return {
                        "message": f"Successfully deleted {sqlalchemy_model.__name__} with {attribute} '{value}'",
                        "resource": db_resource
                    }

            case _: raise ValueError(f"Invalid route type: {route_type}")

    included_attributes = [(attr, col.type.__class__)
        for attr, col in sqlalchemy_model.__table__.columns.items()
        if attr not in excluded_attributes
    ]

    for attr, attr_type in included_attributes:
        # todo: Check if th attr_type declaration is really necessary...
        # ^ I mean, it is to avoid the error of the type not being a type
        # ^ But I think can be redundant to the type of the attribute...
        [_create_route(attr, int if attr_type == Integer else str, method) for method in ["GET", "PUT", "DELETE"]]
