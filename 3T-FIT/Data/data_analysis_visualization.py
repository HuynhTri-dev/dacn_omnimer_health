# -*- coding: utf-8 -*-
"""
Script tiền xử lý, kiểm tra và trực quan hóa dữ liệu
Phân tích tập train và tập test để đảm bảo chất lượng dữ liệu trước khi training

Author: AI Server Team
Date: 2025-11-20
"""

import os
import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime
import warnings
import argparse
import json

warnings.filterwarnings('ignore')

# Cấu hình matplotlib cho tiếng Việt
plt.rcParams['font.family'] = 'DejaVu Sans'
plt.rcParams['figure.figsize'] = (12, 8)
plt.rcParams['figure.dpi'] = 100
sns.set_style("whitegrid")
sns.set_palette("husl")

# ==================== CẤU HÌNH ====================

DEFAULT_TRAIN_PATH = "../../../Data/data/mapped_workout_dataset_20251120_012453.xlsx"
DEFAULT_TEST_PATH = "../../../Data/data/merged_omni_health_dataset.xlsx"
DEFAULT_OUTPUT_DIR = "../../../Data/analysis_results"

# ==================== TIỀN XỬ LÝ VÀ KIỂM TRA ====================

def load_and_validate_data(file_path: str, dataset_name: str = "Dataset"):
    """
    Đọc và validate dữ liệu từ file Excel
    
    Args:
        file_path: Đường dẫn file
        dataset_name: Tên dataset (để hiển thị)
    
    Returns:
        DataFrame đã được validate
    """
    print(f"\n{'='*80}")
    print(f"ĐỌC VÀ VALIDATE {dataset_name.upper()}")
    print(f"{'='*80}")
    
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"Không tìm thấy file: {file_path}")
    
    print(f"[1] Đọc dữ liệu từ: {file_path}")
    df = pd.read_excel(file_path)
    print(f"  ✓ Đã đọc {len(df):,} records, {len(df.columns)} columns")
    
    # Thống kê cơ bản
    print(f"\n[2] Thống kê cơ bản:")
    print(f"  - Shape: {df.shape}")
    print(f"  - Memory usage: {df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")
    print(f"  - Duplicates: {df.duplicated().sum():,} ({df.duplicated().sum()/len(df)*100:.2f}%)")
    
    # Missing values
    print(f"\n[3] Missing values:")
    missing = df.isna().sum()
    missing_pct = (missing / len(df) * 100).round(2)
    missing_df = pd.DataFrame({
        'Column': missing.index,
        'Missing': missing.values,
        'Percentage': missing_pct.values
    })
    missing_df = missing_df[missing_df['Missing'] > 0].sort_values('Missing', ascending=False)
    
    if len(missing_df) > 0:
        print(f"  ⚠ Có {len(missing_df)} columns có missing values:")
        for _, row in missing_df.head(10).iterrows():
            print(f"    - {row['Column']}: {row['Missing']:,} ({row['Percentage']:.2f}%)")
        if len(missing_df) > 10:
            print(f"    ... và {len(missing_df) - 10} columns khác")
    else:
        print(f"  ✓ Không có missing values")
    
    # Data types
    print(f"\n[4] Data types:")
    dtype_counts = df.dtypes.value_counts()
    for dtype, count in dtype_counts.items():
        print(f"  - {dtype}: {count} columns")
    
    return df

