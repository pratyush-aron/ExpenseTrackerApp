import os
import json
from typing import List, Optional, Dict, Any
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from datetime import datetime
from uuid import uuid4
from dotenv import load_dotenv

load_dotenv()

# If modifying these scopes, delete the file token.json.
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']

class GoogleSheetsService:
    def __init__(self):
        self.spreadsheet_id = os.getenv("GOOGLE_SHEETS_ID")
        self.service = self._authenticate()
        self.sheet_name = "Expenses"  # Main sheet name
        
        # Initialize the sheet if it doesn't exist
        self._initialize_sheet()
    
    def _authenticate(self):
        """Authenticate and return the Google Sheets service object."""
        # Try service account first (recommended for production)
        service_account_file = os.getenv("GOOGLE_SERVICE_ACCOUNT_FILE")
        if service_account_file and os.path.exists(service_account_file):
            try:
                # Check if the file is actually a service account file
                with open(service_account_file, 'r') as f:
                    file_content = json.load(f)
                
                if file_content.get('type') == 'service_account':
                    print(f"Using service account: {file_content.get('client_email')}")
                    from google.oauth2.service_account import Credentials as ServiceCredentials
                    creds = ServiceCredentials.from_service_account_file(
                        service_account_file, scopes=SCOPES)
                    return build('sheets', 'v4', credentials=creds)
                else:
                    print(f"Warning: {service_account_file} is not a service account file")
            except Exception as e:
                print(f"Error reading service account file: {e}")
        
        # Try OAuth flow with existing token
        creds = None
        if os.path.exists('token.json'):
            creds = Credentials.from_authorized_user_file('token.json', SCOPES)
        
        # If no valid credentials, try OAuth
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                # Try OAuth with credentials.json
                if os.path.exists('credentials.json'):
                    try:
                        # First check if it's a service account file
                        with open('credentials.json', 'r') as f:
                            client_config = json.load(f)
                        
                        if client_config.get('type') == 'service_account':
                            print("Found service account in credentials.json, using that instead")
                            from google.oauth2.service_account import Credentials as ServiceCredentials
                            creds = ServiceCredentials.from_service_account_file(
                                'credentials.json', scopes=SCOPES)
                            return build('sheets', 'v4', credentials=creds)
                        
                        # Check if it's OAuth format
                        elif 'installed' in client_config or 'web' in client_config:
                            flow = InstalledAppFlow.from_client_secrets_file(
                                'credentials.json', SCOPES)
                            creds = flow.run_local_server(port=0)
                        else:
                            raise ValueError("Invalid credentials.json format")
                        
                    except Exception as e:
                        raise Exception(f"Authentication failed: {e}")
                else:
                    raise Exception(
                        "No authentication method available.\n"
                        "Please provide either:\n"
                        "1. credentials.json (OAuth or Service Account)\n"
                        "2. Set GOOGLE_SERVICE_ACCOUNT_FILE in .env\n"
                    )
            
            # Save OAuth credentials for next run
            if creds and hasattr(creds, 'to_json'):
                with open('token.json', 'w') as token:
                    token.write(creds.to_json())
        
        return build('sheets', 'v4', credentials=creds)
    
    def _initialize_sheet(self):
        """Initialize the sheet with headers if it doesn't exist or is empty."""
        try:
            # Check if sheet exists and has headers
            result = self.service.spreadsheets().values().get(
                spreadsheetId=self.spreadsheet_id,
                range=f'{self.sheet_name}!A1:E1'
            ).execute()
            
            values = result.get('values', [])
            
            if not values or values[0] != ['ID', 'Title', 'Amount', 'Category', 'Created At']:
                # Add headers
                headers = [['ID', 'Title', 'Amount', 'Category', 'Created At']]
                self.service.spreadsheets().values().update(
                    spreadsheetId=self.spreadsheet_id,
                    range=f'{self.sheet_name}!A1:E1',
                    valueInputOption='RAW',
                    body={'values': headers}
                ).execute()
                
        except HttpError as error:
            if error.resp.status == 400:
                # Sheet doesn't exist, create it
                self._create_sheet()
                self._initialize_sheet()
            else:
                raise error
    
    def _create_sheet(self):
        """Create the expenses sheet."""
        try:
            sheet_metadata = {
                'requests': [{
                    'addSheet': {
                        'properties': {
                            'title': self.sheet_name
                        }
                    }
                }]
            }
            
            self.service.spreadsheets().batchUpdate(
                spreadsheetId=self.spreadsheet_id,
                body=sheet_metadata
            ).execute()
            
        except HttpError as error:
            print(f"An error occurred creating sheet: {error}")
            raise error
    
    def _get_next_row(self) -> int:
        """Get the next empty row number."""
        try:
            result = self.service.spreadsheets().values().get(
                spreadsheetId=self.spreadsheet_id,
                range=f'{self.sheet_name}!A:A'
            ).execute()
            
            values = result.get('values', [])
            return len(values) + 1
            
        except HttpError as error:
            print(f"An error occurred getting next row: {error}")
            return 2  # Start from row 2 if error (row 1 is headers)
    
    def add_expense(self, title: str, amount: float, category: str) -> Dict[str, Any]:
        """Add a new expense to the sheet."""
        try:
            expense_id = str(uuid4())
            created_at = datetime.utcnow().isoformat()
            
            row_data = [[expense_id, title, amount, category, created_at]]
            next_row = self._get_next_row()
            
            self.service.spreadsheets().values().update(
                spreadsheetId=self.spreadsheet_id,
                range=f'{self.sheet_name}!A{next_row}:E{next_row}',
                valueInputOption='RAW',
                body={'values': row_data}
            ).execute()
            
            return {
                'id': expense_id,
                'title': title,
                'amount': amount,
                'category': category,
                'created_at': created_at
            }
            
        except HttpError as error:
            print(f"An error occurred adding expense: {error}")
            raise error
    
    def get_all_expenses(self) -> List[Dict[str, Any]]:
        """Get all expenses from the sheet."""
        try:
            result = self.service.spreadsheets().values().get(
                spreadsheetId=self.spreadsheet_id,
                range=f'{self.sheet_name}!A2:E'  # Skip header row
            ).execute()
            
            values = result.get('values', [])
            expenses = []
            
            for row in values:
                if len(row) >= 5:  # Ensure row has all required columns
                    expenses.append({
                        'id': row[0],
                        'title': row[1],
                        'amount': float(row[2]) if row[2] else 0.0,
                        'category': row[3],
                        'created_at': row[4]
                    })
            
            # Sort by created_at in descending order
            expenses.sort(key=lambda x: x['created_at'], reverse=True)
            return expenses
            
        except HttpError as error:
            print(f"An error occurred getting expenses: {error}")
            return []
    
    def get_expense_by_id(self, expense_id: str) -> Optional[Dict[str, Any]]:
        """Get a specific expense by ID."""
        expenses = self.get_all_expenses()
        for expense in expenses:
            if expense['id'] == expense_id:
                return expense
        return None
    
    def update_expense(self, expense_id: str, title: str, amount: float, category: str) -> Optional[Dict[str, Any]]:
        """Update an existing expense."""
        try:
            # Find the row with the matching ID
            result = self.service.spreadsheets().values().get(
                spreadsheetId=self.spreadsheet_id,
                range=f'{self.sheet_name}!A:E'
            ).execute()
            
            values = result.get('values', [])
            
            for i, row in enumerate(values[1:], start=2):  # Skip header row
                if len(row) > 0 and row[0] == expense_id:
                    # Update the row
                    updated_row = [[expense_id, title, amount, category, row[4]]]  # Keep original created_at
                    
                    self.service.spreadsheets().values().update(
                        spreadsheetId=self.spreadsheet_id,
                        range=f'{self.sheet_name}!A{i}:E{i}',
                        valueInputOption='RAW',
                        body={'values': updated_row}
                    ).execute()
                    
                    return {
                        'id': expense_id,
                        'title': title,
                        'amount': amount,
                        'category': category,
                        'created_at': row[4]
                    }
            
            return None  # Expense not found
            
        except HttpError as error:
            print(f"An error occurred updating expense: {error}")
            raise error
    
    def delete_expense(self, expense_id: str) -> bool:
        """Delete an expense by ID."""
        try:
            # Find the row with the matching ID
            result = self.service.spreadsheets().values().get(
                spreadsheetId=self.spreadsheet_id,
                range=f'{self.sheet_name}!A:E'
            ).execute()
            
            values = result.get('values', [])
            
            for i, row in enumerate(values[1:], start=2):  # Skip header row
                if len(row) > 0 and row[0] == expense_id:
                    # Delete the row
                    delete_request = {
                        'requests': [{
                            'deleteDimension': {
                                'range': {
                                    'sheetId': self._get_sheet_id(),
                                    'dimension': 'ROWS',
                                    'startIndex': i - 1,  # 0-based index
                                    'endIndex': i
                                }
                            }
                        }]
                    }
                    
                    self.service.spreadsheets().batchUpdate(
                        spreadsheetId=self.spreadsheet_id,
                        body=delete_request
                    ).execute()
                    
                    return True
            
            return False  # Expense not found
            
        except HttpError as error:
            print(f"An error occurred deleting expense: {error}")
            raise error
    
    def _get_sheet_id(self) -> int:
        """Get the sheet ID for the expenses sheet."""
        try:
            sheet_metadata = self.service.spreadsheets().get(
                spreadsheetId=self.spreadsheet_id
            ).execute()
            
            sheets = sheet_metadata.get('sheets', [])
            for sheet in sheets:
                if sheet['properties']['title'] == self.sheet_name:
                    return sheet['properties']['sheetId']
            
            return 0  # Default sheet ID
            
        except HttpError as error:
            print(f"An error occurred getting sheet ID: {error}")
            return 0
    
    def get_expenses_by_category(self, category: str) -> List[Dict[str, Any]]:
        """Get expenses filtered by category."""
        all_expenses = self.get_all_expenses()
        return [expense for expense in all_expenses if expense['category'] == category]
    
    def get_expenses_summary(self) -> Dict[str, Any]:
        """Get summary statistics of all expenses."""
        expenses = self.get_all_expenses()
        
        total_expenses = sum(exp['amount'] for exp in expenses if exp['amount'] < 0)
        total_income = sum(exp['amount'] for exp in expenses if exp['amount'] > 0)
        net_balance = total_income + total_expenses
        
        # Category breakdown
        categories = {}
        for expense in expenses:
            category = expense['category']
            if category not in categories:
                categories[category] = 0
            categories[category] += expense['amount']
        
        return {
            "total_expenses": abs(total_expenses),
            "total_income": total_income,
            "net_balance": net_balance,
            "total_transactions": len(expenses),
            "categories": categories
        }