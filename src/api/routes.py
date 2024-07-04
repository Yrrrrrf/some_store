# 3rd party imports
from fastapi import APIRouter

# local imports
from src.api.database import *
from src.api.route_generators import *
from src.config import Config


def define_routes() -> Tuple[APIRouter, APIRouter, APIRouter, APIRouter]:
    """
    Define the main routes for the API.

    Returns the `APIRouter` for `home`, `basic_dt`, `views` and `crud_attr`.

    Returns:
        Tuple[`APIRouter`, `APIRouter`, `APIRouter`, `APIRouter`]
    """

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

    views: APIRouter = APIRouter()  # todo: views routes... for views xd
    """
    # Views Routes

    This route contains the main methods that will be used to display the views of the application.

    ## Example
    - Get some useful view data to display on the application (for each schema)
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

    print(f"\n\033[0;30;47m{Config.NAME.value}\033[m\n")  # white bg
    return home, basic_dt, crud_attr, views  # * return all the routers...

home, basic_dt, views, crud_attr = define_routes()

# * Add all the routes for the home page
# schema_dt_routes(get_db, basic_dt, store_models)  # * schema routes for each table
# schema_view_routes(get_db, views, public_views)  # * schema routes for each view

list_tables(home, store_models, 'store')  # * list all the tables in the database

# * Add all the CRUD routes for each view
for sqlalchemy_model, pydantic_model in store_models.values():
    crud_routes(sqlalchemy_model, pydantic_model, crud_attr, db_manager.get_db)
