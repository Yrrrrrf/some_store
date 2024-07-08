"""
function_routes.py
This file contains FastAPI routes that expose the SQL functions as API endpoints.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List

from src.api.database import db_manager

# Create a new router for function-related endpoints
function_router = APIRouter()

def get_db():
    """Database session dependency."""
    db = db_manager.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@function_router.get("/get_purchase_total/{purchase_id}", response_model=float)
async def get_purchase_total(purchase_id: int, db: Session = Depends(get_db)):
    """
    Get the total amount of a purchase.
    
    Args:
        purchase_id (int): The ID of the purchase.
        db (Session): The database session.
    
    Returns:
        float: The total amount of the purchase.
    """
    try:
        result = db.execute(text("SELECT store.get_purchase_total(:purchase_id)"), {"purchase_id": purchase_id})
        total = result.scalar()
        if total is None:
            raise HTTPException(status_code=404, detail="Purchase not found")
        return total
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@function_router.get("/get_sale_total/{sale_id}", response_model=float)
async def get_sale_total(sale_id: int, db: Session = Depends(get_db)):
    """
    Get the total amount of a sale.
    
    Args:
        sale_id (int): The ID of the sale.
        db (Session): The database session.
    
    Returns:
        float: The total amount of the sale.
    """
    try:
        result = db.execute(text("SELECT store.get_sale_total(:sale_id)"), {"sale_id": sale_id})
        total = result.scalar()
        if total is None:
            raise HTTPException(status_code=404, detail="Sale not found")
        return total
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@function_router.get("/get_product_inventory/{product_id}", response_model=int)
async def get_product_inventory(product_id: int, db: Session = Depends(get_db)):
    """
    Get the current inventory of a product.
    
    Args:
        product_id (int): The ID of the product.
        db (Session): The database session.
    
    Returns:
        int: The current inventory of the product.
    """
    try:
        result = db.execute(text("SELECT store.get_product_inventory(:product_id)"), {"product_id": product_id})
        inventory = result.scalar()
        if inventory is None:
            raise HTTPException(status_code=404, detail="Product not found")
        return inventory
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@function_router.post("/convert_cart_to_sale", response_model=int)
async def convert_cart_to_sale(customer_id: int, vendor_id: int, shipping_address_id: int, db: Session = Depends(get_db)):
    """
    Convert a customer's cart to a sale.
    
    Args:
        customer_id (int): The ID of the customer.
        vendor_id (int): The ID of the vendor.
        shipping_address_id (int): The ID of the shipping address.
        db (Session): The database session.
    
    Returns:
        int: The ID of the newly created sale.
    """
    try:
        result = db.execute(
            text("SELECT store.convert_cart_to_sale(:customer_id, :vendor_id, :shipping_address_id)"),
            {"customer_id": customer_id, "vendor_id": vendor_id, "shipping_address_id": shipping_address_id}
        )
        sale_id = result.scalar()
        if sale_id is None:
            raise HTTPException(status_code=400, detail="Failed to convert cart to sale")
        db.commit()
        return sale_id
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

# Add the function router to your main FastAPI app
# In your main.py file, add:
# from src.api.function_routes import function_router
# app.include_router(function_router, prefix="/functions", tags=["Functions"])


# add a route that list all the functions in the database
# @function_router.get("/", response_model=List[str])
# async def get_functions(db: Session = Depends(get_db)):
#     """
#     Get a list of all functions in the database.
    
#     Args:
#         db (Session): The database session.
    
#     Returns:
#         List[str]: A list of function names.
#     """

#     return [
#         "get_purchase_total",
#         "get_sale_total",
#         "get_product_inventory",
#         "convert_cart_to_sale"
#         ]
    