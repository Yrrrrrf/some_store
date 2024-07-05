from fastapi import Depends, HTTPException, APIRouter
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List, Dict, Tuple, Type, Callable, Any
from src.api.database import Base

def dt_routes(
    router: APIRouter, 
    models: Dict[str, Tuple[Type[Base], Type[BaseModel]]],
    type: str = "tables",
    url_prefix: str = None,
    excluded_tables: List[str] = []
):
    """
    Add a route to list all tables in the database.

    Args:
        router (APIRouter): The FastAPI router to add the route to.
        models (Dict[str, Tuple[Type[Base], Type[BaseModel]]]): Dictionary of models.
    """
    @router.get(
        f"/{type}" if not url_prefix else f"/{url_prefix}/{type}", 
        response_model=List[str], 
        tags=["Metadata"]
    )
    def get_tables() -> List[str]:
        """List all tables in the database."""
        # return [model[0].__tablename__ for model in models.values() if model[0].__tablename__ not in excluded_tables]
        return [model[0].__tablename__ for model in models.values()]


def crud_routes(
    sqlalchemy_model: Type[Base],
    pydantic_model: Type[BaseModel],
    router: APIRouter,
    db_dependency: Callable,
    # excluded_attributes: List[str] = ["id", "created_at", "password", "additional_info"]
):
    """
    Add CRUD routes for a specific model.

    Args:
        sqlalchemy_model (Type[Base]): SQLAlchemy model.
        pydantic_model (Type[BaseModel]): Pydantic model.
        router (APIRouter): The FastAPI router to add routes to.
        db_dependency (Callable): Database session dependency.
        excluded_attributes (List[str]): Attributes to exclude from operations.
    """
    model_name: str = sqlalchemy_model.__tablename__.lower()
    tag: str = sqlalchemy_model.__name__.replace("_", " ")

    # * Get Columns
    @router.get(f"/{model_name}/columns", response_model=List[str], tags=[tag])
    def get_columns() -> List[str]:
        """Get columns for the model."""
        return [c.name for c in sqlalchemy_model.__table__.columns]

    # * Create Resource (POST)
    @router.post(f"/{model_name}", tags=[tag], response_model=pydantic_model)
    def create_resource(
        resource: pydantic_model, 
        db: Session = Depends(db_dependency)
    ) -> Base:
        """Create a new resource."""
        db_resource = sqlalchemy_model(**resource.model_dump())
        db.add(db_resource)
        try:
            db.commit()
            db.refresh(db_resource)
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=400, detail=str(e))
        return db_resource

    # * Get All Resources (GET)
    @router.get(f"/{model_name}", tags=[tag], response_model=List[pydantic_model])
    def get_resources(
        db: Session = Depends(db_dependency), 
        filters: pydantic_model = Depends()
    ):
        """Get resources with optional filtering."""
        query = db.query(sqlalchemy_model)
        filters_dict: Dict[str, Any] = filters.model_dump(exclude_unset=True)

        print(f"Query: {len(query.all())}")

        for attr, value in filters_dict.items():
            if value is not None:
                query = query.filter(getattr(sqlalchemy_model, attr) == value)

        return query.all()

    # todo: Use a better way to handle the response model for the PUT route
    # todo: For now it just returns a List of Tuples with the old and new data models
    # todo: Like this: [(old_data, new_data), ... ] and so on
    # * Modify Resource (PUT)
    @router.put(f"/{model_name}", tags=[tag], response_model=List[Tuple[pydantic_model, pydantic_model]])
    def update_resources(
        resource: pydantic_model,
        db: Session = Depends(db_dependency),
        filters: pydantic_model = Depends()
    ):
        """Update resources based on filters."""
        query = db.query(sqlalchemy_model)
        filters_dict: Dict[str, Any] = filters.model_dump(exclude_unset=True)

        if not any(filters_dict.values()):
            raise HTTPException(status_code=400, detail="No filters provided.")

        for attr, value in filters_dict.items():
            if value is not None:
                query = query.filter(getattr(sqlalchemy_model, attr) == value)

        update_data = resource.model_dump(exclude_unset=True)
        d_data: List[pydantic_model] = [pydantic_model(**data.__dict__).model_dump() for data in query.all()]
        updated_model = pydantic_model(**update_data)

        if 'id' in update_data:
            del update_data['id']

        try:
            updated_count = query.update(update_data)

            db.commit()
            if updated_count == 0:
                raise HTTPException(status_code=404, detail="No matching resources found.")
            return [(d, updated_model) for d in d_data]
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=400, detail=str(e))


    # * Delete Resource (DELETE)
    @router.delete(f"/{model_name}", tags=[tag])
    def delete_resources(
        db: Session = Depends(db_dependency), 
        filters: pydantic_model = Depends()
    ):
        """Delete resources based on filters."""
        query = db.query(sqlalchemy_model)
        filters_dict: Dict[str, Any] = filters.model_dump(exclude_unset=True)

        if not any(filters_dict.values()):
            raise HTTPException(status_code=400, detail="No filters provided.")

        for attr, value in filters_dict.items():
            if value is not None:
                print(f"Attr: {attr}, Value: {value}")
                query = query.filter(getattr(sqlalchemy_model, attr) == value)

        print(f"Query: {len(query.all())}")
        d_data: List[pydantic_model] = [pydantic_model(**data.__dict__).model_dump() for data in query.all()]

        try:
            deleted_count = query.delete()
            db.commit()
            if deleted_count == 0:
                raise HTTPException(status_code=404, detail="No matching resources found.")
            return {
                "deleted_count": deleted_count,
                "deleted_resources": f"Deleted {d_data} resources."
                }
        
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=400, detail=str(e))


def view_routes(
    sqlalchemy_model: Type[Base],
    pydantic_model: Type[BaseModel],
    router: APIRouter,
    db_dependency: Callable,
    excluded_attributes: List[str] = ["id", "created_at", "password", "additional_info"]
):
    """
    Add routes for a specific view.

    Args:
        sqlalchemy_model (Type[Base]): SQLAlchemy model.
        pydantic_model (Type[BaseModel]): Pydantic model.
        router (APIRouter): The FastAPI router to add routes to.
        db_dependency (Callable): Database session dependency.
        excluded_attributes (List[str]): Attributes to exclude from operations.
    """
    model_name: str = sqlalchemy_model.__tablename__.lower()

    @router.get(f"/view/{model_name}/columns", response_model=List[str], tags=["Views"])
    def get_columns() -> List[str]:
        """Get columns for the model."""
        return [c.name for c in sqlalchemy_model.__table__.columns]

    @router.get(f"/view/{model_name}", tags=["Views"], response_model=List[pydantic_model])
    def get_resources(db: Session = Depends(db_dependency), filters: pydantic_model = Depends()):
        """Get resources with optional filtering."""
        query = db.query(sqlalchemy_model)
        filters_dict: Dict[str, Any] = filters.model_dump(exclude_unset=True)

        for attr, value in filters_dict.items():
            if value is not None:
                query = query.filter(getattr(sqlalchemy_model, attr) == value)

        return query.all()
