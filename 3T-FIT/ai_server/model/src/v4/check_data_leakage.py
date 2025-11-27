import pandas as pd
import os

def check_data_overlap():
    # Define paths
    train_path = '../data/training_data/train_data.xlsx'
    test_path = '../data/training_data/test_data.xlsx'
    
    print(f"Checking overlap between:\n1. {train_path}\n2. {test_path}\n")
    
    try:
        # Load data
        print("Loading files...")
        df_train = pd.read_excel(train_path)
        df_test = pd.read_excel(test_path)
        
        print(f"Train shape: {df_train.shape}")
        print(f"Test shape: {df_test.shape}")
        
        # Check for exact duplicates across all columns
        # We merge them with an indicator to see which rows appear in both
        print("\nChecking for exact row duplicates...")
        
        # Method 1: Merge
        # Note: This checks if an entire row in Test is identical to a row in Train
        common_rows = pd.merge(df_train, df_test, how='inner')
        
        num_overlap = len(common_rows)
        
        if num_overlap == 0:
            print("✅ GREAT NEWS: No identical rows found between Train and Test sets.")
        else:
            print(f"⚠️ WARNING: Found {num_overlap} identical rows in both datasets!")
            print(f"Percentage of Test data that is in Train: {(num_overlap/len(df_test))*100:.2f}%")
            
        # Method 2: Check based on specific ID columns if they exist (optional but recommended if you have IDs)
        # Assuming no ID column based on previous file reads, so skipping ID check.
        
        print("\n" + "="*50)
        print("VERIFICATION COMPLETE")
        print("="*50)
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    check_data_overlap()
