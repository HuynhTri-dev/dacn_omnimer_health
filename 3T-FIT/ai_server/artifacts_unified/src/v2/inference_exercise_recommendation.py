# -*- coding: utf-8 -*-
"""
inference_exercise_recommendation.py

Script inference cho Exercise Recommendation Model
Nhận input: health profile + danh sách exercise names
Trả về: Top exercises với suitability scores và intensity parameters

Usage:
    python inference_exercise_recommendation.py --input input.json --output output.json
"""

import os
import json
import argparse
import numpy as np
import pandas as pd
import joblib
from typing import List, Dict, Any

import torch

# Import model từ training script
import sys
sys.path.append(os.path.dirname(__file__))
from train_exercise_recommendation import ExerciseRecommendationModel, normalize_exercise_name

# ==================== INFERENCE CLASS ====================

class ExerciseRecommender:
    """
    Class để thực hiện inference
    """
    def __init__(self, artifacts_dir: str):
        """
        Load model và artifacts
        
        Args:
            artifacts_dir: Thư mục chứa model và artifacts
        """
        self.artifacts_dir = artifacts_dir
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        
        # Load metadata
        metadata_path = os.path.join(artifacts_dir, 'metadata.json')
        with open(metadata_path, 'r', encoding='utf-8') as f:
            self.metadata = json.load(f)
        
        # Load preprocessor
        preprocessor_path = os.path.join(artifacts_dir, 'preprocessor.joblib')
        self.preprocessor = joblib.load(preprocessor_path)
        
        # Load model
        model_path = os.path.join(artifacts_dir, 'best_model.pt')
        checkpoint = torch.load(model_path, map_location=self.device)
        
        self.model = ExerciseRecommendationModel(
            input_dim=self.metadata['model_config']['input_dim'],
            num_exercises=self.metadata['model_config']['num_exercises'],
            embed_dim=self.metadata['model_config']['embed_dim'],
            hidden_dim=self.metadata['model_config']['hidden_dim'],
            dropout=self.metadata['model_config']['dropout']
        ).to(self.device)
        
        self.model.load_state_dict(checkpoint['model_state_dict'])
        self.model.eval()
        
        # Exercise mappings
        self.exercise_list = self.metadata['exercise_list']
        self.exercise_to_idx = self.metadata['exercise_to_idx']
        self.idx_to_exercise = {int(k): v for k, v in self.metadata['idx_to_exercise'].items()}
        
        # Intensity scales
        self.intensity_scales = self.metadata['intensity_scales']
        self.intensity_params = self.metadata['intensity_params']
        
        print(f"✓ Loaded model from: {artifacts_dir}")
        print(f"  - {len(self.exercise_list)} exercises")
        print(f"  - Input dim: {self.metadata['model_config']['input_dim']}")
        print(f"  - Device: {self.device}")
    
    def preprocess_health_profile(self, health_profile: Dict[str, Any]) -> np.ndarray:
        """
        Tiền xử lý health profile
        
        Args:
            health_profile: Dictionary chứa thông tin sức khỏe
        
        Returns:
            Preprocessed features array
        """
        # Tạo DataFrame từ health profile
        df = pd.DataFrame([health_profile])
        
        # Đảm bảo có đủ các features cần thiết
        for feat in self.metadata['features_used']:
            if feat not in df.columns:
                df[feat] = None  # Will be imputed
        
        # Select features theo thứ tự đúng
        df = df[self.metadata['features_used']]
        
        # Transform
        X_transformed = self.preprocessor.transform(df)
        X_array = X_transformed.toarray() if hasattr(X_transformed, 'toarray') else np.asarray(X_transformed)
        
        return X_array
    
    def descale_intensity(self, intensity_scaled: np.ndarray) -> Dict[str, float]:
        """
        Chuyển intensity parameters từ [0,1] về giá trị thực
        
        Args:
            intensity_scaled: Array [8] với giá trị trong [0,1]
        
        Returns:
            Dictionary với intensity parameters
        """
        intensity_dict = {}
        
        for idx, param_name in enumerate(self.intensity_params):
            lo, hi = self.intensity_scales[param_name]
            scaled_value = intensity_scaled[idx]
            real_value = scaled_value * (hi - lo) + lo
            
            # Round appropriately
            if param_name in ['sets', 'reps']:
                real_value = int(round(real_value))
            else:
                real_value = round(real_value, 2)
            
            intensity_dict[param_name] = real_value
        
        return intensity_dict
    
    def recommend(self, health_profile: Dict[str, Any], 
                  exercise_names: List[str], 
                  top_k: int = 5) -> List[Dict[str, Any]]:
        """
        Gợi ý bài tập dựa trên health profile và danh sách exercises
        
        Args:
            health_profile: Dictionary chứa thông tin sức khỏe
            exercise_names: Danh sách tên bài tập (từ RAG/filtering)
            top_k: Số lượng bài tập gợi ý
        
        Returns:
            List of recommended exercises với scores và intensity
        """
        # Preprocess health profile
        X = self.preprocess_health_profile(health_profile)
        X_tensor = torch.from_numpy(X).float().to(self.device)
        
        # Forward pass
        with torch.no_grad():
            suitability_logits, intensity_scaled = self.model(X_tensor)
        
        # Convert to numpy
        suitability_scores = torch.sigmoid(suitability_logits).cpu().numpy()[0]  # [num_exercises]
        intensity_params = intensity_scaled.cpu().numpy()[0]  # [num_exercises, 8]
        
        # Filter exercises theo danh sách input
        normalized_input = [normalize_exercise_name(name) for name in exercise_names]
        
        # Tìm indices của exercises trong input list
        valid_indices = []
        valid_names = []
        for name in normalized_input:
            if name in self.exercise_to_idx:
                idx = self.exercise_to_idx[name]
                valid_indices.append(idx)
                valid_names.append(name)
        
        if len(valid_indices) == 0:
            return []
        
        # Lấy scores và intensity cho các exercises hợp lệ
        filtered_scores = suitability_scores[valid_indices]
        filtered_intensity = intensity_params[valid_indices]
        
        # Sort theo suitability score (descending)
        sorted_indices = np.argsort(filtered_scores)[::-1][:top_k]
        
        # Tạo recommendations
        recommendations = []
        for rank, idx in enumerate(sorted_indices, 1):
            exercise_idx = valid_indices[idx]
            exercise_name = self.idx_to_exercise[exercise_idx]
            score = float(filtered_scores[idx])
            intensity = filtered_intensity[idx]
            
            # Descale intensity
            intensity_dict = self.descale_intensity(intensity)
            
            # Format theo yêu cầu backend
            recommendation = {
                'rank': rank,
                'name': exercise_name,  # Tên chính xác để mapping với DB
                'suitabilityScore': round(score, 3),
                'sets': [
                    {
                        'reps': intensity_dict['reps'],
                        'kg': intensity_dict['kg'],
                        'km': intensity_dict['km'],
                        'min': intensity_dict['min'],
                        'minRest': intensity_dict['minRest']
                    }
                    for _ in range(int(intensity_dict['sets']))
                ],
                'predictedAvgHR': intensity_dict['avgHR'],
                'predictedPeakHR': intensity_dict['peakHR']
            }
            
            recommendations.append(recommendation)
        
        return recommendations

