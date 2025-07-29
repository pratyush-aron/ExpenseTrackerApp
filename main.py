from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from models import Expense
from database import Base, engine, SessionLocal
from pydantic import BaseModel
from typing import List
from datetime import datetime

# Create DB tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Expense Tracker API", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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
    created_at: datetime

    class Config:
        from_attributes = True

# Health check endpoint
@app.get("/")
def read_root():
    return {"message": "Expense Tracker API is running!"}

# Health check endpoint
@app.get("/health")
def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow()}

# POST - Add expense
@app.post("/expenses/", response_model=ExpenseOut)
def add_expense(expense: ExpenseCreate, db: Session = Depends(get_db)):
    try:
        new_expense = Expense(**expense.dict())
        db.add(new_expense)
        db.commit()
        db.refresh(new_expense)
        return new_expense
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating expense: {str(e)}")

# GET all expenses
@app.get("/expenses/", response_model=List[ExpenseOut])
def get_expenses(db: Session = Depends(get_db)):
    try:
        expenses = db.query(Expense).order_by(Expense.created_at.desc()).all()
        return expenses
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching expenses: {str(e)}")

# GET one expense
@app.get("/expenses/{expense_id}", response_model=ExpenseOut)
def get_expense(expense_id: str, db: Session = Depends(get_db)):
    try:
        expense = db.query(Expense).filter(Expense.id == expense_id).first()
        if not expense:
            raise HTTPException(status_code=404, detail="Expense not found")
        return expense
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching expense: {str(e)}")

# PUT - Update expense
@app.put("/expenses/{expense_id}", response_model=ExpenseOut)
def update_expense(expense_id: str, expense: ExpenseCreate, db: Session = Depends(get_db)):
    try:
        db_expense = db.query(Expense).filter(Expense.id == expense_id).first()
        if not db_expense:
            raise HTTPException(status_code=404, detail="Expense not found")
        
        db_expense.title = expense.title
        db_expense.amount = expense.amount
        db_expense.category = expense.category
        
        db.commit()
        db.refresh(db_expense)
        return db_expense
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating expense: {str(e)}")

# DELETE expense
@app.delete("/expenses/{expense_id}")
def delete_expense(expense_id: str, db: Session = Depends(get_db)):
    try:
        expense = db.query(Expense).filter(Expense.id == expense_id).first()
        if not expense:
            raise HTTPException(status_code=404, detail="Expense not found")
        
        db.delete(expense)
        db.commit()
        return {"message": "Expense deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error deleting expense: {str(e)}")

# GET expenses by category
@app.get("/expenses/category/{category}", response_model=List[ExpenseOut])
def get_expenses_by_category(category: str, db: Session = Depends(get_db)):
    try:
        expenses = db.query(Expense).filter(Expense.category == category).order_by(Expense.created_at.desc()).all()
        return expenses
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching expenses by category: {str(e)}")

# GET expenses summary
@app.get("/expenses/summary/stats")
def get_expenses_summary(db: Session = Depends(get_db)):
    try:
        expenses = db.query(Expense).all()
        
        total_expenses = sum(exp.amount for exp in expenses if exp.amount < 0)
        total_income = sum(exp.amount for exp in expenses if exp.amount > 0)
        net_balance = total_income + total_expenses  # total_expenses is negative
        
        # Category breakdown
        categories = {}
        for expense in expenses:
            if expense.category not in categories:
                categories[expense.category] = 0
            categories[expense.category] += expense.amount
        
        return {
            "total_expenses": abs(total_expenses),
            "total_income": total_income,
            "net_balance": net_balance,
            "total_transactions": len(expenses),
            "categories": categories
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching summary: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 