import React from 'react';
import './RecipeCard.css';

function RecipeCard({ recipe }) {
  return (
    <div className="recipe-card">
      <div className="recipe-image">
        <img src={recipe.image_url || 'https://via.placeholder.com/300x200'} alt={recipe.name} />
        <div className="recipe-badges">
          {recipe.is_heart_healthy && <span className="badge heart-healthy">❤️ Heart Healthy</span>}
          {recipe.is_weeknight_friendly && <span className="badge weeknight">⚡ Quick</span>}
        </div>
      </div>
      
      <div className="recipe-content">
        <h3 className="recipe-title">{recipe.name}</h3>
        
        <div className="recipe-meta">
          <span className="cuisine-tag">{recipe.cuisine}</span>
          <span className="source-tag">{recipe.source}</span>
        </div>

        <div className="recipe-stats">
          <div className="stat">
            <span className="stat-icon">🔥</span>
            <span className="stat-value">{recipe.calories}</span>
            <span className="stat-label">cal</span>
          </div>
          <div className="stat">
            <span className="stat-icon">⏱️</span>
            <span className="stat-value">{recipe.total_time_minutes}</span>
            <span className="stat-label">min</span>
          </div>
          <div className="stat">
            <span className="stat-icon">💪</span>
            <span className="stat-value">{recipe.protein_g}g</span>
            <span className="stat-label">protein</span>
          </div>
        </div>

        <div className="recipe-nutrition-detail">
          <div className="nutrition-row">
            <span>Carbs:</span>
            <span>{recipe.carbs_g}g</span>
          </div>
          <div className="nutrition-row">
            <span>Fat:</span>
            <span>{recipe.fat_g}g</span>
          </div>
          <div className="nutrition-row">
            <span>Sodium:</span>
            <span className={recipe.sodium_mg > 600 ? 'high-sodium' : 'low-sodium'}>
              {recipe.sodium_mg}mg
            </span>
          </div>
        </div>

        {recipe.source_url && recipe.source_url !== 'https://example.com' && (
          <a 
            href={recipe.source_url} 
            target="_blank" 
            rel="noopener noreferrer"
            className="view-recipe-btn"
          >
            View Full Recipe →
          </a>
        )}
      </div>
    </div>
  );
}

export default RecipeCard;