def analyze_numeric_features(df: pd.DataFrame, dataset_name: str = "Dataset"):
    """
    Phân tích các features số
    
    Args:
        df: DataFrame
        dataset_name: Tên dataset
    
    Returns:
        Dictionary chứa thống kê
    """
    print(f"\n{'='*80}")
    print(f"PHÂN TÍCH NUMERIC FEATURES - {dataset_name.upper()}")
    print(f"{'='*80}")
    
    numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
    print(f"\nSố lượng numeric columns: {len(numeric_cols)}")
    
    stats = {}
    
    for col in numeric_cols:
        col_stats = {
            'count': int(df[col].count()),
            'mean': float(df[col].mean()) if df[col].count() > 0 else None,
            'std': float(df[col].std()) if df[col].count() > 0 else None,
            'min': float(df[col].min()) if df[col].count() > 0 else None,
            'max': float(df[col].max()) if df[col].count() > 0 else None,
            'median': float(df[col].median()) if df[col].count() > 0 else None,
            'missing': int(df[col].isna().sum()),
            'missing_pct': float(df[col].isna().sum() / len(df) * 100)
        }
        stats[col] = col_stats
    
    # In một số columns quan trọng
    important_cols = ['age', 'weight_kg', 'height_m', 'bmi', 'avg_hr', 'max_hr', 
                     'calories', 'duration_min', 'suitability_x', 'suitability_y']
    
    print(f"\nThống kê các features quan trọng:")
    for col in important_cols:
        if col in stats:
            s = stats[col]
            print(f"\n  {col}:")
            print(f"    Mean: {s['mean']:.2f}, Std: {s['std']:.2f}")
            print(f"    Min: {s['min']:.2f}, Max: {s['max']:.2f}, Median: {s['median']:.2f}")
            if s['missing'] > 0:
                print(f"    Missing: {s['missing']} ({s['missing_pct']:.2f}%)")
    
    return stats

def analyze_categorical_features(df: pd.DataFrame, dataset_name: str = "Dataset"):
    """
    Phân tích các features phân loại
    
    Args:
        df: DataFrame
        dataset_name: Tên dataset
    
    Returns:
        Dictionary chứa phân bố
    """
    print(f"\n{'='*80}")
    print(f"PHÂN TÍCH CATEGORICAL FEATURES - {dataset_name.upper()}")
    print(f"{'='*80}")
    
    categorical_cols = df.select_dtypes(include=['object']).columns.tolist()
    print(f"\nSố lượng categorical columns: {len(categorical_cols)}")
    
    distributions = {}
    
    # Các columns quan trọng
    important_cats = ['gender', 'experience_level', 'workout_type', 'intensity', 
                     'exercise_name', 'equipment', 'target_muscle', 'activity_level']
    
    for col in important_cats:
        if col in df.columns:
            value_counts = df[col].value_counts()
            distributions[col] = value_counts.to_dict()
            
            print(f"\n  {col}:")
            print(f"    Unique values: {df[col].nunique()}")
            print(f"    Top 5:")
            for val, count in value_counts.head(5).items():
                pct = count / len(df) * 100
                print(f"      - {val}: {count:,} ({pct:.2f}%)")
    
    return distributions

