import pandas as pd
import os

file1 = r'd:\dacn_omnimer_health\3T-FIT\Data\data\gym_member_exercise_tracking.xlsx'
file2 = r'd:\dacn_omnimer_health\3T-FIT\Data\data\WorkoutTrackerDataset.xlsx'

try:
    print(f"Reading {file1}...")
    df1 = pd.read_excel(file1, nrows=5)
    print('--- gym_member_exercise_tracking.xlsx ---')
    print(df1.columns.tolist())
    print(df1.head(2))
except Exception as e:
    print(f"Error reading {file1}: {e}")

try:
    print(f"\nReading {file2}...")
    df2 = pd.read_excel(file2, nrows=5)
    print('--- WorkoutTrackerDataset.xlsx ---')
    print(df2.columns.tolist())
    print(df2.head(2))
except Exception as e:
    print(f"Error reading {file2}: {e}")
