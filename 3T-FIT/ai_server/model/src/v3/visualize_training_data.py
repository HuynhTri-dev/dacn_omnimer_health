"""
visualize_training_data.py
Visualization Script for V3 Training Data Analysis

This script generates comprehensive visualizations for analyzing training data
including distributions, correlations, and relationships between features.

Usage:
    python visualize_training_data.py --data_dir ./data --output_dir ./visualizations
"""

import os
import argparse
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

# Import from train_v3_enhanced
try:
    from train_v3_enhanced import (
        load_and_combine_datasets,
        map_sepa_to_numeric,
        MOOD_MAPPING,
        FATIGUE_MAPPING,
        EFFORT_MAPPING,
        calculate_readiness_factor
    )
except ImportError:
    print("Error: Could not import from train_v3_enhanced.py")
    exit(1)

def plot_training_data_analysis(df: pd.DataFrame, output_dir: str):
    """
    Create comprehensive visualizations for training data analysis
    """
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"\n📊 Generating Training Data Visualizations...")
    
    # Set style
    sns.set_style("whitegrid")
    plt.rcParams['figure.figsize'] = (15, 10)
    
    # 1. Target Variable Distributions
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    fig.suptitle('Target Variable Distributions', fontsize=16, fontweight='bold')
    
    # 1RM Distribution
    if 'estimated_1rm' in df.columns:
        axes[0, 0].hist(df['estimated_1rm'].dropna(), bins=50, color='steelblue', edgecolor='black', alpha=0.7)
        axes[0, 0].set_title('Estimated 1RM Distribution')
        axes[0, 0].set_xlabel('1RM (kg)')
        axes[0, 0].set_ylabel('Frequency')
        axes[0, 0].axvline(df['estimated_1rm'].mean(), color='red', linestyle='--', label=f'Mean: {df["estimated_1rm"].mean():.1f}')
        axes[0, 0].legend()
    
    # Suitability Score Distribution
    if 'suitability_score' in df.columns:
        axes[0, 1].hist(df['suitability_score'].dropna(), bins=30, color='green', edgecolor='black', alpha=0.7)
        axes[0, 1].set_title('Suitability Score Distribution')
        axes[0, 1].set_xlabel('Suitability Score')
        axes[0, 1].set_ylabel('Frequency')
        axes[0, 1].axvline(df['suitability_score'].mean(), color='red', linestyle='--', label=f'Mean: {df["suitability_score"].mean():.3f}')
        axes[0, 1].legend()
    
    # Readiness Factor Distribution
    if 'readiness_factor' in df.columns:
        axes[1, 0].hist(df['readiness_factor'].dropna(), bins=30, color='orange', edgecolor='black', alpha=0.7)
        axes[1, 0].set_title('Readiness Factor Distribution')
        axes[1, 0].set_xlabel('Readiness Factor')
        axes[1, 0].set_ylabel('Frequency')
        axes[1, 0].axvline(df['readiness_factor'].mean(), color='red', linestyle='--', label=f'Mean: {df["readiness_factor"].mean():.3f}')
        axes[1, 0].legend()
    
    # BMI Distribution
    if 'bmi' in df.columns:
        axes[1, 1].hist(df['bmi'].dropna(), bins=40, color='purple', edgecolor='black', alpha=0.7)
        axes[1, 1].set_title('BMI Distribution')
        axes[1, 1].set_xlabel('BMI')
        axes[1, 1].set_ylabel('Frequency')
        axes[1, 1].axvline(df['bmi'].mean(), color='red', linestyle='--', label=f'Mean: {df["bmi"].mean():.1f}')
        axes[1, 1].legend()
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, '01_target_distributions.png'), dpi=300, bbox_inches='tight')
    plt.close()
    print(f"  ✅ Saved: 01_target_distributions.png")
    
    # 2. SePA (Sleep, Psychology, Activity) Analysis
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('SePA Features Distribution', fontsize=16, fontweight='bold')
    
    sepa_cols = ['mood_numeric', 'fatigue_numeric', 'effort_numeric']
    sepa_titles = ['Mood (1-5)', 'Fatigue (1-5)', 'Effort (1-5)']
    colors = ['skyblue', 'salmon', 'lightgreen']
    
    for idx, (col, title, color) in enumerate(zip(sepa_cols, sepa_titles, colors)):
        if col in df.columns:
            value_counts = df[col].value_counts().sort_index()
            axes[idx].bar(value_counts.index, value_counts.values, color=color, edgecolor='black', alpha=0.7)
            axes[idx].set_title(title)
            axes[idx].set_xlabel('Score')
            axes[idx].set_ylabel('Count')
            axes[idx].set_xticks([1, 2, 3, 4, 5])
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, '02_sepa_distributions.png'), dpi=300, bbox_inches='tight')
    plt.close()
    print(f"  ✅ Saved: 02_sepa_distributions.png")
    
    # 3. Correlation Heatmap
    numeric_cols = ['age', 'weight_kg', 'height_m', 'bmi', 'experience_level', 
                    'workout_frequency', 'resting_heartrate', 'mood_numeric', 
                    'fatigue_numeric', 'effort_numeric', 'estimated_1rm', 
                    'suitability_score', 'readiness_factor']
    
    available_numeric = [col for col in numeric_cols if col in df.columns]
    
    if len(available_numeric) > 2:
        plt.figure(figsize=(14, 12))
        correlation_matrix = df[available_numeric].corr()
        
        mask = np.triu(np.ones_like(correlation_matrix, dtype=bool))
        sns.heatmap(correlation_matrix, mask=mask, annot=True, fmt='.2f', 
                   cmap='coolwarm', center=0, square=True, linewidths=1,
                   cbar_kws={"shrink": 0.8})
        
        plt.title('Feature Correlation Heatmap', fontsize=16, fontweight='bold', pad=20)
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, '03_correlation_heatmap.png'), dpi=300, bbox_inches='tight')
        plt.close()
        print(f"  ✅ Saved: 03_correlation_heatmap.png")
    
    # 4. 1RM vs User Characteristics
    fig, axes = plt.subplots(2, 3, figsize=(18, 10))
    fig.suptitle('1RM Relationships with User Characteristics', fontsize=16, fontweight='bold')
    
    scatter_pairs = [
        ('age', 'estimated_1rm', 'Age vs 1RM'),
        ('weight_kg', 'estimated_1rm', 'Weight vs 1RM'),
        ('bmi', 'estimated_1rm', 'BMI vs 1RM'),
        ('experience_level', 'estimated_1rm', 'Experience vs 1RM'),
        ('workout_frequency', 'estimated_1rm', 'Workout Frequency vs 1RM'),
        ('readiness_factor', 'estimated_1rm', 'Readiness vs 1RM')
    ]
    
    for idx, (x_col, y_col, title) in enumerate(scatter_pairs):
        row, col = idx // 3, idx % 3
        if x_col in df.columns and y_col in df.columns:
            axes[row, col].scatter(df[x_col], df[y_col], alpha=0.5, s=20, color='steelblue')
            axes[row, col].set_title(title)
            axes[row, col].set_xlabel(x_col.replace('_', ' ').title())
            axes[row, col].set_ylabel('1RM (kg)')
            
            # Add trend line
            valid_data = df[[x_col, y_col]].dropna()
            if len(valid_data) > 1:
                z = np.polyfit(valid_data[x_col], valid_data[y_col], 1)
                p = np.poly1d(z)
                x_sorted = valid_data[x_col].sort_values()
                axes[row, col].plot(x_sorted, p(x_sorted), "r--", alpha=0.8, linewidth=2)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, '04_1rm_relationships.png'), dpi=300, bbox_inches='tight')
    plt.close()
    print(f"  ✅ Saved: 04_1rm_relationships.png")
    
    # 5. Gender Analysis
    if 'gender' in df.columns and 'estimated_1rm' in df.columns:
        fig, axes = plt.subplots(1, 2, figsize=(14, 5))
        fig.suptitle('Gender-based Analysis', fontsize=16, fontweight='bold')
        
        # 1RM by Gender
        gender_1rm = df.groupby('gender')['estimated_1rm'].apply(list)
        axes[0].boxplot(gender_1rm.values, labels=gender_1rm.index)
        axes[0].set_title('1RM Distribution by Gender')
        axes[0].set_ylabel('1RM (kg)')
        axes[0].grid(True, alpha=0.3)
        
        # Count by Gender
        gender_counts = df['gender'].value_counts()
        axes[1].bar(gender_counts.index, gender_counts.values, color=['lightblue', 'lightpink'], 
                   edgecolor='black', alpha=0.7)
        axes[1].set_title('Sample Count by Gender')
        axes[1].set_ylabel('Count')
        
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, '05_gender_analysis.png'), dpi=300, bbox_inches='tight')
        plt.close()
        print(f"  ✅ Saved: 05_gender_analysis.png")
    
    # 6. Experience Level Analysis
    if 'experience_level' in df.columns and 'estimated_1rm' in df.columns:
        plt.figure(figsize=(10, 6))
        
        exp_1rm = df.groupby('experience_level')['estimated_1rm'].apply(list)
        plt.boxplot(exp_1rm.values, labels=exp_1rm.index)
        plt.title('1RM Distribution by Experience Level', fontsize=14, fontweight='bold')
        plt.xlabel('Experience Level')
        plt.ylabel('1RM (kg)')
        plt.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, '06_experience_analysis.png'), dpi=300, bbox_inches='tight')
        plt.close()
        print(f"  ✅ Saved: 06_experience_analysis.png")
    
    print(f"\n✅ All visualizations saved to: {output_dir}/")
    return output_dir

