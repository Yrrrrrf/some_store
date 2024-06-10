"""
    Main file for the FastAPI application
"""

# ? 3rd party imports
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# ? Local imports
from src.api.routes import *
from src.config import Config


app = FastAPI(
    title = Config.NAME.value,
    description = Config.DESCRIPTION.value,
    version = Config.VERSION.value,
    contact = {
        "name": Config.AUTHOR.value, 
        "email": Config.EMAIL.value
        },
    license_info = {
        "name": "MIT",
        "url": "https://choosealicense.com/licenses/mit/",
    },
)

app.add_middleware(  # Add CORS middleware
    CORSMiddleware,
    allow_origins=[  # origin: protocol + host + port (ex: "http://localhost:5173")
        # "http://localhost:5173",  # Your Svelte frontend URL
        # "http://127.0.0.1:5173",  # Alternative localhost URL
        "*"
        ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# * Create routes
app.include_router(home)        # * main routes for the application (home, about, contact, help, etc.)
# app.include_router(auth)        # * authentication routes (login, logout, etc.)
app.include_router(views)       # * views for the application (for each schema on the database)
app.include_router(basic_dt)    # * data table (GET columns & all resources)
app.include_router(crud_attr)   # * CRUD operations for attributes
# app.include_router(router)      # * main router for the application


# * Run the application
if __name__ == "__main__":
    """
        Run the FastAPI application
    
        Using the `python main.py` will use this block to run the FastAPI application.
        It will run the application using the `uvicorn` server on the localhost at port 8000.
        So it wont be updated automatically when the code changes.
    """
    import uvicorn  # import uvicorn to run the application
    uvicorn.run(app, host="127.0.0.1", port=8000)