# ==================== CLI ====================

def main():
    parser = argparse.ArgumentParser(description='Exercise Recommendation Inference')
    parser.add_argument('--artifacts', type=str, 
                       default='../artifacts_exercise_rec',
                       help='Path to artifacts directory')
    parser.add_argument('--input', type=str, required=True,
                       help='Path to input JSON file')
    parser.add_argument('--output', type=str, required=True,
                       help='Path to output JSON file')
    parser.add_argument('--top-k', type=int, default=5,
                       help='Number of recommendations')
    
    args = parser.parse_args()
    
    # Load recommender
    recommender = ExerciseRecommender(args.artifacts)
    
    # Load input
    with open(args.input, 'r', encoding='utf-8') as f:
        input_data = json.load(f)
    
    health_profile = input_data['healthProfile']
    exercise_names = [ex['exerciseName'] for ex in input_data['exercises']]
    
    print(f"\n{'='*80}")
    print("EXERCISE RECOMMENDATION")
    print(f"{'='*80}")
    print(f"Input exercises: {len(exercise_names)}")
    print(f"Top K: {args.top_k}")
    
    # Get recommendations
    recommendations = recommender.recommend(
        health_profile=health_profile,
        exercise_names=exercise_names,
        top_k=args.top_k
    )
    
    # Format output
    output_data = {
        'exercises': recommendations,
        'totalRecommendations': len(recommendations)
    }
    
    # Save output
    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, ensure_ascii=False, indent=2)
    
    print(f"\n✓ Generated {len(recommendations)} recommendations")
    print(f"✓ Saved to: {args.output}")
    print(f"{'='*80}\n")
    
    # Print summary
    for rec in recommendations:
        print(f"{rec['rank']}. {rec['name']}")
        print(f"   Suitability: {rec['suitabilityScore']:.3f}")
        print(f"   Sets: {len(rec['sets'])}, Reps: {rec['sets'][0]['reps']}, Weight: {rec['sets'][0]['kg']}kg")
        print(f"   HR: {rec['predictedAvgHR']:.0f} avg, {rec['predictedPeakHR']:.0f} peak")
        print()

if __name__ == '__main__':
    main()
