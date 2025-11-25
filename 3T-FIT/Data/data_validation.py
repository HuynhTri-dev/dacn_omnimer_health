"""
Data Validation Script for Training and Test Datasets
========================================================

This script validates the training and test datasets against the requirements
specified in README.md and Strategy_Analysis.md.

It checks:
1. Data schema compatibility
2. Required fields presence
3. Data quality metrics
4. Suitability for training requirements
5. Statistical distributions
"""

import pandas as pd
import numpy as np
import json
from pathlib import Path
from typing import Dict, List, Tuple
import warnings
warnings.filterwarnings('ignore')


class DataValidator:
    """Validator for gym training datasets"""
    
    # Required fields based on README.md and Strategy_Analysis.md
    REQUIRED_FIELDS = [
        'exercise_name', 'duration_min', 'avg_hr', 'max_hr', 'calories',
        'fatigue', 'effort', 'mood', 'suitability_x',
        'age', 'height_m', 'weight_kg', 'bmi', 'fat_percentage',
        'resting_heartrate', 'experience_level', 'workout_frequency',
        'health_status', 'workout_type', 'gender', 'session_duration'
    ]
    
    # Strategy-specific fields (from Strategy_Analysis.md)
    STRATEGY_FIELDS = {
        'strength': ['estimated_1rm', 'intensity_score', 'rest_period'],
        'cardio': ['pace', 'intensity_score'],
        'general': ['duration_capacity', 'intensity_score']
    }
    
    # Valid workout types
    VALID_WORKOUT_TYPES = ['Strength', 'Cardio', 'HIIT', 'Yoga', 'Walking', 'Cycling', 'Swimming']
    
    # SePA fields (mood, fatigue, effort)
    SEPA_FIELDS = ['mood', 'fatigue', 'effort']
    
    def __init__(self, training_file: str, test_file: str):
        """Initialize validator with file paths"""
        self.training_file = training_file
        self.test_file = test_file
        self.training_df = None
        self.test_df = None
        self.validation_results = {
            'training': {},
            'test': {},
            'compatibility': {},
            'recommendations': []
        }
        
    def load_data(self) -> bool:
        """Load training and test datasets"""
        try:
            print("=" * 80)
            print("LOADING DATASETS")
            print("=" * 80)
            
            print(f"\n[1/2] Loading training data: {self.training_file}")
            self.training_df = pd.read_excel(self.training_file)
            print(f"  ✓ Loaded {len(self.training_df):,} records")
            print(f"  ✓ Columns: {len(self.training_df.columns)}")
            
            print(f"\n[2/2] Loading test data: {self.test_file}")
            self.test_df = pd.read_excel(self.test_file)
            print(f"  ✓ Loaded {len(self.test_df):,} records")
            print(f"  ✓ Columns: {len(self.test_df.columns)}")
            
            return True
            
        except Exception as e:
            print(f"\n✗ ERROR loading data: {e}")
            return False
    
    def validate_schema(self, df: pd.DataFrame, dataset_name: str) -> Dict:
        """Validate dataset schema against requirements"""
        results = {
            'dataset': dataset_name,
            'total_columns': len(df.columns),
            'total_rows': len(df),
            'missing_required_fields': [],
            'extra_fields': [],
            'field_coverage': 0.0,
            'status': 'PASS'
        }
        
        # Check for missing required fields
        for field in self.REQUIRED_FIELDS:
            if field not in df.columns:
                results['missing_required_fields'].append(field)
                results['status'] = 'FAIL'
        
        # Calculate field coverage
        present_fields = [f for f in self.REQUIRED_FIELDS if f in df.columns]
        results['field_coverage'] = (len(present_fields) / len(self.REQUIRED_FIELDS)) * 100
        
        # Identify extra fields (not necessarily bad)
        results['extra_fields'] = [col for col in df.columns if col not in self.REQUIRED_FIELDS]
        
        return results
    
    def validate_data_quality(self, df: pd.DataFrame, dataset_name: str) -> Dict:
        """Validate data quality metrics"""
        results = {
            'dataset': dataset_name,
            'null_percentages': {},
            'data_ranges': {},
            'invalid_values': {},
            'quality_score': 0.0,
            'issues': []
        }
        
        # Check null values
        for col in df.columns:
            null_pct = (df[col].isnull().sum() / len(df)) * 100
            if null_pct > 0:
                results['null_percentages'][col] = round(null_pct, 2)
                if null_pct > 20:
                    results['issues'].append(f"High null rate in '{col}': {null_pct:.1f}%")
        
        # Validate numeric ranges
        numeric_validations = {
            'age': (10, 100),
            'weight_kg': (30, 200),
            'height_m': (1.2, 2.5),
            'bmi': (10, 50),
            'avg_hr': (40, 220),
            'max_hr': (50, 220),
            'calories': (0, 2000),
            'duration_min': (1, 300),
            'experience_level': (1, 4),
            'workout_frequency': (1, 7)
        }
        
        for field, (min_val, max_val) in numeric_validations.items():
            if field in df.columns:
                valid_data = df[field].dropna()
                if len(valid_data) > 0:
                    out_of_range = ((valid_data < min_val) | (valid_data > max_val)).sum()
                    if out_of_range > 0:
                        pct = (out_of_range / len(valid_data)) * 100
                        results['invalid_values'][field] = {
                            'count': int(out_of_range),
                            'percentage': round(pct, 2),
                            'expected_range': f"{min_val}-{max_val}",
                            'actual_range': f"{valid_data.min():.1f}-{valid_data.max():.1f}"
                        }
                        if pct > 5:
                            results['issues'].append(
                                f"'{field}' has {pct:.1f}% values outside expected range {min_val}-{max_val}"
                            )
        
        # Calculate overall quality score
        total_checks = len(self.REQUIRED_FIELDS)
        passed_checks = total_checks - len(results['issues'])
        results['quality_score'] = (passed_checks / total_checks) * 100
        
        return results
    
    def validate_workout_distribution(self, df: pd.DataFrame, dataset_name: str) -> Dict:
        """Validate workout type distribution"""
        results = {
            'dataset': dataset_name,
            'workout_distribution': {},
            'exercise_diversity': 0,
            'avg_exercises_per_session': 0.0,
            'strength_metrics': {},
            'cardio_metrics': {},
            'recommendations': []
        }
        
        if 'workout_type' in df.columns:
            # Workout type distribution
            workout_counts = df['workout_type'].value_counts()
            total = len(df)
            for workout_type, count in workout_counts.items():
                results['workout_distribution'][workout_type] = {
                    'count': int(count),
                    'percentage': round((count / total) * 100, 2)
                }
            
            # Check if distribution aligns with README.md recommendations
            strength_pct = (df['workout_type'] == 'Strength').mean() * 100
            if strength_pct < 40:
                results['recommendations'].append(
                    f"Strength workouts are {strength_pct:.1f}% of data. "
                    "README.md suggests 40-60% for balanced training."
                )
        
        # Exercise diversity
        if 'exercise_name' in df.columns:
            results['exercise_diversity'] = df['exercise_name'].nunique()
            
            # Strength-specific metrics
            strength_df = df[df['workout_type'] == 'Strength']
            if len(strength_df) > 0:
                if 'estimated_1rm' in strength_df.columns:
                    results['strength_metrics'] = {
                        'avg_1rm': round(strength_df['estimated_1rm'].mean(), 2),
                        'min_1rm': round(strength_df['estimated_1rm'].min(), 2),
                        'max_1rm': round(strength_df['estimated_1rm'].max(), 2),
                        'std_1rm': round(strength_df['estimated_1rm'].std(), 2)
                    }
                
                # Check exercises per strength session
                if 'session_duration' in strength_df.columns:
                    # Group by session and count exercises
                    exercises_per_session = strength_df.groupby('session_duration').size()
                    avg_exercises = exercises_per_session.mean()
                    results['avg_exercises_per_session'] = round(avg_exercises, 1)
                    
                    # Validate against README.md recommendations (4-8 exercises)
                    if avg_exercises < 4:
                        results['recommendations'].append(
                            f"Average {avg_exercises:.1f} exercises per strength session. "
                            "README.md recommends 4-8 exercises for optimal hypertrophy/strength."
                        )
                    elif avg_exercises > 8:
                        results['recommendations'].append(
                            f"Average {avg_exercises:.1f} exercises per strength session. "
                            "This may be too many; README.md recommends 4-8 exercises."
                        )
            
            # Cardio-specific metrics
            cardio_df = df[df['workout_type'].isin(['Cardio', 'HIIT', 'Running', 'Cycling'])]
            if len(cardio_df) > 0 and 'pace' in cardio_df.columns:
                results['cardio_metrics'] = {
                    'avg_pace': round(cardio_df['pace'].mean(), 2),
                    'min_pace': round(cardio_df['pace'].min(), 2),
                    'max_pace': round(cardio_df['pace'].max(), 2)
                }
        
        return results
    
    def validate_sepa_integration(self, df: pd.DataFrame, dataset_name: str) -> Dict:
        """Validate SePA (mood, fatigue, effort) fields"""
        results = {
            'dataset': dataset_name,
            'sepa_fields_present': [],
            'sepa_distributions': {},
            'readiness_analysis': {},
            'status': 'PASS'
        }
        
        # Check presence of SePA fields
        for field in self.SEPA_FIELDS:
            if field in df.columns:
                results['sepa_fields_present'].append(field)
                
                # Analyze distribution
                value_counts = df[field].value_counts()
                total = df[field].notna().sum()
                distribution = {}
                for value, count in value_counts.items():
                    distribution[str(value)] = {
                        'count': int(count),
                        'percentage': round((count / total) * 100, 2)
                    }
                results['sepa_distributions'][field] = distribution
        
        # Check if all SePA fields are present
        missing_sepa = [f for f in self.SEPA_FIELDS if f not in df.columns]
        if missing_sepa:
            results['status'] = 'PARTIAL'
            results['missing_fields'] = missing_sepa
        
        # Analyze readiness patterns (from Strategy_Analysis.md)
        if all(f in df.columns for f in self.SEPA_FIELDS):
            # Count high fatigue cases
            high_fatigue = df[df['fatigue'].astype(str).str.contains('High|Very High', case=False, na=False)]
            results['readiness_analysis']['high_fatigue_percentage'] = round(
                (len(high_fatigue) / len(df)) * 100, 2
            )
            
            # Count poor mood cases
            poor_mood = df[df['mood'].astype(str).str.contains('Bad|Very Bad', case=False, na=False)]
            results['readiness_analysis']['poor_mood_percentage'] = round(
                (len(poor_mood) / len(df)) * 100, 2
            )
        
        return results
    
    def validate_strategy_compliance(self, df: pd.DataFrame, dataset_name: str) -> Dict:
        """Validate compliance with Strategy_Analysis.md requirements"""
        results = {
            'dataset': dataset_name,
            'strategy_compliance': {},
            'missing_strategy_fields': [],
            'compliance_score': 0.0,
            'issues': []
        }
        
        # Check for 1RM estimation (key requirement from Strategy_Analysis.md)
        strength_df = df[df['workout_type'] == 'Strength']
        if len(strength_df) > 0:
            if 'estimated_1rm' in strength_df.columns:
                has_1rm = strength_df['estimated_1rm'].notna().sum()
                total_strength = len(strength_df)
                pct = (has_1rm / total_strength) * 100
                results['strategy_compliance']['1rm_estimation'] = {
                    'present': True,
                    'coverage': round(pct, 2),
                    'status': 'PASS' if pct > 90 else 'PARTIAL'
                }
                if pct < 90:
                    results['issues'].append(
                        f"Only {pct:.1f}% of strength exercises have 1RM estimates. "
                        "Strategy_Analysis.md requires 1RM for all strength exercises."
                    )
            else:
                results['strategy_compliance']['1rm_estimation'] = {
                    'present': False,
                    'status': 'FAIL'
                }
                results['missing_strategy_fields'].append('estimated_1rm')
                results['issues'].append(
                    "Missing 'estimated_1rm' field for strength exercises. "
                    "This is CRITICAL per Strategy_Analysis.md."
                )
        
        # Check for intensity scoring
        if 'intensity_score' in df.columns:
            has_intensity = df['intensity_score'].notna().sum()
            pct = (has_intensity / len(df)) * 100
            results['strategy_compliance']['intensity_scoring'] = {
                'present': True,
                'coverage': round(pct, 2),
                'status': 'PASS' if pct > 90 else 'PARTIAL'
            }
        else:
            results['missing_strategy_fields'].append('intensity_score')
            results['issues'].append("Missing 'intensity_score' field.")
        
        # Check for suitability scoring
        if 'suitability_x' in df.columns:
            has_suitability = df['suitability_x'].notna().sum()
            pct = (has_suitability / len(df)) * 100
            results['strategy_compliance']['suitability_scoring'] = {
                'present': True,
                'coverage': round(pct, 2),
                'range': f"{df['suitability_x'].min():.2f} - {df['suitability_x'].max():.2f}",
                'mean': round(df['suitability_x'].mean(), 2),
                'status': 'PASS' if pct > 90 else 'PARTIAL'
            }
        else:
            results['missing_strategy_fields'].append('suitability_x')
            results['issues'].append("Missing 'suitability_x' field for exercise suitability scoring.")
        
        # Calculate compliance score
        total_checks = 3  # 1RM, intensity, suitability
        passed_checks = sum(1 for k, v in results['strategy_compliance'].items() 
                          if v.get('status') == 'PASS')
        results['compliance_score'] = (passed_checks / total_checks) * 100
        
        return results
    
    def check_compatibility(self) -> Dict:
        """Check compatibility between training and test datasets"""
        results = {
            'schema_match': False,
            'column_differences': {
                'training_only': [],
                'test_only': [],
                'common': []
            },
            'data_distribution_similarity': {},
            'recommendations': []
        }
        
        # Compare columns
        train_cols = set(self.training_df.columns)
        test_cols = set(self.test_df.columns)
        
        results['column_differences']['training_only'] = list(train_cols - test_cols)
        results['column_differences']['test_only'] = list(test_cols - train_cols)
        results['column_differences']['common'] = list(train_cols & test_cols)
        
        results['schema_match'] = len(results['column_differences']['training_only']) == 0 and \
                                 len(results['column_differences']['test_only']) == 0
        
        if not results['schema_match']:
            results['recommendations'].append(
                "Training and test datasets have different schemas. "
                "Ensure all required fields are present in both datasets."
            )
        
        # Compare data distributions for common numeric fields
        common_numeric = ['age', 'weight_kg', 'bmi', 'avg_hr', 'calories']
        for field in common_numeric:
            if field in self.training_df.columns and field in self.test_df.columns:
                train_mean = self.training_df[field].mean()
                test_mean = self.test_df[field].mean()
                diff_pct = abs(train_mean - test_mean) / train_mean * 100 if train_mean != 0 else 0
                
                results['data_distribution_similarity'][field] = {
                    'training_mean': round(train_mean, 2),
                    'test_mean': round(test_mean, 2),
                    'difference_pct': round(diff_pct, 2),
                    'status': 'SIMILAR' if diff_pct < 20 else 'DIFFERENT'
                }
                
                if diff_pct > 30:
                    results['recommendations'].append(
                        f"Large distribution difference in '{field}': {diff_pct:.1f}%. "
                        "This may affect model generalization."
                    )
        
        return results
    
    def generate_report(self) -> Dict:
        """Generate comprehensive validation report"""
        print("\n" + "=" * 80)
        print("VALIDATING DATASETS")
        print("=" * 80)
        
        # Schema validation
        print("\n[1/6] Schema Validation...")
        self.validation_results['training']['schema'] = self.validate_schema(
            self.training_df, 'Training'
        )
        self.validation_results['test']['schema'] = self.validate_schema(
            self.test_df, 'Test'
        )
        
        # Data quality validation
        print("[2/6] Data Quality Validation...")
        self.validation_results['training']['quality'] = self.validate_data_quality(
            self.training_df, 'Training'
        )
        self.validation_results['test']['quality'] = self.validate_data_quality(
            self.test_df, 'Test'
        )
        
        # Workout distribution validation
        print("[3/6] Workout Distribution Validation...")
        self.validation_results['training']['workout_dist'] = self.validate_workout_distribution(
            self.training_df, 'Training'
        )
        self.validation_results['test']['workout_dist'] = self.validate_workout_distribution(
            self.test_df, 'Test'
        )
        
        # SePA integration validation
        print("[4/6] SePA Integration Validation...")
        self.validation_results['training']['sepa'] = self.validate_sepa_integration(
            self.training_df, 'Training'
        )
        self.validation_results['test']['sepa'] = self.validate_sepa_integration(
            self.test_df, 'Test'
        )
        
        # Strategy compliance validation
        print("[5/6] Strategy Compliance Validation...")
        self.validation_results['training']['strategy'] = self.validate_strategy_compliance(
            self.training_df, 'Training'
        )
        self.validation_results['test']['strategy'] = self.validate_strategy_compliance(
            self.test_df, 'Test'
        )
        
        # Compatibility check
        print("[6/6] Compatibility Check...")
        self.validation_results['compatibility'] = self.check_compatibility()
        
        # Generate recommendations
        self._generate_recommendations()
        
        return self.validation_results
    
    def _generate_recommendations(self):
        """Generate overall recommendations"""
        recommendations = []
        
        # Check training data quality
        train_quality = self.validation_results['training']['quality']['quality_score']
        if train_quality < 80:
            recommendations.append({
                'priority': 'HIGH',
                'category': 'Data Quality',
                'message': f"Training data quality score is {train_quality:.1f}%. "
                          "Address data quality issues before training."
            })
        
        # Check strategy compliance
        train_compliance = self.validation_results['training']['strategy']['compliance_score']
        if train_compliance < 100:
            recommendations.append({
                'priority': 'CRITICAL',
                'category': 'Strategy Compliance',
                'message': f"Training data strategy compliance is {train_compliance:.1f}%. "
                          "Missing fields required by Strategy_Analysis.md."
            })
        
        # Check schema compatibility
        if not self.validation_results['compatibility']['schema_match']:
            recommendations.append({
                'priority': 'HIGH',
                'category': 'Schema Compatibility',
                'message': "Training and test datasets have different schemas. "
                          "Align schemas before model training."
            })
        
        self.validation_results['recommendations'] = recommendations
    
    def print_summary(self):
        """Print validation summary to console"""
        print("\n" + "=" * 80)
        print("VALIDATION SUMMARY")
        print("=" * 80)
        
        # Training dataset summary
        print("\n📊 TRAINING DATASET")
        print("-" * 80)
        train_schema = self.validation_results['training']['schema']
        train_quality = self.validation_results['training']['quality']
        train_strategy = self.validation_results['training']['strategy']
        
        print(f"  Records: {train_schema['total_rows']:,}")
        print(f"  Columns: {train_schema['total_columns']}")
        print(f"  Field Coverage: {train_schema['field_coverage']:.1f}%")
        print(f"  Quality Score: {train_quality['quality_score']:.1f}%")
        print(f"  Strategy Compliance: {train_strategy['compliance_score']:.1f}%")
        
        if train_schema['missing_required_fields']:
            print(f"  ⚠ Missing Required Fields: {', '.join(train_schema['missing_required_fields'])}")
        
        if train_quality['issues']:
            print(f"  ⚠ Quality Issues: {len(train_quality['issues'])}")
            for issue in train_quality['issues'][:3]:
                print(f"    - {issue}")
        
        # Test dataset summary
        print("\n📊 TEST DATASET")
        print("-" * 80)
        test_schema = self.validation_results['test']['schema']
        test_quality = self.validation_results['test']['quality']
        test_strategy = self.validation_results['test']['strategy']
        
        print(f"  Records: {test_schema['total_rows']:,}")
        print(f"  Columns: {test_schema['total_columns']}")
        print(f"  Field Coverage: {test_schema['field_coverage']:.1f}%")
        print(f"  Quality Score: {test_quality['quality_score']:.1f}%")
        print(f"  Strategy Compliance: {test_strategy['compliance_score']:.1f}%")
        
        if test_schema['missing_required_fields']:
            print(f"  ⚠ Missing Required Fields: {', '.join(test_schema['missing_required_fields'])}")
        
        # Compatibility
        print("\n🔗 COMPATIBILITY")
        print("-" * 80)
        compat = self.validation_results['compatibility']
        print(f"  Schema Match: {'✓ YES' if compat['schema_match'] else '✗ NO'}")
        
        if not compat['schema_match']:
            if compat['column_differences']['training_only']:
                print(f"  Training-only columns: {', '.join(compat['column_differences']['training_only'][:5])}")
            if compat['column_differences']['test_only']:
                print(f"  Test-only columns: {', '.join(compat['column_differences']['test_only'][:5])}")
        
        # Recommendations
        if self.validation_results['recommendations']:
            print("\n💡 RECOMMENDATIONS")
            print("-" * 80)
            for i, rec in enumerate(self.validation_results['recommendations'], 1):
                print(f"  {i}. [{rec['priority']}] {rec['category']}")
                print(f"     {rec['message']}")
        
        # Overall verdict
        print("\n" + "=" * 80)
        overall_pass = (
            train_quality['quality_score'] >= 80 and
            train_strategy['compliance_score'] >= 80 and
            compat['schema_match']
        )
        
        if overall_pass:
            print("✅ VERDICT: DATASETS ARE SUITABLE FOR TRAINING")
        else:
            print("⚠️  VERDICT: DATASETS NEED IMPROVEMENTS BEFORE TRAINING")
        print("=" * 80)
    
    def save_report(self, output_file: str):
        """Save validation report to JSON file"""
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(self.validation_results, f, indent=2, ensure_ascii=False)
        print(f"\n📄 Detailed report saved to: {output_file}")


def main():
    """Main execution function"""
    # File paths
    training_file = './preprocessing_data/enhanced_gym_member_exercise_tracking_10k.xlsx'
    test_file = './preprocessing_data/test_dataset.xlsx'
    output_report = './preprocessing_data/data_validation_report.json'
    
    # Create validator
    validator = DataValidator(training_file, test_file)
    
    # Load data
    if not validator.load_data():
        return
    
    # Generate validation report
    validator.generate_report()
    
    # Print summary
    validator.print_summary()
    
    # Save detailed report
    validator.save_report(output_report)
    
    print("\n✓ Validation complete!")


if __name__ == "__main__":
    main()
