"""
target_transformation.py
Advanced target transformation techniques for improving model performance

This script implements various transformations to handle:
1. Log transformation for skewed distributions
2. Box-Cox transformation for optimal power transforms
3. Yeo-Johnson transformation for negative/zero values
4. Quantile transformation for non-linear distributions
5. Custom domain-specific transformations

Author: Claude Code Assistant
Date: 2025-11-27
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
from scipy.stats import boxcox, yeojohnson
from sklearn.preprocessing import QuantileTransformer, PowerTransformer
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.model_selection import train_test_split
from sklearn.linear_model import Ridge, LinearRegression
from sklearn.ensemble import RandomForestRegressor
import torch
import torch.nn as nn
import torch.optim as optim
from pathlib import Path
import json
import warnings
warnings.filterwarnings('ignore')

class TargetTransformer:
    """Advanced target transformation for regression tasks"""

    def __init__(self, target_column: str = 'estimated_1rm'):
        """
        Initialize target transformer

        Args:
            target_column: Name of the target column to transform
        """
        self.target_column = target_column
        self.transformations = {}
        self.scalers = {}
        self.best_transformation = None
        self.transformation_results = {}

    def analyze_target_distribution(self, y: pd.Series) -> dict:
        """
        Comprehensive analysis of target distribution

        Returns:
            Dictionary with distribution statistics
        """
        analysis = {
            'count': len(y),
            'mean': y.mean(),
            'std': y.std(),
            'min': y.min(),
            'max': y.max(),
            'median': y.median(),
            'q25': y.quantile(0.25),
            'q75': y.quantile(0.75),
            'iqr': y.quantile(0.75) - y.quantile(0.25),
            'skewness': stats.skew(y.dropna()),
            'kurtosis': stats.kurtosis(y.dropna()),
            'cv': y.std() / y.mean() if y.mean() != 0 else float('inf'),
            'zero_count': (y == 0).sum(),
            'near_zero_count': (y < 5).sum(),
            'positive_count': (y > 0).sum(),
            'negative_count': (y < 0).sum()
        }

        # Distribution tests
        if analysis['positive_count'] > 0:
            y_pos = y[y > 0]
            if len(y_pos) > 0:
                try:
                    _, p_value_normal = stats.normaltest(y_pos)
                    analysis['normality_p_value'] = p_value_normal
                    analysis['is_normal'] = p_value_normal > 0.05
                except:
                    analysis['normality_p_value'] = 0
                    analysis['is_normal'] = False

        # Transformation recommendations
        analysis['transformations_recommended'] = []

        if analysis['skewness'] > 1.0:
            analysis['transformations_recommended'].append('log')
            analysis['transformations_recommended'].append('boxcox')
            analysis['transformations_recommended'].append('yeojohnson')

        if analysis['kurtosis'] > 3.0:
            analysis['transformations_recommended'].append('boxcox')
            analysis['transformations_recommended'].append('quantile')

        if analysis['zero_count'] > len(y) * 0.1:
            analysis['transformations_recommended'].append('log1p')
            analysis['transformations_recommended'].append('sqrt')

        if analysis['cv'] > 0.5:
            analysis['transformations_recommended'].append('robust_scaling')

        return analysis

    def log_transformation(self, y: pd.Series, method: str = 'log1p') -> pd.Series:
        """
        Apply logarithmic transformation

        Args:
            y: Target series
            method: 'log1p' (log(1+y)), 'log', or 'safe_log'

        Returns:
            Transformed series
        """
        if method == 'log1p':
            return np.log1p(y.clip(lower=0))
        elif method == 'safe_log':
            # Add small constant to avoid log(0)
            min_val = y.min()
            if min_val <= 0:
                constant = 1.0 - min_val + 1e-8
                return np.log(y + constant)
            else:
                return np.log(y)
        elif method == 'log':
            return np.log(y.clip(lower=1e-8))
        else:
            raise ValueError(f"Unknown log transformation method: {method}")

    def power_transformation(self, y: pd.Series, method: str = 'boxcox') -> tuple:
        """
        Apply power transformation

        Args:
            y: Target series
            method: 'boxcox', 'yeojohnson', or 'sklearn_power'

        Returns:
            Tuple of (transformed_series, lambda_parameter)
        """
        y_clean = y.dropna()

        if method == 'boxcox':
            if (y_clean <= 0).any():
                # Add constant to make all positive
                constant = abs(y_clean.min()) + 1
                y_shifted = y_clean + constant
                transformed, lambda_param = boxcox(y_shifted)
                return pd.Series(transformed, index=y_clean.index), lambda_param, constant
            else:
                transformed, lambda_param = boxcox(y_clean)
                return pd.Series(transformed, index=y_clean.index), lambda_param, 0

        elif method == 'yeojohnson':
            try:
                transformed, lambda_param = yeojohnson(y_clean)
                return pd.Series(transformed, index=y_clean.index), lambda_param, 0
            except:
                # Fallback to log if yeo-johnson fails
                return self.log_transformation(y, 'log1p'), 0, 0

        elif method == 'sklearn_power':
            transformer = PowerTransformer(method='yeo-johnson', standardize=True)
            transformed = transformer.fit_transform(y_clean.values.reshape(-1, 1)).flatten()
            return pd.Series(transformed, index=y_clean.index), transformer, 0

        else:
            raise ValueError(f"Unknown power transformation method: {method}")

    def quantile_transformation(self, y: pd.Series, n_quantiles: int = 1000,
                               output_distribution: str = 'normal') -> tuple:
        """
        Apply quantile transformation

        Args:
            y: Target series
            n_quantiles: Number of quantiles to use
            output_distribution: 'normal' or 'uniform'

        Returns:
            Tuple of (transformed_series, transformer_object)
        """
        transformer = QuantileTransformer(
            n_quantiles=n_quantiles,
            output_distribution=output_distribution,
            random_state=42
        )

        y_clean = y.dropna().values.reshape(-1, 1)
        transformed = transformer.fit_transform(y_clean).flatten()

        return pd.Series(transformed, index=y.dropna().index), transformer

    def domain_specific_transformation(self, y: pd.Series, features: pd.DataFrame) -> pd.Series:
        """
        Apply domain-specific transformation for 1RM

        Uses knowledge from exercise science:
        - 1RM scales non-linearly with body weight
        - Experience levels have diminishing returns
        - Age affects strength non-linearly
        """
        try:
            # Extract relevant features
            weight = features['weight_kg'] if 'weight_kg' in features.columns else 70
            age = features['age'] if 'age' in features.columns else 30
            experience = features['experience_level'] if 'experience_level' in features.columns else 2

            # Body weight scaling (strength ~ weight^0.67 for compound movements)
            if weight > 0:
                weight_factor = np.power(weight, 2/3)  # Approximate for compound lifts
            else:
                weight_factor = 1

            # Age factor (strength peaks around 30-35, declines after)
            age_factor = np.where(age <= 30,
                               age / 30,
                               np.where(age <= 50,
                                        1.0 - (age - 30) * 0.01,
                                        0.8 - (age - 50) * 0.005))

            # Experience factor (diminishing returns)
            exp_factor = np.where(experience == 1, 0.7,
                               np.where(experience == 2, 0.85,
                                        np.where(experience == 3, 1.0, 1.1)))

            # Combine factors
            scaling_factor = weight_factor * age_factor * exp_factor

            # Transform 1RM relative to scaling factors
            transformed = y / scaling_factor

            # Log transform to handle skewness
            transformed = np.log1p(transformed)

            return pd.Series(transformed, index=y.index)

        except Exception as e:
            print(f"Warning: Domain-specific transformation failed: {e}")
            return self.log_transformation(y, 'log1p')

    def inverse_transform(self, y_transformed: pd.Series, method: str, **kwargs) -> pd.Series:
        """
        Inverse transformation to get back to original scale

        Args:
            y_transformed: Transformed target series
            method: Transformation method used
            **kwargs: Additional parameters for inverse transformation

        Returns:
            Original scale series
        """
        if method == 'log1p':
            return np.expm1(y_transformed)
        elif method == 'log':
            constant = kwargs.get('constant', 0)
            return np.exp(y_transformed) - constant
        elif method == 'safe_log':
            constant = kwargs.get('constant', 0)
            return np.exp(y_transformed) - constant
        elif method == 'sqrt':
            return np.power(y_transformed, 2)
        elif method == 'boxcox':
            lambda_param = kwargs.get('lambda_param', 0)
            constant = kwargs.get('constant', 0)
            y_shifted = y_transformed + constant
            if lambda_param == 0:
                return np.exp(y_shifted) - constant
            else:
                return np.power(lambda_param * y_shifted + 1, 1/lambda_param) - constant
        elif method == 'yeojohnson':
            lambda_param = kwargs.get('lambda_param', 0)
            transformer = kwargs.get('transformer', None)
            if transformer:
                return transformer.inverse_transform(y_transformed.values.reshape(-1, 1)).flatten()
            else:
                # Manual inverse yeo-johnson (simplified)
                if lambda_param == 0:
                    return np.exp(y_transformed) - 1
                elif lambda_param == 1:
                    return y_transformed
                else:
                    return (np.exp(y_transformed) - 1) / lambda_param
        elif method == 'quantile':
            transformer = kwargs.get('transformer', None)
            if transformer:
                return transformer.inverse_transform(y_transformed.values.reshape(-1, 1)).flatten()
            else:
                return y_transformed
        elif method == 'domain_specific':
            # Need features to invert domain transformation
            # For now, return exponential
            return np.expm1(y_transformed)
        else:
            return y_transformed

    def evaluate_transformation(self, y_true: pd.Series, y_transformed: pd.Series,
                             method: str, X_train=None, X_test=None, **kwargs) -> dict:
        """
        Evaluate transformation effectiveness using a simple model

        Args:
            y_true: Original target values
            y_transformed: Transformed target values
            method: Transformation method name
            X_train, X_test: Features for simple evaluation
            **kwargs: Additional transformation parameters

        Returns:
            Dictionary with evaluation metrics
        """
        try:
            # Split data
            y_train_t, y_test_t = train_test_split(y_transformed, test_size=0.3, random_state=42)
            y_train_orig, y_test_orig = train_test_split(y_true, test_size=0.3, random_state=42)

            # Simple model evaluation
            if X_train is not None and X_test is not None:
                # Use provided features
                X_tr, X_te = train_test_split(X_train, test_size=0.3, random_state=42)
                model = RandomForestRegressor(n_estimators=50, random_state=42)
                model.fit(X_tr, y_train_t)
                y_pred_t = model.predict(X_te)
            else:
                # Use time series prediction (simple)
                model = LinearRegression()
                # Use index as time feature
                time_train = np.arange(len(y_train_t)).reshape(-1, 1)
                time_test = np.arange(len(y_test_t)).reshape(-1, 1)
                model.fit(time_train, y_train_t)
                y_pred_t = model.predict(time_test)

            # Calculate metrics in transformed space
            mae_t = mean_absolute_error(y_test_t, y_pred_t)
            mse_t = mean_squared_error(y_test_t, y_pred_t)
            r2_t = r2_score(y_test_t, y_pred_t)

            # Transform back to original scale
            y_pred_orig = self.inverse_transform(pd.Series(y_pred_t), method, **kwargs)

            # Calculate metrics in original scale
            mae_orig = mean_absolute_error(y_test_orig, y_pred_orig)
            mse_orig = mean_squared_error(y_test_orig, y_pred_orig)
            r2_orig = r2_score(y_test_orig, y_pred_orig)
            mape = np.mean(np.abs((y_test_orig - y_pred_orig) / (y_test_orig + 1e-8))) * 100

            return {
                'method': method,
                'mae_transformed': mae_t,
                'r2_transformed': r2_t,
                'mae_original': mae_orig,
                'mse_original': mse_orig,
                'rmse_original': np.sqrt(mse_orig),
                'r2_original': r2_orig,
                'mape_original': mape,
                'transformation_params': kwargs
            }

        except Exception as e:
            print(f"Warning: Evaluation failed for {method}: {e}")
            return {
                'method': method,
                'mae_original': float('inf'),
                'r2_original': -float('inf'),
                'mape_original': float('inf'),
                'error': str(e)
            }

    def find_best_transformation(self, y: pd.Series, X: pd.DataFrame = None) -> dict:
        """
        Find the best transformation for the target

        Args:
            y: Target series
            X: Feature dataframe (optional)

        Returns:
            Dictionary with all transformation results and best recommendation
        """
        print("🔍 Finding best target transformation...")
        print("=" * 60)

        # Analyze original distribution
        analysis = self.analyze_target_distribution(y)
        print(f"📊 Target Distribution Analysis:")
        print(f"   • Count: {analysis['count']:,}")
        print(f"   • Mean: {analysis['mean']:.2f}")
        print(f"   • Std: {analysis['std']:.2f}")
        print(f"   • Range: [{analysis['min']:.2f}, {analysis['max']:.2f}]")
        print(f"   • Skewness: {analysis['skewness']:.3f}")
        print(f"   • Kurtosis: {analysis['kurtosis']:.3f}")
        print(f"   • CV: {analysis['cv']:.3f}")
        print(f"   • Zero values: {analysis['zero_count']} ({analysis['zero_count']/analysis['count']:.1%})")
        print(f"   • Near-zero values: {analysis['near_zero_count']} ({analysis['near_zero_count']/analysis['count']:.1%})")

        transformations_to_try = ['log1p', 'safe_log', 'sqrt', 'boxcox', 'yeojohnson', 'quantile']
        if X is not None:
            transformations_to_try.append('domain_specific')

        results = {}

        for method in transformations_to_try:
            print(f"\n🔧 Testing {method} transformation...")

            try:
                if method == 'log1p':
                    y_t = self.log_transformation(y, 'log1p')
                    result = self.evaluate_transformation(y, y_t, method)

                elif method == 'safe_log':
                    y_t = self.log_transformation(y, 'safe_log')
                    result = self.evaluate_transformation(y, y_t, method)

                elif method == 'sqrt':
                    y_t = np.sqrt(y.clip(lower=0))
                    result = self.evaluate_transformation(y, y_t, method)

                elif method == 'boxcox':
                    y_t, lambda_param, constant = self.power_transformation(y, 'boxcox')
                    result = self.evaluate_transformation(y, y_t, method, lambda_param=lambda_param, constant=constant)

                elif method == 'yeojohnson':
                    y_t, lambda_param, constant = self.power_transformation(y, 'yeojohnson')
                    result = self.evaluate_transformation(y, y_t, method, lambda_param=lambda_param, constant=constant)

                elif method == 'quantile':
                    y_t, transformer = self.quantile_transformation(y)
                    result = self.evaluate_transformation(y, y_t, method, transformer=transformer)

                elif method == 'domain_specific':
                    y_t = self.domain_specific_transformation(y, X)
                    result = self.evaluate_transformation(y, y_t, method)

                results[method] = result
                print(f"   • MAE: {result['mae_original']:.3f}")
                print(f"   • RMSE: {result['rmse_original']:.3f}")
                print(f"   • R²: {result['r2_original']:.3f}")
                print(f"   • MAPE: {result['mape_original']:.1f}%")

            except Exception as e:
                print(f"   ❌ Failed: {e}")
                results[method] = {
                    'method': method,
                    'mae_original': float('inf'),
                    'r2_original': -float('inf'),
                    'mape_original': float('inf'),
                    'error': str(e)
                }

        # Find best transformation
        valid_results = [r for r in results.values() if r['mape_original'] != float('inf')]

        if valid_results:
            best_by_mae = min(valid_results, key=lambda x: x['mae_original'])
            best_by_rmse = min(valid_results, key=lambda x: x['rmse_original'])
            best_by_r2 = max(valid_results, key=lambda x: x['r2_original'])
            best_by_mape = min(valid_results, key=lambda x: x['mape_original'])

            self.best_transformation = best_by_mape['method']

            print(f"\n🏆 BEST TRANSFORMATION RESULTS:")
            print(f"   • Best by MAE: {best_by_mae['method']} (MAE: {best_by_mae['mae_original']:.3f})")
            print(f"   • Best by RMSE: {best_by_rmse['method']} (RMSE: {best_by_rmse['rmse_original']:.3f})")
            print(f"   • Best by R²: {best_by_r2['method']} (R²: {best_by_r2['r2_original']:.3f})")
            print(f"   • Best by MAPE: {best_by_mape['method']} (MAPE: {best_by_mape['mape_original']:.1f}%)")

        else:
            print(f"\n❌ All transformations failed!")
            self.best_transformation = 'log1p'  # Default fallback

        self.transformation_results = results
        return {
            'analysis': analysis,
            'results': results,
            'best_transformation': self.best_transformation,
            'best_results': {
                'by_mae': best_by_mae if valid_results else None,
                'by_rmse': best_by_rmse if valid_results else None,
                'by_r2': best_by_r2 if valid_results else None,
                'by_mape': best_by_mape if valid_results else None
            }
        }

    def visualize_transformations(self, y: pd.Series, save_path: str = None):
        """
        Create comprehensive visualization of transformation results
        """
        if not self.transformation_results:
            print("❌ No transformation results to visualize")
            return

        fig, axes = plt.subplots(3, 3, figsize=(20, 15))
        fig.suptitle('Target Transformation Comparison', fontsize=16, fontweight='bold')

        methods = ['log1p', 'safe_log', 'sqrt', 'boxcox', 'yeojohnson', 'quantile']

        # Plot 1: Original distribution
        ax1 = axes[0, 0]
        ax1.hist(y.dropna(), bins=50, alpha=0.7, color='blue', edgecolor='black', density=True)
        ax1.set_xlabel('1RM (kg)')
        ax1.set_ylabel('Density')
        ax1.set_title('Original Distribution')
        ax1.grid(True, alpha=0.3)

        # Plot 2: Q-Q Plot of original
        ax2 = axes[0, 1]
        stats.probplot(y.dropna(), dist="norm", plot=ax2)
        ax2.set_title('Original Q-Q Plot')
        ax2.grid(True, alpha=0.3)

        # Plot 3: Box plot of original
        ax3 = axes[0, 2]
        ax3.boxplot(y.dropna(), patch_artist=True)
        ax3.set_ylabel('1RM (kg)')
        ax3.set_title('Original Box Plot')
        ax3.grid(True, alpha=0.3)

        # Plot 4-6: Best transformations
        best_methods = sorted(methods, key=lambda x: self.transformation_results.get(x, {}).get('mape_original', float('inf')))

        for i, method in enumerate(best_methods[:3]):
            row = 1
            col = i

            if method == 'log1p':
                y_t = self.log_transformation(y, 'log1p')
                title = 'Log(1+X) Transform'
                color = 'green'
            elif method == 'sqrt':
                y_t = np.sqrt(y.clip(lower=0))
                title = 'Square Root Transform'
                color = 'orange'
            elif method == 'boxcox':
                try:
                    y_t, _, _ = self.power_transformation(y, 'boxcox')
                    title = 'Box-Cox Transform'
                    color = 'red'
                except:
                    y_t = self.log_transformation(y, 'log1p')
                    title = 'Box-Cox (Fallback to Log)'
                    color = 'red'
            else:
                continue

            ax = axes[row, col]

            # Histogram of transformed
            ax.hist(y_t.dropna(), bins=50, alpha=0.7, color=color, edgecolor='black', density=True)
            ax.set_xlabel('Transformed Value')
            ax.set_ylabel('Density')
            ax.set_title(f'{title}\nMAPE: {self.transformation_results[method]["mape_original"]:.1f}%')
            ax.grid(True, alpha=0.3)

        # Plot 7-8: Metrics comparison
        methods_to_plot = ['log1p', 'sqrt', 'boxcox']
        if 'yeojohnson' in self.transformation_results:
            methods_to_plot.append('yeojohnson')
        if 'quantile' in self.transformation_results:
            methods_to_plot.append('quantile')

        mae_values = [self.transformation_results[m]['mae_original'] for m in methods_to_plot if m in self.transformation_results]
        rmse_values = [self.transformation_results[m]['rmse_original'] for m in methods_to_plot if m in self.transformation_results]
        r2_values = [self.transformation_results[m]['r2_original'] for m in methods_to_plot if m in self.transformation_results]

        ax7 = axes[2, 0]
        bars = ax7.bar(methods_to_plot, mae_values, alpha=0.7, color='skyblue', edgecolor='black')
        ax7.set_xlabel('Transformation Method')
        ax7.set_ylabel('MAE')
        ax7.set_title('MAE Comparison')
        ax7.grid(True, alpha=0.3)
        # Add value labels
        for bar, value in zip(bars, mae_values):
            ax7.text(bar.get_x() + bar.get_width()/2, bar.get_height() + max(mae_values)*0.01,
                    f'{value:.1f}', ha='center', va='bottom')

        ax8 = axes[2, 1]
        bars = ax8.bar(methods_to_plot, rmse_values, alpha=0.7, color='lightcoral', edgecolor='black')
        ax8.set_xlabel('Transformation Method')
        ax8.set_ylabel('RMSE')
        ax8.set_title('RMSE Comparison')
        ax8.grid(True, alpha=0.3)
        # Add value labels
        for bar, value in zip(bars, rmse_values):
            ax8.text(bar.get_x() + bar.get_width()/2, bar.get_height() + max(rmse_values)*0.01,
                    f'{value:.1f}', ha='center', va='bottom')

        ax9 = axes[2, 2]
        bars = ax9.bar(methods_to_plot, r2_values, alpha=0.7, color='lightgreen', edgecolor='black')
        ax9.set_xlabel('Transformation Method')
        ax9.set_ylabel('R² Score')
        ax9.set_title('R² Score Comparison')
        ax9.grid(True, alpha=0.3)
        # Add value labels
        for bar, value in zip(bars, r2_values):
            ax9.text(bar.get_x() + bar.get_width()/2, bar.get_height() + max(r2_values)*0.01,
                    f'{value:.3f}', ha='center', va='bottom')

        plt.tight_layout()

        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            print(f"   • Visualization saved: {save_path}")

        plt.close()

    def apply_best_transformation(self, y: pd.Series, features: pd.DataFrame = None) -> tuple:
        """
        Apply the best transformation found

        Args:
            y: Target series
            features: Feature dataframe (for domain_specific)

        Returns:
            Tuple of (transformed_series, transformation_method, inverse_params)
        """
        if not self.best_transformation:
            self.find_best_transformation(y, features)

        method = self.best_transformation

        if method == 'log1p':
            return self.log_transformation(y, 'log1p'), method, {}
        elif method == 'safe_log':
            min_val = y.min()
            constant = max(1, abs(min_val) + 1e-8)
            return self.log_transformation(y, 'safe_log'), method, {'constant': constant}
        elif method == 'sqrt':
            return np.sqrt(y.clip(lower=0)), method, {}
        elif method == 'boxcox':
            y_t, lambda_param, constant = self.power_transformation(y, 'boxcox')
            return y_t, method, {'lambda_param': lambda_param, 'constant': constant}
        elif method == 'yeojohnson':
            y_t, lambda_param, constant = self.power_transformation(y, 'yeojohnson')
            return y_t, method, {'lambda_param': lambda_param, 'constant': constant}
        elif method == 'quantile':
            y_t, transformer = self.quantile_transformation(y)
            return y_t, method, {'transformer': transformer}
        elif method == 'domain_specific' and features is not None:
            return self.domain_specific_transformation(y, features), method, {}
        else:
            return self.log_transformation(y, 'log1p'), method, {}

    def save_transformation_config(self, save_path: str):
        """
        Save transformation configuration for future use
        """
        config = {
            'target_column': self.target_column,
            'best_transformation': self.best_transformation,
            'transformation_results': self.transformation_results,
            'analysis': self.analyze_target_distribution(
                pd.Series([0]) if not self.transformation_results else pd.Series([0])
            )
        }

        # Remove numpy arrays for JSON serialization
        if 'results' in config:
            for method, result in config['results'].items():
                if 'transformer' in result.get('transformation_params', {}):
                    del result['transformation_params']['transformer']

        with open(save_path, 'w') as f:
            json.dump(config, f, indent=2, default=str)

        print(f"   • Transformation config saved: {save_path}")


def main():
    """Main function to analyze target transformations"""
    import argparse

    parser = argparse.ArgumentParser(description='Target Transformation Analysis')
    parser.add_argument('--data', type=str,
                       default='./data/test_dataset.xlsx',
                       help='Data file path')
    parser.add_argument('--target', type=str,
                       default='estimated_1rm',
                       help='Target column name')
    parser.add_argument('--output', type=str,
                       default='./target_transformation_results',
                       help='Output directory')
    parser.add_argument('--visualize', action='store_true',
                       help='Create transformation visualizations')

    args = parser.parse_args()

    # Create output directory
    output_dir = Path(args.output)
    output_dir.mkdir(exist_ok=True)

    try:
        # Load data
        data = pd.read_excel(args.data)
        print(f"📁 Loaded data: {data.shape}")

        if args.target not in data.columns:
            print(f"❌ Target column '{args.target}' not found in data")
            print(f"Available columns: {list(data.columns)}")
            return

        y = data[args.target]
        X = data.drop(columns=[args.target]) if args.visualize else None

        # Initialize transformer
        transformer = TargetTransformer(args.target)

        # Find best transformation
        results = transformer.find_best_transformation(y, X)

        # Save results
        results_file = output_dir / 'transformation_results.json'
        with open(results_file, 'w') as f:
            json.dump(results, f, indent=2, default=str)

        # Save transformation config
        config_file = output_dir / 'best_transformation_config.json'
        transformer.save_transformation_config(config_file)

        # Create visualizations
        if args.visualize:
            viz_file = output_dir / 'transformation_comparison.png'
            transformer.visualize_transformations(y, viz_file)

        print(f"\n🎉 Target transformation analysis completed!")
        print(f"📁 Results saved in: {output_dir}")

        # Apply best transformation example
        print(f"\n✅ Applying best transformation: {transformer.best_transformation}")
        y_transformed, method, params = transformer.apply_best_transformation(y, X)
        print(f"   • Original mean: {y.mean():.2f}")
        print(f"   • Transformed mean: {y_transformed.mean():.2f}")
        print(f"   • Original std: {y.std():.2f}")
        print(f"   • Transformed std: {y_transformed.std():.2f}")

        # Example inverse transformation
        sample_size = min(5, len(y_transformed))
        sample_original = y.iloc[:sample_size].values
        sample_transformed = y_transformed.iloc[:sample_size].values
        sample_inverted = transformer.inverse_transform(
            pd.Series(sample_transformed), method, **params
        ).values

        print(f"\n🔄 Inverse Transformation Test (first {sample_size} samples):")
        for i in range(sample_size):
            print(f"   • Original: {sample_original[i]:.2f} -> "
                  f"Transformed: {sample_transformed[i]:.3f} -> "
                  f"Inverted: {sample_inverted[i]:.2f} "
                  f"(Error: {abs(sample_original[i] - sample_inverted[i]):.2f})")

    except Exception as e:
        print(f"❌ Error during transformation analysis: {e}")
        raise


if __name__ == "__main__":
    main()