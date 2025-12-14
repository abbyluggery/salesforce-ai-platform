import React, { useState } from 'react';
import './SearchBar.css';

function SearchBar({ onSearchChange, onSortChange, sortBy }) {
  const [searchTerm, setSearchTerm] = useState('');

  const handleSearchInput = (e) => {
    const value = e.target.value;
    setSearchTerm(value);
    onSearchChange(value);
  };

  const clearSearch = () => {
    setSearchTerm('');
    onSearchChange('');
  };

  return (
    <div className="search-bar">
      <div className="search-input-wrapper">
        <span className="search-icon">🔍</span>
        <input
          type="text"
          placeholder="Search recipes by name, ingredients, or cuisine..."
          value={searchTerm}
          onChange={handleSearchInput}
          className="search-input"
        />
        {searchTerm && (
          <button onClick={clearSearch} className="clear-search">
            ✕
          </button>
        )}
      </div>

      <div className="sort-controls">
        <label htmlFor="sort-select">Sort by:</label>
        <select
          id="sort-select"
          value={sortBy}
          onChange={(e) => onSortChange(e.target.value)}
          className="sort-select"
        >
          <option value="name">Name (A-Z)</option>
          <option value="calories">Calories (Low to High)</option>
          <option value="cookTime">Cook Time (Quick First)</option>
          <option value="protein">Protein (High to Low)</option>
        </select>
      </div>
    </div>
  );
}

export default SearchBar;
