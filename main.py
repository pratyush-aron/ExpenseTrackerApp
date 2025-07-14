from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from models import Expense
from database import Base, engine, SessionLocal
from pydantic import BaseModel
from typing import List
from datetime import datetime

# Create DB tables
Base.metadata.create_all(bind=engine)

app = FastAPI()

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Pydantic schema for input
class ExpenseCreate(BaseModel):
    title: str
    amount: float
    category: str

class ExpenseOut(ExpenseCreate):
    id: str
    created_at: datetime  # ✅ changed from str to datetime

    class Config:
        from_attributes = True     # ✅ tells Pydantic to accept ORM models

# POST - Add expense
@app.post("/expenses/", response_model=ExpenseOut)
def add_expense(expense: ExpenseCreate, db: Session = Depends(get_db)):
    new_expense = Expense(**expense.dict())
    db.add(new_expense)
    db.commit()
    db.refresh(new_expense)
    return new_expense

# GET all expenses
@app.get("/expenses/", response_model=List[ExpenseOut])
def get_expenses(db: Session = Depends(get_db)):
    return db.query(Expense).all()

# GET one
@app.get("/expenses/{expense_id}", response_model=ExpenseOut)
def get_expense(expense_id: str, db: Session = Depends(get_db)):
    expense = db.query(Expense).filter(Expense.id == expense_id).first()
    if not expense:
        raise HTTPException(status_code=404, detail="Expense not found")
    return expense

# DELETE
@app.delete("/expenses/{expense_id}")
def delete_expense(expense_id: str, db: Session = Depends(get_db)):
    expense = db.query(Expense).filter(Expense.id == expense_id).first()
    if not expense:
        raise HTTPException(status_code=404, detail="Expense not found")
    db.delete(expense)
    db.commit()
    return {"message": "Expense deleted"}
