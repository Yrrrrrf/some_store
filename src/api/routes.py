# 3rd party imports
from fastapi import Depends, HTTPException, APIRouter, Query
from sqlalchemy.orm import Session, Query, aliased
from sqlalchemy import text
from pydantic import BaseModel

# stdlib imports
from typing import Callable
from functools import partial

# local imports
from src.config import Config
from src.api.database import *
from src.api.route_generators import *
# from src.api.auth import *


def define_routes():
    home: APIRouter = APIRouter()  # for home routes
    """
    # Home Route

    This route contains the main methods that will be used to display the home page of the application.

    ## Example
    - Get the home page
    - Get the about page
    - Get the contact page
    - Get the help page
    """

    @home.get("/", tags=["Main"])  # todo: Make this rout a redirect to the main web interface (svelte app) on the future...
    def _home_route(): return {"The interface for Some Store API is on: 127.0.0.1:8000/docs"}

    basic_dt: APIRouter = APIRouter()  # for data table routes
    """
    # Data Table Routes

    This routes contains some basic useful methods for the data tables.

    ## Example
    - Get the attributes of a table (all the columns)
    - Get all the resources of a table (all the rows)
    """

    crud_attr: APIRouter = APIRouter()  # crud routes for each attribute
    """
    # CRUD Routes

    This route contains the main methods that will be used to create, read, update and delete resources.

    todo: UPDATE THIS EXAMPLES TO MATCH THE NEW ROUTES...
    todo: Add the respective examples for each method
    ## Example
    - Create a new resource
    - Get all resources
    - Get a resource by ID
    - Update a resource by ID
    - Delete a resource by ID
    """

    views: APIRouter = APIRouter()  # todo: views routes... for views xd
    """
    # Views Routes

    This route contains the main methods that will be used to display the views of the application.

    ## Example
    - Get some useful view data to display on the application (for each schema)
    """

    print(f"\n\033[0;30;47m{Config.NAME.value}\033[m\n")  # white bg
    return home, basic_dt, crud_attr, views  # * return all the routers...

home, basic_dt, crud_attr, views = define_routes()

# todo: ADD SOME NEW GENERATOR TO CREATE THE SQL_CALSSES USING SOME METADATA FROM THE DATABASE...
# * this will allow to create the routes for each schema dynamically...


def _add_schema_routes(
    db_dependency: Callable, 
    schema: str = 'store', 
    b_color: str = ""
):
    print(f"\033[0;30;{b_color}m{schema.capitalize()}\033[m")  # yellow bg

    schema_dt_routes(db_dependency, basic_dt)
    schema_view_routes(db_dependency, views)

    for model in all_models.values():
        crud_routes(
            model[0],  # * SQLAlchemy Model 
            model[1],  # * Pydantic Model
            crud_attr,            
            db_dependency, 
            )

# * Add routes for each schema...
_add_schema_routes(get_db, b_color="43")

# schema_dt_routes(partial(get_db, "school"), basic_dt)