def check_data_quality(df: pd.DataFrame, dataset_name: str = "Dataset"):
    """
    Kiểm tra chất lượng dữ liệu
    
    Args:
        df: DataFrame
        dataset_name: Tên dataset
    
    Returns:
        Dictionary chứa các vấn đề
    """
    print(f"\n{'='*80}")
    print(f"KIỂM TRA CHẤT LƯỢNG DỮ LIỆU - {dataset_name.upper()}")
    print(f"{'='*80}")
    
    issues = {
        'outliers': {},
        'invalid_values': {},
        'warnings': []
    }
    
    # Kiểm tra outliers cho các features quan trọng
    print(f"\n[1] Kiểm tra outliers:")
    
    outlier_checks = {
        'age': (0, 100),
        'weight_kg': (30, 200),
        'height_m': (1.0, 2.5),
        'bmi': (10, 50),
        'avg_hr': (40, 220),
        'max_hr': (60, 220),
    }
    
    # Thêm resting_hr nếu column tồn tại
    if 'resting_hr' in df.columns:
        outlier_checks['resting_hr'] = (30, 120)
    
    for col, (min_val, max_val) in outlier_checks.items():
        if col in df.columns:
            outliers = df[(df[col] < min_val) | (df[col] > max_val)]
            if len(outliers) > 0:
                issues['outliers'][col] = len(outliers)
                print(f"  ⚠ {col}: {len(outliers):,} outliers ({len(outliers)/len(df)*100:.2f}%)")
                print(f"    Range: [{min_val}, {max_val}], Found: [{df[col].min():.2f}, {df[col].max():.2f}]")
    
    if not issues['outliers']:
        print(f"  ✓ Không phát hiện outliers bất thường")
    
    # Kiểm tra giá trị không hợp lệ
    print(f"\n[2] Kiểm tra giá trị không hợp lệ:")
    
    # BMI consistency
    if all(col in df.columns for col in ['weight_kg', 'height_m', 'bmi']):
        calculated_bmi = df['weight_kg'] / (df['height_m'] ** 2)
        bmi_diff = abs(df['bmi'] - calculated_bmi)
        inconsistent_bmi = bmi_diff > 1.0
        if inconsistent_bmi.sum() > 0:
            issues['invalid_values']['bmi_inconsistent'] = int(inconsistent_bmi.sum())
            print(f"  ⚠ BMI không nhất quán: {inconsistent_bmi.sum():,} records")
    
    # Negative values
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    for col in numeric_cols:
        if col not in ['unnamed:_22', 'unnamed:_23', 'unnamed:_24']:  # Skip unnamed columns
            negative_count = (df[col] < 0).sum()
            if negative_count > 0:
                issues['invalid_values'][f'{col}_negative'] = int(negative_count)
                print(f"  ⚠ {col}: {negative_count:,} giá trị âm")
    
    if not issues['invalid_values']:
        print(f"  ✓ Không phát hiện giá trị không hợp lệ")
    
    # Warnings
    print(f"\n[3] Cảnh báo:")
    
    # Check for low variance features
    for col in numeric_cols:
        if df[col].std() < 0.01 and df[col].count() > 0:
            issues['warnings'].append(f"{col} có variance rất thấp (std={df[col].std():.4f})")
    
    # Check for high missing rate
    high_missing = df.isna().sum() / len(df) > 0.5
    if high_missing.any():
        for col in high_missing[high_missing].index:
            issues['warnings'].append(f"{col} có >50% missing values")
    
    if issues['warnings']:
        for warning in issues['warnings'][:5]:
            print(f"  ⚠ {warning}")
        if len(issues['warnings']) > 5:
            print(f"  ... và {len(issues['warnings']) - 5} cảnh báo khác")
    else:
        print(f"  ✓ Không có cảnh báo")
    
    return issues

# ==================== TRỰC QUAN HÓA ====================

