from pydantic import BaseModel
from datetime import datetime

class ExpenseCreate(BaseModel):
    title: str
    amount: float
    category: str

class ExpenseOut(ExpenseCreate):
    id: str
    created_at: datetime

    class Config:
        from_attributes = True
