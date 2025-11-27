"""
data_cleaning.py
Data Cleaning and Preprocessing for V3 Model Improvement

This script implements comprehensive data cleaning strategies:
1. Remove invalid 1RM values (near-zero and outliers)
2. Apply statistical outlier detection
3. Implement domain-specific validation rules
4. Create cleaned training and test sets

Author: Claude Code Assistant
Date: 2025-11-27
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
from scipy import stats
from sklearn.preprocessing import RobustScaler
import json

class V3DataCleaner:
    """Comprehensive data cleaning for V3 model"""

    def __init__(self, data_path: str):
        """
        Initialize data cleaner

        Args:
            data_path: Path to the raw data file
        """
        self.data_path = Path(data_path)
        self.original_data = None
        self.cleaned_data = None
        self.cleaning_report = {}

        # Domain-specific thresholds
        self.DOMAIN_THRESHOLDS = {
            'min_1rm_adult_male': 20,      # kg - minimum reasonable for adult male
            'min_1rm_adult_female': 15,     # kg - minimum reasonable for adult female
            'max_1rm_beginner': 80,         # kg - maximum for beginners
            'max_1rm_advanced': 300,         # kg - reasonable maximum
            'min_age': 16,                   # years - minimum training age
            'max_age': 80,                    # years - maximum training age
            'min_weight_kg': 35,              # kg - minimum healthy weight
            'max_weight_kg': 200,             # kg - maximum reasonable weight
            'min_height_m': 1.2,             # m - minimum adult height
            'max_height_m': 2.4,              # m - maximum reasonable height
            'min_bmi': 15,                   # kg/m² - minimum healthy BMI
            'max_bmi': 50,                    # kg/m² - maximum reasonable BMI
            'min_resting_hr': 40,              # bpm - minimum resting heart rate
            'max_resting_hr': 120,             # bpm - maximum resting heart rate
            'min_workout_freq': 1,             # days/week - minimum frequency
            'max_workout_freq': 7,             # days/week - maximum frequency
        }

    def load_data(self):
        """Load original data"""
        try:
            self.original_data = pd.read_excel(self.data_path)
            print(f"📁 Loaded data: {self.original_data.shape}")
            return True
        except Exception as e:
            print(f"❌ Error loading data: {e}")
            return False

    def analyze_data_quality(self, data: pd.DataFrame) -> dict:
        """
        Comprehensive data quality analysis

        Returns:
            Dictionary with quality metrics
        """
        analysis = {
            'total_rows': len(data),
            'total_columns': len(data.columns),
            'missing_values': data.isnull().sum().to_dict(),
            'zero_1rm_count': (data['estimated_1rm'] == 0).sum(),
            'near_zero_1rm_count': (data['estimated_1rm'] < 5).sum(),
            'negative_1rm_count': (data['estimated_1rm'] < 0).sum(),
            'invalid_age_count': ((data['age'] < self.DOMAIN_THRESHOLDS['min_age']) |
                               (data['age'] > self.DOMAIN_THRESHOLDS['max_age'])).sum(),
            'invalid_weight_count': ((data['weight_kg'] < self.DOMAIN_THRESHOLDS['min_weight_kg']) |
                                 (data['weight_kg'] > self.DOMAIN_THRESHOLDS['max_weight_kg'])).sum(),
            'invalid_height_count': ((data['height_m'] < self.DOMAIN_THRESHOLDS['min_height_m']) |
                                 (data['height_m'] > self.DOMAIN_THRESHOLDS['max_height_m'])).sum(),
            'bmi_outliers': self._detect_bmi_outliers(data['bmi']),
            'heart_rate_outliers': self._detect_hr_outliers(data['resting_heartrate']),
        }

        # 1RM statistics
        analysis['1rm_stats'] = {
            'mean': data['estimated_1rm'].mean(),
            'std': data['estimated_1rm'].std(),
            'min': data['estimated_1rm'].min(),
            'max': data['estimated_1rm'].max(),
            'q1': data['estimated_1rm'].quantile(0.25),
            'q3': data['estimated_1rm'].quantile(0.75),
            'iqr': data['estimated_1rm'].quantile(0.75) - data['estimated_1rm'].quantile(0.25),
            'skewness': stats.skew(data['estimated_1rm']),
            'kurtosis': stats.kurtosis(data['estimated_1rm'])
        }

        return analysis

    def _detect_bmi_outliers(self, bmi_series: pd.Series) -> int:
        """Detect BMI outliers using IQR method"""
        q1, q3 = bmi_series.quantile([0.25, 0.75])
        iqr = q3 - q1
        lower_bound = q1 - 1.5 * iqr
        upper_bound = q3 + 1.5 * iqr
        return ((bmi_series < lower_bound) | (bmi_series > upper_bound)).sum()

    def _detect_hr_outliers(self, hr_series: pd.Series) -> int:
        """Detect heart rate outliers using domain knowledge"""
        return ((hr_series < 40) | (hr_series > 100)).sum()

    def remove_invalid_1rm_values(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Remove invalid 1RM values using multiple strategies

        Strategies:
        1. Remove zero values
        2. Remove near-zero values (< 5kg)
        3. Remove negative values
        4. Remove statistical outliers
        5. Remove domain-inconsistent values
        """
        print("🧹 Cleaning 1RM values...")

        initial_count = len(data)
        cleaned_data = data.copy()

        # Strategy 1: Remove zero and negative values
        mask = cleaned_data['estimated_1rm'] > 0
        cleaned_data = cleaned_data[mask]
        zero_removed = initial_count - len(cleaned_data)

        # Strategy 2: Remove near-zero values
        mask = cleaned_data['estimated_1rm'] >= 5
        cleaned_data = cleaned_data[mask]
        near_zero_removed = initial_count - zero_removed - len(cleaned_data)

        # Strategy 3: Statistical outlier removal using IQR
        q1, q3 = cleaned_data['estimated_1rm'].quantile([0.25, 0.75])
        iqr = q3 - q1
        lower_bound = q1 - 1.5 * iqr
        upper_bound = q3 + 1.5 * iqr

        mask = (cleaned_data['estimated_1rm'] >= lower_bound) & (cleaned_data['estimated_1rm'] <= upper_bound)
        cleaned_data = cleaned_data[mask]
        statistical_outliers_removed = initial_count - zero_removed - near_zero_removed - len(cleaned_data)

        # Strategy 4: Domain consistency check
        # 1RM should be reasonable based on body weight and experience
        def is_1rm_reasonable(row):
            weight = row['weight_kg']
            exp = row['experience_level']

            # Handle gender column properly (could be int or string)
            gender_val = row.get('gender', 'male')
            if isinstance(gender_val, (int, float)):
                gender = 'female' if gender_val in [0, 2] else 'male'  # Common encoding: 0,2=female, 1=male
            else:
                gender = str(gender_val).lower()

            # Minimum 1RM based on body weight
            if gender == 'female':
                min_reasonable = max(weight * 0.3, self.DOMAIN_THRESHOLDS['min_1rm_adult_female'])
            else:
                min_reasonable = max(weight * 0.4, self.DOMAIN_THRESHOLDS['min_1rm_adult_male'])

            # Maximum 1RM based on experience
            if exp <= 1:  # Beginner
                max_reasonable = min(weight * 1.5, self.DOMAIN_THRESHOLDS['max_1rm_beginner'])
            elif exp <= 2:  # Intermediate
                max_reasonable = min(weight * 2.0, 150)
            else:  # Advanced/Expert
                max_reasonable = min(weight * 2.5, self.DOMAIN_THRESHOLDS['max_1rm_advanced'])

            return min_reasonable <= row['estimated_1rm'] <= max_reasonable

        reasonable_mask = cleaned_data.apply(is_1rm_reasonable, axis=1)
        cleaned_data = cleaned_data[reasonable_mask]
        domain_outliers_removed = initial_count - zero_removed - near_zero_removed - statistical_outliers_removed - len(cleaned_data)

        self.cleaning_report['1rm_cleaning'] = {
            'zero_values_removed': zero_removed,
            'near_zero_removed': near_zero_removed,
            'statistical_outliers_removed': statistical_outliers_removed,
            'domain_outliers_removed': domain_outliers_removed,
            'total_removed': zero_removed + near_zero_removed + statistical_outliers_removed + domain_outliers_removed,
            'final_count': len(cleaned_data),
            'removal_rate': (zero_removed + near_zero_removed + statistical_outliers_removed + domain_outliers_removed) / initial_count
        }

        print(f"   • Zero values removed: {zero_removed}")
        print(f"   • Near-zero values removed: {near_zero_removed}")
        print(f"   • Statistical outliers removed: {statistical_outliers_removed}")
        print(f"   • Domain outliers removed: {domain_outliers_removed}")
        print(f"   • Total 1RM values removed: {self.cleaning_report['1rm_cleaning']['total_removed']} ({self.cleaning_report['1rm_cleaning']['removal_rate']:.1%})")

        return cleaned_data

    def clean_demographics(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Clean demographic data using domain rules
        """
        print("👥 Cleaning demographic data...")

        initial_count = len(data)
        cleaned_data = data.copy()

        # Remove invalid age
        age_mask = (cleaned_data['age'] >= self.DOMAIN_THRESHOLDS['min_age']) & \
                   (cleaned_data['age'] <= self.DOMAIN_THRESHOLDS['max_age'])
        cleaned_data = cleaned_data[age_mask]
        age_removed = initial_count - len(cleaned_data)

        # Remove invalid weight
        weight_mask = (cleaned_data['weight_kg'] >= self.DOMAIN_THRESHOLDS['min_weight_kg']) & \
                     (cleaned_data['weight_kg'] <= self.DOMAIN_THRESHOLDS['max_weight_kg'])
        cleaned_data = cleaned_data[weight_mask]
        weight_removed = initial_count - age_removed - len(cleaned_data)

        # Remove invalid height
        height_mask = (cleaned_data['height_m'] >= self.DOMAIN_THRESHOLDS['min_height_m']) & \
                      (cleaned_data['height_m'] <= self.DOMAIN_THRESHOLDS['max_height_m'])
        cleaned_data = cleaned_data[height_mask]
        height_removed = initial_count - age_removed - weight_removed - len(cleaned_data)

        # Remove invalid BMI
        bmi_mask = (cleaned_data['bmi'] >= self.DOMAIN_THRESHOLDS['min_bmi']) & \
                   (cleaned_data['bmi'] <= self.DOMAIN_THRESHOLDS['max_bmi'])
        cleaned_data = cleaned_data[bmi_mask]
        bmi_removed = initial_count - age_removed - weight_removed - height_removed - len(cleaned_data)

        # Remove invalid resting heart rate
        hr_mask = (cleaned_data['resting_heartrate'] >= self.DOMAIN_THRESHOLDS['min_resting_hr']) & \
                   (cleaned_data['resting_heartrate'] <= self.DOMAIN_THRESHOLDS['max_resting_hr'])
        cleaned_data = cleaned_data[hr_mask]
        hr_removed = initial_count - age_removed - weight_removed - height_removed - bmi_removed - len(cleaned_data)

        self.cleaning_report['demographics_cleaning'] = {
            'invalid_age_removed': age_removed,
            'invalid_weight_removed': weight_removed,
            'invalid_height_removed': height_removed,
            'invalid_bmi_removed': bmi_removed,
            'invalid_hr_removed': hr_removed,
            'total_removed': age_removed + weight_removed + height_removed + bmi_removed + hr_removed
        }

        print(f"   • Invalid ages removed: {age_removed}")
        print(f"   • Invalid weights removed: {weight_removed}")
        print(f"   • Invalid heights removed: {height_removed}")
        print(f"   • Invalid BMIs removed: {bmi_removed}")
        print(f"   • Invalid heart rates removed: {hr_removed}")

        return cleaned_data

    def handle_missing_values(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Handle missing values using appropriate strategies
        """
        print("🔧 Handling missing values...")

        cleaned_data = data.copy()
        missing_before = cleaned_data.isnull().sum().sum()

        # Strategy for different column types
        for col in cleaned_data.columns:
            if cleaned_data[col].isnull().sum() == 0:
                continue

            if col in ['gender']:
                # Categorical: use mode
                cleaned_data[col].fillna(cleaned_data[col].mode()[0], inplace=True)
            elif col in ['mood', 'fatigue', 'effort']:
                # SePA: use neutral default
                cleaned_data[col].fillna('Neutral', inplace=True)
            else:
                # Numerical: use median (more robust to outliers)
                cleaned_data[col].fillna(cleaned_data[col].median(), inplace=True)

        missing_after = cleaned_data.isnull().sum().sum()

        self.cleaning_report['missing_values'] = {
            'missing_before': missing_before,
            'missing_after': missing_after,
            'filled': missing_before - missing_after
        }

        print(f"   • Missing values before: {missing_before}")
        print(f"   • Missing values after: {missing_after}")

        return cleaned_data

    def apply_log_transformation(self, data: pd.DataFrame, columns: list = None) -> pd.DataFrame:
        """
        Apply log transformation to reduce skewness

        Args:
            data: Input dataframe
            columns: List of columns to transform (default: ['estimated_1rm'])
        """
        if columns is None:
            columns = ['estimated_1rm']

        print("📈 Applying log transformation...")

        transformed_data = data.copy()
        transformation_info = {}

        for col in columns:
            if col in transformed_data.columns:
                # Add small constant to avoid log(0)
                min_val = transformed_data[col].min()
                constant = max(1, abs(min_val) + 1)

                transformed_data[f'{col}_log'] = np.log(transformed_data[col] + constant)
                transformed_data[f'{col}_sqrt'] = np.sqrt(transformed_data[col])

                # Calculate skewness before and after
                original_skew = stats.skew(transformed_data[col].dropna())
                log_skew = stats.skew(transformed_data[f'{col}_log'].dropna())
                sqrt_skew = stats.skew(transformed_data[f'{col}_sqrt'].dropna())

                transformation_info[col] = {
                    'original_skew': original_skew,
                    'log_skew': log_skew,
                    'sqrt_skew': sqrt_skew,
                    'constant_added': constant,
                    'best_transformation': 'log' if abs(log_skew) < abs(sqrt_skew) else 'sqrt'
                }

                print(f"   • {col}: original skew={original_skew:.3f}, log skew={log_skew:.3f}, sqrt skew={sqrt_skew:.3f}")

        self.cleaning_report['transformations'] = transformation_info

        return transformed_data

    def visualize_cleaning_results(self):
        """Create visualizations of cleaning results"""
        print("📊 Creating cleaning visualizations...")

        if self.original_data is None or self.cleaned_data is None:
            print("❌ No data available for visualization")
            return

        fig, axes = plt.subplots(2, 3, figsize=(18, 12))
        fig.suptitle('Data Cleaning Results Comparison', fontsize=16, fontweight='bold')

        # 1RM Distribution Comparison
        ax1 = axes[0, 0]
        ax1.hist(self.original_data['estimated_1rm'], bins=50, alpha=0.7, label='Original', color='red', density=True)
        ax1.hist(self.cleaned_data['estimated_1rm'], bins=50, alpha=0.7, label='Cleaned', color='blue', density=True)
        ax1.set_xlabel('1RM (kg)')
        ax1.set_ylabel('Density')
        ax1.set_title('1RM Distribution Before/After Cleaning')
        ax1.legend()
        ax1.grid(True, alpha=0.3)

        # Age Distribution
        ax2 = axes[0, 1]
        ax2.hist(self.original_data['age'], bins=30, alpha=0.7, label='Original', color='red', density=True)
        ax2.hist(self.cleaned_data['age'], bins=30, alpha=0.7, label='Cleaned', color='blue', density=True)
        ax2.set_xlabel('Age (years)')
        ax2.set_ylabel('Density')
        ax2.set_title('Age Distribution Before/After Cleaning')
        ax2.legend()
        ax2.grid(True, alpha=0.3)

        # BMI Distribution
        ax3 = axes[0, 2]
        ax3.hist(self.original_data['bmi'], bins=30, alpha=0.7, label='Original', color='red', density=True)
        ax3.hist(self.cleaned_data['bmi'], bins=30, alpha=0.7, label='Cleaned', color='blue', density=True)
        ax3.set_xlabel('BMI (kg/m²)')
        ax3.set_ylabel('Density')
        ax3.set_title('BMI Distribution Before/After Cleaning')
        ax3.legend()
        ax3.grid(True, alpha=0.3)

        # Box Plot Comparison
        ax4 = axes[1, 0]
        original_1rm = self.original_data['estimated_1rm'].dropna()
        cleaned_1rm = self.cleaned_data['estimated_1rm'].dropna()

        box_data = [original_1rm, cleaned_1rm]
        bp = ax4.boxplot(box_data, labels=['Original', 'Cleaned'], patch_artist=True)
        bp['boxes'][0].set_facecolor('lightcoral')
        bp['boxes'][1].set_facecolor('lightblue')
        ax4.set_ylabel('1RM (kg)')
        ax4.set_title('1RM Box Plot Comparison')
        ax4.grid(True, alpha=0.3)

        # Data Size Comparison
        ax5 = axes[1, 1]
        categories = ['Original', 'After 1RM Cleaning', 'After Demographics', 'Final']
        counts = [len(self.original_data),
                  len(self.original_data) - self.cleaning_report.get('1rm_cleaning', {}).get('total_removed', 0),
                  len(self.original_data) - self.cleaning_report.get('demographics_cleaning', {}).get('total_removed', 0),
                  len(self.cleaned_data)]

        bars = ax5.bar(categories, counts, color=['red', 'orange', 'yellow', 'green'], alpha=0.7)
        ax5.set_ylabel('Number of Samples')
        ax5.set_title('Data Retention Throughout Cleaning')
        ax5.grid(True, alpha=0.3)

        # Add value labels on bars
        for bar, count in zip(bars, counts):
            ax5.text(bar.get_x() + bar.get_width()/2, bar.get_height() + max(counts)*0.01,
                    f'{count}', ha='center', va='bottom')

        # Quality Metrics Summary
        ax6 = axes[1, 2]
        ax6.axis('off')

        original_stats = self.analyze_data_quality(self.original_data)
        cleaned_stats = self.analyze_data_quality(self.cleaned_data)

        summary_text = f"""
        DATA QUALITY SUMMARY

        Original Data:
        • Total samples: {original_stats['total_rows']:,}
        • Zero 1RM values: {original_stats['zero_1rm_count']}
        • Near-zero 1RM: {original_stats['near_zero_1rm_count']}
        • Mean 1RM: {original_stats['1rm_stats']['mean']:.1f} kg
        • 1RM Std: {original_stats['1rm_stats']['std']:.1f} kg
        • 1RM Range: [{original_stats['1rm_stats']['min']:.1f}, {original_stats['1rm_stats']['max']:.1f}]

        Cleaned Data:
        • Total samples: {cleaned_stats['total_rows']:,}
        • Data retained: {len(self.cleaned_data)/len(self.original_data):.1%}
        • Mean 1RM: {cleaned_stats['1rm_stats']['mean']:.1f} kg
        • 1RM Std: {cleaned_stats['1rm_stats']['std']:.1f} kg
        • 1RM Range: [{cleaned_stats['1rm_stats']['min']:.1f}, {cleaned_stats['1rm_stats']['max']:.1f}]
        """

        ax6.text(0.05, 0.95, summary_text, transform=ax6.transAxes, fontsize=10,
                verticalalignment='top', fontfamily='monospace',
                bbox=dict(boxstyle="round,pad=0.5", facecolor="lightgray", alpha=0.8))

        plt.tight_layout()

        # Save visualization
        output_path = self.data_path.parent / "cleaning_results.png"
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
        plt.close()

        print(f"   • Visualization saved: {output_path}")

    def run_complete_cleaning(self) -> pd.DataFrame:
        """
        Run the complete cleaning pipeline
        """
        print("Starting complete data cleaning pipeline...")
        print("=" * 60)

        if not self.load_data():
            return None

        # Analyze original data
        print("\n📋 Original Data Analysis:")
        original_analysis = self.analyze_data_quality(self.original_data)
        print(f"   • Total samples: {original_analysis['total_rows']:,}")
        print(f"   • Zero 1RM values: {original_analysis['zero_1rm_count']}")
        print(f"   • Near-zero 1RM values: {original_analysis['near_zero_1rm_count']}")
        print(f"   • 1RM Statistics: mean={original_analysis['1rm_stats']['mean']:.1f}, "
              f"std={original_analysis['1rm_stats']['std']:.1f}")
        print(f"   • Missing values: {original_analysis['missing_values']}")

        # Step 1: Clean 1RM values
        self.cleaned_data = self.remove_invalid_1rm_values(self.original_data)

        # Step 2: Clean demographics
        self.cleaned_data = self.clean_demographics(self.cleaned_data)

        # Step 3: Handle missing values
        self.cleaned_data = self.handle_missing_values(self.cleaned_data)

        # Step 4: Apply transformations
        self.cleaned_data = self.apply_log_transformation(self.cleaned_data)

        # Final analysis
        print("\n📊 Final Cleaned Data Analysis:")
        cleaned_analysis = self.analyze_data_quality(self.cleaned_data)
        print(f"   • Total samples: {cleaned_analysis['total_rows']:,}")
        print(f"   • Data retention rate: {len(self.cleaned_data)/len(self.original_data):.1%}")
        print(f"   • 1RM Statistics: mean={cleaned_analysis['1rm_stats']['mean']:.1f}, "
              f"std={cleaned_analysis['1rm_stats']['std']:.1f}")
        print(f"   • Missing values: {cleaned_analysis['missing_values']}")

        # Generate visualizations
        self.visualize_cleaning_results()

        # Save cleaned data
        output_path = self.data_path.parent / "enhanced_gym_member_exercise_tracking_10k_cleaned.xlsx"
        self.cleaned_data.to_excel(output_path, index=False)
        print(f"\n💾 Cleaned data saved: {output_path}")

        # Save cleaning report
        report_path = self.data_path.parent / "cleaning_report.json"
        with open(report_path, 'w') as f:
            json.dump(self.cleaning_report, f, indent=2)
        print(f"📄 Cleaning report saved: {report_path}")

        print(f"\nData cleaning completed successfully!")
        print(f"   • Original samples: {len(self.original_data):,}")
        print(f"   • Final samples: {len(self.cleaned_data):,}")
        print(f"   • Data retained: {len(self.cleaned_data)/len(self.original_data):.1%}")

        return self.cleaned_data


def main():
    """Main function to run data cleaning"""
    import argparse

    parser = argparse.ArgumentParser(description='V3 Data Cleaning Pipeline')
    parser.add_argument('--input', type=str,
                       default='./data/enhanced_gym_member_exercise_tracking_10k.xlsx',
                       help='Input data file path')

    args = parser.parse_args()

    try:
        cleaner = V3DataCleaner(args.input)
        cleaned_data = cleaner.run_complete_cleaning()

        if cleaned_data is not None:
            print(f"\n🎉 Data cleaning completed successfully!")
            print(f"📊 Check the generated visualizations and reports.")

    except Exception as e:
        print(f"Error during data cleaning: {e}")
        raise


if __name__ == "__main__":
    main()