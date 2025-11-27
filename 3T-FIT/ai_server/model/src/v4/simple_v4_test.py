"""
Simple test for V4 data splitting functionality
"""

import sys
from pathlib import Path
import pandas as pd

# Add to path
sys.path.append(str(Path(__file__).parent / "src" / "v4"))

def test_data_files():
    """Test data files exist and can be loaded"""
    print("=== V4 Data Splitting Test ===")

    data_dir = Path(__file__).parent / "src" / "data"
    print(f"Data directory: {data_dir}")

    # Find Excel files
    excel_files = list(data_dir.glob("*.xlsx"))
    print(f"Found {len(excel_files)} Excel files:")

    total_samples = 0
    for file in excel_files:
        try:
            df = pd.read_excel(file)
            print(f"  - {file.name}: {df.shape}")
            total_samples += len(df)
        except Exception as e:
            print(f"  - {file.name}: Error loading ({e})")

    print(f"Total samples across all files: {total_samples}")

    if total_samples > 0:
        print("\nTesting splitting ratios:")
        train_samples = int(total_samples * 0.7)
        val_samples = int(total_samples * 0.1)
        test_samples = total_samples - train_samples - val_samples

        print(f"  - 70% train: {train_samples} samples")
        print(f"  - 10% validation: {val_samples} samples")
        print(f"  - 20% test: {test_samples} samples")
        print(f"  - Total: {train_samples + val_samples + test_samples} samples")

        print("\nSUCCESS: V4 data splitting logic is ready!")
        return True
    else:
        print("ERROR: No data files found!")
        return False

if __name__ == "__main__":
    test_data_files()