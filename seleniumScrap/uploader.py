import os
import pandas as pd
import numpy as np
from supabase import create_client, Client

# Supabase project details
SUPABASE_URL = "https://iqfcfhftrwdgipjdlssv.supabase.co"
SUPABASE_KEY = os.environ.get("SUPABASE_KEY", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxZmNmaGZ0cndkZ2lwamRsc3N2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTAwNzEwNiwiZXhwIjoyMDY2NTgzMTA2fQ.uc7Kaokb2H9Xyx6yB2tCWIFhOQxLc0v6aP5Pm-714vk")  # Add your API key here
TABLE_NAME = "luma_events"

def clear_table(supabase: Client):
    """
    Deletes all rows from the specified table if it's not empty.
    """
    try:
        # Check if the table is empty
        select_response = supabase.table(TABLE_NAME).select('id', count='exact').limit(0).execute()

        if select_response.count > 0:
            print(f"Table '{TABLE_NAME}' contains {select_response.count} rows. Clearing now.")
            # If not empty, clear the table
            delete_response = supabase.table(TABLE_NAME).delete().gt('id', 0).execute()
            if len(delete_response.data) > 0:
                print(f"Table '{TABLE_NAME}' cleared successfully.")
            else:
                 print(f"Error clearing table.") # Simplified error message
        else:
            print(f"Table '{TABLE_NAME}' is already empty. Skipping clear operation.")

    except Exception as e:
        print(f"An error occurred while clearing the table: {e}")


def upload_csv_to_supabase(file_path):
    """
    Uploads a CSV file to a Supabase table.

    :param file_path: The path to the CSV file.
    """
    if not os.path.exists(file_path):
        print(f"Error: File not found at {file_path}")
        return

    try:
        # Initialize Supabase client
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

        # Clear the table before uploading new data
        clear_table(supabase)

        # Read the CSV file
        df = pd.read_csv(file_path)

        # Replace NaN values with None
        df = df.replace({np.nan: None})

        # Convert dataframe to a list of dictionaries
        data_to_upload = df.to_dict(orient="records")

        # Upload the data to Supabase
        response = supabase.table(TABLE_NAME).insert(data_to_upload).execute()

        if len(response.data) > 0:
            print(f"Successfully uploaded {len(response.data)} records to '{TABLE_NAME}'.")
        else:
            print(f"Error uploading data: {response.error}")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    # Replace 'path/to/your/luma_events.csv' with the actual path to your CSV file
    csv_file_path = "luma_events.csv"
    upload_csv_to_supabase(csv_file_path)