import React from 'react';
import './FilterPanel.css';

function FilterPanel({ filters, onFilterChange }) {
  const handleSliderChange = (key, value) => {
    onFilterChange({ ...filters, [key]: value });
  };

  const handleCheckboxChange = (key) => {
    onFilterChange({ ...filters, [key]: !filters[key] });
  };

  const handleSourceChange = (source) => {
    onFilterChange({ ...filters, source });
  };

  const resetFilters = () => {
    onFilterChange({
      maxCalories: 1000,
      maxSodium: 600,
      maxCookTime: 60,
      heartHealthy: false,
      diabeticFriendly: false,
      weeknightFriendly: false,
      source: 'all'
    });
  };

  return (
    <div className="filter-panel">
      <div className="filter-header">
        <h2>Filters</h2>
        <button onClick={resetFilters} className="reset-btn">Reset</button>
      </div>

      {/* Nutrition Filters */}
      <div className="filter-section">
        <h3>Nutrition Limits</h3>
        
        <div className="filter-control">
          <label>
            Max Calories: {filters.maxCalories}
          </label>
          <input
            type="range"
            min="100"
            max="1500"
            step="50"
            value={filters.maxCalories}
            onChange={(e) => handleSliderChange('maxCalories', parseInt(e.target.value))}
          />
          <div className="range-labels">
            <span>100</span>
            <span>1500</span>
          </div>
        </div>

        <div className="filter-control">
          <label>
            Max Sodium: {filters.maxSodium}mg
          </label>
          <input
            type="range"
            min="0"
            max="2000"
            step="100"
            value={filters.maxSodium}
            onChange={(e) => handleSliderChange('maxSodium', parseInt(e.target.value))}
          />
          <div className="range-labels">
            <span>0</span>
            <span>2000mg</span>
          </div>
        </div>

        <div className="filter-control">
          <label>
            Max Cook Time: {filters.maxCookTime} min
          </label>
          <input
            type="range"
            min="15"
            max="180"
            step="15"
            value={filters.maxCookTime}
            onChange={(e) => handleSliderChange('maxCookTime', parseInt(e.target.value))}
          />
          <div className="range-labels">
            <span>15min</span>
            <span>180min</span>
          </div>
        </div>
      </div>

      {/* Dietary Preferences */}
      <div className="filter-section">
        <h3>Dietary Preferences</h3>
        
        <label className="checkbox-label">
          <input
            type="checkbox"
            checked={filters.heartHealthy}
            onChange={() => handleCheckboxChange('heartHealthy')}
          />
          <span>❤️ Heart Healthy (<600mg sodium)</span>
        </label>

        <label className="checkbox-label">
          <input
            type="checkbox"
            checked={filters.diabeticFriendly}
            onChange={() => handleCheckboxChange('diabeticFriendly')}
          />
          <span>🍬 Diabetic Friendly (<10g sugar)</span>
        </label>

        <label className="checkbox-label">
          <input
            type="checkbox"
            checked={filters.weeknightFriendly}
            onChange={() => handleCheckboxChange('weeknightFriendly')}
          />
          <span>⚡ Weeknight Friendly (≤30 min)</span>
        </label>
      </div>

      {/* Source Filter */}
      <div className="filter-section">
        <h3>Recipe Source</h3>
        
        <div className="source-buttons">
          <button
            className={`source-btn ${filters.source === 'all' ? 'active' : ''}`}
            onClick={() => handleSourceChange('all')}
          >
            All Sources
          </button>
          <button
            className={`source-btn ${filters.source === 'TheMealDB' ? 'active' : ''}`}
            onClick={() => handleSourceChange('TheMealDB')}
          >
            TheMealDB
          </button>
          <button
            className={`source-btn ${filters.source === 'Edamam' ? 'active' : ''}`}
            onClick={() => handleSourceChange('Edamam')}
          >
            Edamam
          </button>
          <button
            className={`source-btn ${filters.source === 'Spoonacular' ? 'active' : ''}`}
            onClick={() => handleSourceChange('Spoonacular')}
          >
            Spoonacular
          </button>
        </div>
      </div>
    </div>
  );
}

export default FilterPanel;
