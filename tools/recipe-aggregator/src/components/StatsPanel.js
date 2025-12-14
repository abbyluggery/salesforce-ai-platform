import React from 'react';
import './StatsPanel.css';

function StatsPanel({ total, filtered }) {
  const percentage = total > 0 ? Math.round((filtered / total) * 100) : 0;

  return (
    <div className="stats-panel">
      <div className="stat-item">
        <div className="stat-number">{total}</div>
        <div className="stat-description">Total Recipes</div>
      </div>
      
      <div className="stat-divider"></div>
      
      <div className="stat-item">
        <div className="stat-number">{filtered}</div>
        <div className="stat-description">Matching Filters</div>
      </div>
      
      <div className="stat-divider"></div>
      
      <div className="stat-item">
        <div className="stat-number">{percentage}%</div>
        <div className="stat-description">Match Rate</div>
      </div>
    </div>
  );
}

export default StatsPanel;
