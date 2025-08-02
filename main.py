from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
from datetime import datetime
from sheets_service import GoogleSheetsService

app = FastAPI(title="Expense Tracker API", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Google Sheets service
sheets_service = GoogleSheetsService()

# Pydantic schemas
class ExpenseCreate(BaseModel):
    title: str
    amount: float
    category: str

class ExpenseOut(BaseModel):
    id: str
    title: str
    amount: float
    category: str
    created_at: str

    class Config:
        from_attributes = True

# Health check endpoint
@app.get("/")
def read_root():
    return {"message": "Expense Tracker API is running with Google Sheets!"}

# Health check endpoint
@app.get("/health")
def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow()}

# POST - Add expense
@app.post("/expenses/", response_model=ExpenseOut)
def add_expense(expense: ExpenseCreate):
    try:
        new_expense = sheets_service.add_expense(
            title=expense.title,
            amount=expense.amount,
            category=expense.category
        )
        return ExpenseOut(**new_expense)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating expense: {str(e)}")

# GET all expenses
@app.get("/expenses/", response_model=List[ExpenseOut])
def get_expenses():
    try:
        expenses = sheets_service.get_all_expenses()
        return [ExpenseOut(**expense) for expense in expenses]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching expenses: {str(e)}")

# GET one expense
@app.get("/expenses/{expense_id}", response_model=ExpenseOut)
def get_expense(expense_id: str):
    try:
        expense = sheets_service.get_expense_by_id(expense_id)
        if not expense:
            raise HTTPException(status_code=404, detail="Expense not found")
        return ExpenseOut(**expense)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching expense: {str(e)}")

# PUT - Update expense
@app.put("/expenses/{expense_id}", response_model=ExpenseOut)
def update_expense(expense_id: str, expense: ExpenseCreate):
    try:
        updated_expense = sheets_service.update_expense(
            expense_id=expense_id,
            title=expense.title,
            amount=expense.amount,
            category=expense.category
        )
        if not updated_expense:
            raise HTTPException(status_code=404, detail="Expense not found")
        
        return ExpenseOut(**updated_expense)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error updating expense: {str(e)}")

# DELETE expense
@app.delete("/expenses/{expense_id}")
def delete_expense(expense_id: str):
    try:
        success = sheets_service.delete_expense(expense_id)
        if not success:
            raise HTTPException(status_code=404, detail="Expense not found")
        
        return {"message": "Expense deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting expense: {str(e)}")

# GET expenses by category
@app.get("/expenses/category/{category}", response_model=List[ExpenseOut])
def get_expenses_by_category(category: str):
    try:
        expenses = sheets_service.get_expenses_by_category(category)
        return [ExpenseOut(**expense) for expense in expenses]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching expenses by category: {str(e)}")

# GET expenses summary
@app.get("/expenses/summary/stats")
def get_expenses_summary():
    try:
        summary = sheets_service.get_expenses_summary()
        return summary
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching summary: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)