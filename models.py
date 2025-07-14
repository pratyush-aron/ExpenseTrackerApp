from sqlalchemy import Column, String, Float, DateTime
from uuid import uuid4
from datetime import datetime
from database import Base

class Expense(Base):
    __tablename__ = "expenses"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid4()))
    title = Column(String(100))
    amount = Column(Float)
    category = Column(String(50))
    created_at = Column(DateTime, default=datetime.utcnow)
