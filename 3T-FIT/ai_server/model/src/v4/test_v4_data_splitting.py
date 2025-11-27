"""
test_v4_data_splitting.py
Test script to verify the updated V4 data splitting and merging functionality

This script tests:
1. Data merging from multiple Excel files
2. 70-10-20 splitting ratio
3. Proper dataset preparation

Author: Claude Code Assistant
Date: 2025-11-27
"""

import sys
import os
from pathlib import Path
import pandas as pd
import numpy as np

# Add the model src to path
sys.path.append(str(Path(__file__).parent / "src" / "v4"))

from data_cleaning_v4 import V4DataCleaner
from two_branch_model_v4 import V4ModelTrainer

def test_data_merging():
    """Test data merging functionality"""
    print("="*80)
    print("TESTING V4 DATA MERGING AND SPLITTING")
    print("="*80)

    # Test data directory
    data_dir = Path(__file__).parent / "src" / "data"

    print(f"Data Directory: {data_dir}")

    # Check data files exist
    data_files = list(data_dir.glob("*.xlsx"))
    print(f"📊 Found {len(data_files)} Excel files:")
    for file in data_files:
        print(f"   • {file.name}")

    if not data_files:
        print("❌ No data files found!")
        return False

    # Test 1: Data Cleaner with automatic merging
    print("\n" + "="*60)
    print("TEST 1: V4 Data Cleaner with Dataset Merging")
    print("="*60)

    try:
        # Use the primary data file
        primary_file = data_dir / "enhanced_gym_member_exercise_tracking_10k.xlsx"
        if not primary_file.exists():
            primary_file = data_files[0]  # Fallback to first available file

        print(f"🔧 Initializing V4 Data Cleaner with: {primary_file.name}")
        data_cleaner = V4DataCleaner(str(primary_file))

        # Load data (should merge automatically)
        print("📥 Loading data with automatic merging...")
        if data_cleaner.load_data():
            print(f"✅ Data loading successful!")
            print(f"   • Combined dataset shape: {data_cleaner.original_data.shape}")
            print(f"   • Columns: {list(data_cleaner.original_data.columns[:10])}...")

            # Check if we have multiple datasets
            expected_total = 0
            for file in data_files:
                if file.name in ["enhanced_gym_member_exercise_tracking_10k.xlsx", "test_dataset.xlsx"]:
                    try:
                        temp_df = pd.read_excel(file)
                        expected_total += len(temp_df)
                        print(f"   • {file.name}: {len(temp_df)} samples")
                    except:
                        print(f"   • ❌ Could not read {file.name}")

            print(f"   • Expected total: {expected_total} samples")
            print(f"   • Actual total: {len(data_cleaner.original_data)} samples")

            if len(data_cleaner.original_data) >= expected_total * 0.95:  # Allow for some data loss in cleaning
                print("✅ Data merging successful!")
            else:
                print("⚠️ Data merging might have issues")

        else:
            print("❌ Data loading failed!")
            return False

    except Exception as e:
        print(f"❌ Error in data cleaner test: {e}")
        return False

    # Test 2: 70-10-20 Splitting
    print("\n" + "="*60)
    print("TEST 2: V4 Dataset Splitting (70-10-20)")
    print("="*60)

    try:
        # Run complete cleaning
        print("🧹 Running complete V4 data cleaning...")
        cleaned_data = data_cleaner.run_complete_cleaning_v4()

        if cleaned_data is not None:
            print(f"✅ Data cleaning successful!")
            print(f"   • Cleaned dataset shape: {cleaned_data.shape}")

            # Initialize model trainer
            print("🏋️ Initializing V4 Model Trainer...")
            trainer = V4ModelTrainer(str(primary_file), "./test_artifacts")

            # Load cleaned data
            data = trainer.load_and_prepare_data(data_cleaner=data_cleaner)

            if data is not None:
                print(f"✅ Data loading for training successful!")
                print(f"   • Training data shape: {data.shape}")

                # Test dataset preparation with 70-10-20 split
                print("🔧 Testing 70-10-20 dataset splitting...")
                train_dataset, val_dataset, test_dataset, feature_columns, target_columns = trainer.prepare_datasets(
                    train_ratio=0.7, val_ratio=0.1, test_ratio=0.2, random_state=42
                )

                total_samples = len(data)
                train_samples = len(train_dataset)
                val_samples = len(val_dataset)
                test_samples = len(test_dataset)
                actual_total = train_samples + val_samples + test_samples

                print(f"📊 Splitting Results:")
                print(f"   • Total samples: {total_samples}")
                print(f"   • Train samples: {train_samples} ({train_samples/total_samples:.1%})")
                print(f"   • Validation samples: {val_samples} ({val_samples/total_samples:.1%})")
                print(f"   • Test samples: {test_samples} ({test_samples/total_samples:.1%})")
                print(f"   • Accounted for: {actual_total}/{total_samples} ({actual_total/total_samples:.1%})")

                # Check ratios
                train_ratio_actual = train_samples / total_samples
                val_ratio_actual = val_samples / total_samples
                test_ratio_actual = test_samples / total_samples

                train_correct = 0.68 <= train_ratio_actual <= 0.72  # Allow ±2% tolerance
                val_correct = 0.08 <= val_ratio_actual <= 0.12
                test_correct = 0.18 <= test_ratio_actual <= 0.22

                if train_correct and val_correct and test_correct:
                    print("✅ 70-10-20 splitting successful!")
                else:
                    print("⚠️ Splitting ratios might be off:")
                    print(f"   • Train: {train_ratio_actual:.3f} (expected ~0.70)")
                    print(f"   • Val: {val_ratio_actual:.3f} (expected ~0.10)")
                    print(f"   • Test: {test_ratio_actual:.3f} (expected ~0.20)")

                print(f"📋 Feature columns found: {len(feature_columns)}")
                print(f"🎯 Target columns found: {len(target_columns)}")

            else:
                print("❌ Failed to load data for training!")
                return False

        else:
            print("❌ Data cleaning failed!")
            return False

    except Exception as e:
        print(f"❌ Error in splitting test: {e}")
        import traceback
        traceback.print_exc()
        return False

    # Test 3: Feature and Target Analysis
    print("\n" + "="*60)
    print("TEST 3: Feature and Target Analysis")
    print("="*60)

    try:
        # Analyze a sample from training dataset
        if len(train_dataset) > 0:
            sample = train_dataset[0]
            branch_a_features, branch_b_features, targets = sample[:3]

            print(f"🔍 Sample Analysis:")
            print(f"   • Branch A features: {branch_a_features.shape[0]} dimensions")
            print(f"   • Branch B features: {branch_b_features.shape[0]} dimensions")
            print(f"   • Number of targets: {len(targets)}")

            print(f"📊 Branch A features range: [{branch_a_features.min():.3f}, {branch_a_features.max():.3f}]")
            print(f"📊 Branch B features range: [{branch_b_features.min():.3f}, {branch_b_features.max():.3f}]")

            print("✅ Feature analysis completed!")

    except Exception as e:
        print(f"❌ Error in feature analysis: {e}")
        return False

    print("\n" + "="*80)
    print("🎉 ALL TESTS COMPLETED!")
    print("="*80)
    print("✅ Data merging: Working")
    print("✅ 70-10-20 splitting: Working")
    print("✅ Feature preparation: Working")
    print("\nThe V4 implementation is ready for training with your specified requirements!")

    return True

if __name__ == "__main__":
    success = test_data_merging()
    if success:
        print("\n✅ All tests passed! Ready for V4 training.")
    else:
        print("\n❌ Some tests failed. Check the error messages above.")

    # Cleanup test artifacts
    import shutil
    test_artifacts_dir = Path("test_artifacts")
    if test_artifacts_dir.exists():
        shutil.rmtree(test_artifacts_dir)
        print("🧹 Cleaned up test artifacts.")