def prepare_data_for_visualization(df: pd.DataFrame) -> pd.DataFrame:
    """Prepare data by adding necessary computed columns"""
    
    # Process SePA columns
    if 'mood' in df.columns:
        if df['mood'].dtype == 'object':
            df['mood_numeric'] = df['mood'].apply(lambda x: map_sepa_to_numeric(x, MOOD_MAPPING))
        else:
            df['mood_numeric'] = df['mood'].astype(float)
    
    if 'fatigue' in df.columns:
        if df['fatigue'].dtype == 'object':
            df['fatigue_numeric'] = df['fatigue'].apply(lambda x: map_sepa_to_numeric(x, FATIGUE_MAPPING))
        else:
            df['fatigue_numeric'] = df['fatigue'].astype(float)
    
    if 'effort' in df.columns:
        if df['effort'].dtype == 'object':
            df['effort_numeric'] = df['effort'].apply(lambda x: map_sepa_to_numeric(x, EFFORT_MAPPING))
        else:
            df['effort_numeric'] = df['effort'].astype(float)
    
    # Calculate readiness factors
    df['readiness_factor'] = df.apply(
        lambda row: calculate_readiness_factor(
            row.get('mood_numeric', 3),
            row.get('fatigue_numeric', 3),
            row.get('effort_numeric', 3)
        ), axis=1
    )
    
    # Use existing suitability_x as suitability_score
    if 'suitability_x' in df.columns:
        df['suitability_score'] = df['suitability_x']
    elif 'suitability_score' not in df.columns:
        df['suitability_score'] = 0.7  # Default
    
    return df

def main():
    parser = argparse.ArgumentParser(description='Visualize V3 Training Data')
    parser.add_argument('--data_dir', type=str, default='./data',
                       help='Directory containing training data')
    parser.add_argument('--output_dir', type=str, default='./visualizations',
                       help='Directory to save visualizations')
    
    args = parser.parse_args()
    
    print("="*80)
    print("V3 TRAINING DATA VISUALIZATION")
    print("="*80)
    
    # Load data
    df_combined = load_and_combine_datasets(args.data_dir)
    print(f"\nLoaded {len(df_combined)} samples")
    
    # Prepare data
    df_prepared = prepare_data_for_visualization(df_combined)
    
    # Generate visualizations
    plot_training_data_analysis(df_prepared, args.output_dir)
    
    print("\n" + "="*80)
    print("VISUALIZATION COMPLETED SUCCESSFULLY")
    print("="*80)

if __name__ == "__main__":
    main()
