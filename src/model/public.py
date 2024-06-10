# from sqlalchemy import *
# from sqlalchemy.orm import relationship
# from pydantic import *

# from datetime import datetime
# from src.api.database import *


# SchemaBaseModel, IDBaseModel, NamedBaseModel = base_model(schema='public')


# # * SQL ALchemy Model 
# class GeneralUser(NamedBaseModel):
#     email = Column(String(255), nullable=False, unique=True)
#     password = Column(String(255), nullable=False)  # represents the password hash (not the actual password)
#     # additional_info = Column(JSON, default={})
#     created_at = Column(DateTime, default=datetime.now)

#     # students = relationship("Student", back_populates="user")

#     def __repr__(self):
#         return f"<User {self.name}>"


# public_sql_classes: list = get_classes_from_globals(globals())


# # * Pydantic Models
# class UserModel(BaseModel):
#     name: str
#     email: EmailStr
#     password: str  # represents the password hash (not the actual password)
#     # additional_info: Optional[dict] = None

#     class Config:
#         # orm_mode = True  # old version of pydantic
#         from_attributes = True  # same as orm_mode bug has been renamed...

# public_pydantic_classes = [cls for cls in get_classes_from_globals(globals()) if cls not in public_sql_classes]
