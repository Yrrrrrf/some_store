"""
    Main file for the FastAPI application
"""

# ? 3rd party imports
import shutil
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

# ? Local imports
from src.api.routes import *
from src.config import Config


app: FastAPI = FastAPI(
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
    }
)

app.add_middleware(  # Add CORS middleware
    CORSMiddleware,
    allow_origins=[  # origin: protocol + host + port (ex: "http://localhost:5173")
        "*"  # allow all origins
        ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Mount a static files directory
app.mount("/static", StaticFiles(directory="hub/static"), name="static")

@app.post("/upload-image")
async def upload_image(file: UploadFile = File(...)):
    file_location = f"hub/static/uploads/{file.filename}"
    with open(file_location, "wb+") as file_object:
        shutil.copyfileobj(file.file, file_object)
    return {"url": f"hub/static/uploads/{file.filename}"}


# * Create routes
# app.include_router(router)      # * main router to test the application
app.include_router(home)        # * main routes for the application (home, about, contact, help, etc.)
# app.include_router(auth)        # * authentication routes (login, logout, etc.)
app.include_router(views)       # * views for the application (for each schema on the database)
app.include_router(basic_dt)    # * data table (GET columns & all resources)
app.include_router(crud_attr)   # * CRUD operations for attributes


# * Startup event
print("\n\033[92m" + f"Startup completed successfully!\n\n")

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