def create_visualizations(train_df: pd.DataFrame, test_df: pd.DataFrame, output_dir: str):
    """
    Tạo các biểu đồ trực quan hóa dữ liệu
    
    Args:
        train_df: DataFrame train
        test_df: DataFrame test
        output_dir: Thư mục lưu biểu đồ
    """
    print(f"\n{'='*80}")
    print(f"TẠO BIỂU ĐỒ TRỰC QUAN HÓA")
    print(f"{'='*80}")
    
    os.makedirs(output_dir, exist_ok=True)
    
    # 1. Phân bố Age
    print(f"\n[1] Vẽ biểu đồ phân bố Age...")
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    if 'age' in train_df.columns:
        axes[0].hist(train_df['age'].dropna(), bins=30, alpha=0.7, color='blue', edgecolor='black')
        axes[0].set_title('Train Set - Age Distribution', fontsize=14, fontweight='bold')
        axes[0].set_xlabel('Age')
        axes[0].set_ylabel('Frequency')
        axes[0].grid(alpha=0.3)
    
    if 'age' in test_df.columns:
        axes[1].hist(test_df['age'].dropna(), bins=30, alpha=0.7, color='green', edgecolor='black')
        axes[1].set_title('Test Set - Age Distribution', fontsize=14, fontweight='bold')
        axes[1].set_xlabel('Age')
        axes[1].set_ylabel('Frequency')
        axes[1].grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, '01_age_distribution.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  ✓ Đã lưu: 01_age_distribution.png")
    
    # 2. Phân bố BMI
    print(f"\n[2] Vẽ biểu đồ phân bố BMI...")
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    if 'bmi' in train_df.columns:
        axes[0].hist(train_df['bmi'].dropna(), bins=30, alpha=0.7, color='orange', edgecolor='black')
        axes[0].axvline(train_df['bmi'].mean(), color='red', linestyle='--', linewidth=2, label=f'Mean: {train_df["bmi"].mean():.2f}')
        axes[0].set_title('Train Set - BMI Distribution', fontsize=14, fontweight='bold')
        axes[0].set_xlabel('BMI')
        axes[0].set_ylabel('Frequency')
        axes[0].legend()
        axes[0].grid(alpha=0.3)
    
    if 'bmi' in test_df.columns:
        axes[1].hist(test_df['bmi'].dropna(), bins=30, alpha=0.7, color='purple', edgecolor='black')
        axes[1].axvline(test_df['bmi'].mean(), color='red', linestyle='--', linewidth=2, label=f'Mean: {test_df["bmi"].mean():.2f}')
        axes[1].set_title('Test Set - BMI Distribution', fontsize=14, fontweight='bold')
        axes[1].set_xlabel('BMI')
        axes[1].set_ylabel('Frequency')
        axes[1].legend()
        axes[1].grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, '02_bmi_distribution.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  ✓ Đã lưu: 02_bmi_distribution.png")
    
    # 3. Phân bố Gender
    print(f"\n[3] Vẽ biểu đồ phân bố Gender...")
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    if 'gender' in train_df.columns:
        gender_counts = train_df['gender'].value_counts()
        axes[0].bar(gender_counts.index, gender_counts.values, alpha=0.7, color=['skyblue', 'pink'])
        axes[0].set_title('Train Set - Gender Distribution', fontsize=14, fontweight='bold')
        axes[0].set_ylabel('Count')
        axes[0].grid(alpha=0.3, axis='y')
        for i, v in enumerate(gender_counts.values):
            axes[0].text(i, v + max(gender_counts.values)*0.02, str(v), ha='center', fontweight='bold')
    
    if 'gender' in test_df.columns:
        gender_counts = test_df['gender'].value_counts()
        axes[1].bar(gender_counts.index, gender_counts.values, alpha=0.7, color=['skyblue', 'pink'])
        axes[1].set_title('Test Set - Gender Distribution', fontsize=14, fontweight='bold')
        axes[1].set_ylabel('Count')
        axes[1].grid(alpha=0.3, axis='y')
        for i, v in enumerate(gender_counts.values):
            axes[1].text(i, v + max(gender_counts.values)*0.02, str(v), ha='center', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, '03_gender_distribution.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  ✓ Đã lưu: 03_gender_distribution.png")
    
    # 4. Phân bố Experience Level
    print(f"\n[4] Vẽ biểu đồ phân bố Experience Level...")
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    if 'experience_level' in train_df.columns:
        exp_counts = train_df['experience_level'].value_counts()
        colors = ['#90EE90', '#FFD700', '#FF6347']
        axes[0].bar(exp_counts.index, exp_counts.values, alpha=0.7, color=colors[:len(exp_counts)])
        axes[0].set_title('Train Set - Experience Level Distribution', fontsize=14, fontweight='bold')
        axes[0].set_ylabel('Count')
        axes[0].grid(alpha=0.3, axis='y')
        axes[0].tick_params(axis='x', rotation=45)
        for i, v in enumerate(exp_counts.values):
            axes[0].text(i, v + max(exp_counts.values)*0.02, str(v), ha='center', fontweight='bold')
    
    if 'experience_level' in test_df.columns:
        exp_counts = test_df['experience_level'].value_counts()
        axes[1].bar(exp_counts.index, exp_counts.values, alpha=0.7, color=colors[:len(exp_counts)])
        axes[1].set_title('Test Set - Experience Level Distribution', fontsize=14, fontweight='bold')
        axes[1].set_ylabel('Count')
        axes[1].grid(alpha=0.3, axis='y')
        axes[1].tick_params(axis='x', rotation=45)
        for i, v in enumerate(exp_counts.values):
            axes[1].text(i, v + max(exp_counts.values)*0.02, str(v), ha='center', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, '04_experience_level_distribution.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  ✓ Đã lưu: 04_experience_level_distribution.png")
    
    # 5. Phân bố Workout Type
    print(f"\n[5] Vẽ biểu đồ phân bố Workout Type...")
    
    workout_col = None
    for col in ['workout_type', 'category_type_want_todo', 'category_exercise_want_todo']:
        if col in train_df.columns:
            workout_col = col
            break
    
    if workout_col:
        fig, axes = plt.subplots(1, 2, figsize=(14, 5))
        
        workout_counts = train_df[workout_col].value_counts()
        axes[0].pie(workout_counts.values, labels=workout_counts.index, autopct='%1.1f%%', 
                   startangle=90, colors=sns.color_palette("husl", len(workout_counts)))
        axes[0].set_title('Train Set - Workout Type Distribution', fontsize=14, fontweight='bold')
        
        if workout_col in test_df.columns:
            workout_counts = test_df[workout_col].value_counts()
            axes[1].pie(workout_counts.values, labels=workout_counts.index, autopct='%1.1f%%',
                       startangle=90, colors=sns.color_palette("husl", len(workout_counts)))
            axes[1].set_title('Test Set - Workout Type Distribution', fontsize=14, fontweight='bold')
        
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, '05_workout_type_distribution.png'), dpi=150, bbox_inches='tight')
        plt.close()
        print(f"  ✓ Đã lưu: 05_workout_type_distribution.png")
    
    # 6. Phân bố Intensity
    print(f"\n[6] Vẽ biểu đồ phân bố Intensity...")
    if 'intensity' in train_df.columns:
        fig, axes = plt.subplots(1, 2, figsize=(14, 5))
        
        intensity_counts = train_df['intensity'].value_counts()
        intensity_order = ['Low', 'Medium', 'High', 'Maximal']
        intensity_counts = intensity_counts.reindex([i for i in intensity_order if i in intensity_counts.index])
        
        colors_intensity = ['#90EE90', '#FFD700', '#FF8C00', '#FF0000']
        axes[0].bar(intensity_counts.index, intensity_counts.values, alpha=0.7, 
                   color=colors_intensity[:len(intensity_counts)])
        axes[0].set_title('Train Set - Intensity Distribution', fontsize=14, fontweight='bold')
        axes[0].set_ylabel('Count')
        axes[0].grid(alpha=0.3, axis='y')
        for i, v in enumerate(intensity_counts.values):
            axes[0].text(i, v + max(intensity_counts.values)*0.02, str(v), ha='center', fontweight='bold')
        
        if 'intensity' in test_df.columns:
            intensity_counts = test_df['intensity'].value_counts()
            intensity_counts = intensity_counts.reindex([i for i in intensity_order if i in intensity_counts.index])
            axes[1].bar(intensity_counts.index, intensity_counts.values, alpha=0.7,
                       color=colors_intensity[:len(intensity_counts)])
            axes[1].set_title('Test Set - Intensity Distribution', fontsize=14, fontweight='bold')
            axes[1].set_ylabel('Count')
            axes[1].grid(alpha=0.3, axis='y')
            for i, v in enumerate(intensity_counts.values):
                axes[1].text(i, v + max(intensity_counts.values)*0.02, str(v), ha='center', fontweight='bold')
        
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, '06_intensity_distribution.png'), dpi=150, bbox_inches='tight')
        plt.close()
        print(f"  ✓ Đã lưu: 06_intensity_distribution.png")
    
    # 7. Correlation Heatmap (Train)
    print(f"\n[7] Vẽ correlation heatmap...")
    numeric_cols = ['age', 'weight_kg', 'bmi', 'avg_hr', 'max_hr', 'calories', 'duration_min']
    available_cols = [col for col in numeric_cols if col in train_df.columns]
    
    if len(available_cols) >= 3:
        fig, ax = plt.subplots(figsize=(10, 8))
        corr_matrix = train_df[available_cols].corr()
        sns.heatmap(corr_matrix, annot=True, fmt='.2f', cmap='coolwarm', center=0,
                   square=True, linewidths=1, cbar_kws={"shrink": 0.8}, ax=ax)
        ax.set_title('Train Set - Correlation Matrix', fontsize=14, fontweight='bold', pad=20)
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, '07_correlation_heatmap.png'), dpi=150, bbox_inches='tight')
        plt.close()
        print(f"  ✓ Đã lưu: 07_correlation_heatmap.png")
    
    # 8. Boxplot cho các features quan trọng
    print(f"\n[8] Vẽ boxplot cho features quan trọng...")
    boxplot_cols = ['age', 'weight_kg', 'bmi', 'avg_hr', 'calories']
    available_boxplot = [col for col in boxplot_cols if col in train_df.columns]
    
    if available_boxplot:
        fig, axes = plt.subplots(2, len(available_boxplot), figsize=(4*len(available_boxplot), 8))
        if len(available_boxplot) == 1:
            axes = axes.reshape(-1, 1)
        
        for i, col in enumerate(available_boxplot):
            # Train
            axes[0, i].boxplot(train_df[col].dropna(), vert=True)
            axes[0, i].set_title(f'Train - {col}', fontweight='bold')
            axes[0, i].grid(alpha=0.3)
            
            # Test
            if col in test_df.columns:
                axes[1, i].boxplot(test_df[col].dropna(), vert=True)
                axes[1, i].set_title(f'Test - {col}', fontweight='bold')
                axes[1, i].grid(alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, '08_boxplots.png'), dpi=150, bbox_inches='tight')
        plt.close()
        print(f"  ✓ Đã lưu: 08_boxplots.png")
    
    # 9. Suitability Score Distribution
    print(f"\n[9] Vẽ biểu đồ phân bố Suitability Scores...")
    if 'suitability_x' in train_df.columns or 'suitability_y' in train_df.columns:
        fig, axes = plt.subplots(1, 2, figsize=(14, 5))
        
        if 'suitability_x' in train_df.columns:
            axes[0].hist(train_df['suitability_x'].dropna(), bins=20, alpha=0.7, 
                        color='teal', edgecolor='black')
            axes[0].axvline(train_df['suitability_x'].mean(), color='red', linestyle='--', 
                          linewidth=2, label=f'Mean: {train_df["suitability_x"].mean():.2f}')
            axes[0].set_title('Train Set - Suitability X Distribution', fontsize=14, fontweight='bold')
            axes[0].set_xlabel('Suitability X')
            axes[0].set_ylabel('Frequency')
            axes[0].legend()
            axes[0].grid(alpha=0.3)
        
        if 'suitability_y' in train_df.columns:
            axes[1].hist(train_df['suitability_y'].dropna(), bins=20, alpha=0.7,
                        color='coral', edgecolor='black')
            axes[1].axvline(train_df['suitability_y'].mean(), color='red', linestyle='--',
                          linewidth=2, label=f'Mean: {train_df["suitability_y"].mean():.2f}')
            axes[1].set_title('Train Set - Suitability Y Distribution', fontsize=14, fontweight='bold')
            axes[1].set_xlabel('Suitability Y')
            axes[1].set_ylabel('Frequency')
            axes[1].legend()
            axes[1].grid(alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, '09_suitability_distribution.png'), dpi=150, bbox_inches='tight')
        plt.close()
        print(f"  ✓ Đã lưu: 09_suitability_distribution.png")
    
    # 10. Top Exercises
    print(f"\n[10] Vẽ biểu đồ Top Exercises...")
    if 'exercise_name' in train_df.columns:
        fig, axes = plt.subplots(1, 2, figsize=(14, 6))
        
        top_exercises = train_df['exercise_name'].value_counts().head(15)
        axes[0].barh(range(len(top_exercises)), top_exercises.values, alpha=0.7, color='steelblue')
        axes[0].set_yticks(range(len(top_exercises)))
        axes[0].set_yticklabels(top_exercises.index, fontsize=9)
        axes[0].set_xlabel('Count')
        axes[0].set_title('Train Set - Top 15 Exercises', fontsize=14, fontweight='bold')
        axes[0].grid(alpha=0.3, axis='x')
        axes[0].invert_yaxis()
        
        if 'exercise_name' in test_df.columns:
            top_exercises_test = test_df['exercise_name'].value_counts().head(15)
            axes[1].barh(range(len(top_exercises_test)), top_exercises_test.values, alpha=0.7, color='darkorange')
            axes[1].set_yticks(range(len(top_exercises_test)))
            axes[1].set_yticklabels(top_exercises_test.index, fontsize=9)
            axes[1].set_xlabel('Count')
            axes[1].set_title('Test Set - Top 15 Exercises', fontsize=14, fontweight='bold')
            axes[1].grid(alpha=0.3, axis='x')
            axes[1].invert_yaxis()
        
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, '10_top_exercises.png'), dpi=150, bbox_inches='tight')
        plt.close()
        print(f"  ✓ Đã lưu: 10_top_exercises.png")
    
    print(f"\n{'='*80}")
    print(f"✅ ĐÃ TẠO XONG TẤT CẢ BIỂU ĐỒ!")
    print(f"{'='*80}")

# ==================== MAIN ====================

def main():
    """Hàm chính"""
    parser = argparse.ArgumentParser(description='Phân tích và trực quan hóa dữ liệu train/test')
    parser.add_argument('--train', type=str, default=DEFAULT_TRAIN_PATH,
                       help='Đường dẫn file train data')
    parser.add_argument('--test', type=str, default=DEFAULT_TEST_PATH,
                       help='Đường dẫn file test data')
    parser.add_argument('--output', type=str, default=DEFAULT_OUTPUT_DIR,
                       help='Thư mục lưu kết quả')
    
    args = parser.parse_args()
    
    # Chuyển đổi relative path sang absolute path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    train_path = os.path.join(script_dir, args.train) if not os.path.isabs(args.train) else args.train
    test_path = os.path.join(script_dir, args.test) if not os.path.isabs(args.test) else args.test
    output_dir = os.path.join(script_dir, args.output) if not os.path.isabs(args.output) else args.output
    
    print(f"\n{'#'*80}")
    print(f"# PHÂN TÍCH VÀ TRỰC QUAN HÓA DỮ LIỆU TRAIN/TEST")
    print(f"# Thời gian: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'#'*80}")
    
    # Load data
    train_df = load_and_validate_data(train_path, "Train Data")
    test_df = load_and_validate_data(test_path, "Test Data")
    
    # Analyze numeric features
    train_numeric_stats = analyze_numeric_features(train_df, "Train Data")
    test_numeric_stats = analyze_numeric_features(test_df, "Test Data")
    
    # Analyze categorical features
    train_cat_dist = analyze_categorical_features(train_df, "Train Data")
    test_cat_dist = analyze_categorical_features(test_df, "Test Data")
    
    # Check data quality
    train_issues = check_data_quality(train_df, "Train Data")
    test_issues = check_data_quality(test_df, "Test Data")
    
    # Create visualizations
    create_visualizations(train_df, test_df, output_dir)
    
    # Save analysis report
    report = {
        'timestamp': datetime.now().isoformat(),
        'train_data': {
            'path': train_path,
            'shape': train_df.shape,
            'numeric_stats': train_numeric_stats,
            'categorical_distributions': train_cat_dist,
            'quality_issues': train_issues
        },
        'test_data': {
            'path': test_path,
            'shape': test_df.shape,
            'numeric_stats': test_numeric_stats,
            'categorical_distributions': test_cat_dist,
            'quality_issues': test_issues
        }
    }
    
    report_path = os.path.join(output_dir, 'analysis_report.json')
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    
    print(f"\n{'='*80}")
    print(f"✅ HOÀN THÀNH PHÂN TÍCH!")
    print(f"{'='*80}")
    print(f"\nKết quả đã được lưu tại: {output_dir}")
    print(f"  - Biểu đồ: {output_dir}/*.png")
    print(f"  - Báo cáo: {report_path}")
    print(f"\n{'='*80}\n")

if __name__ == "__main__":
    main()
