import React, { useState, useEffect } from 'react';
import './App.css';
import RecipeCard from './components/RecipeCard';
import FilterPanel from './components/FilterPanel';
import SearchBar from './components/SearchBar';
import StatsPanel from './components/StatsPanel';

function App() {
  const [recipes, setRecipes] = useState([]);
  const [filteredRecipes, setFilteredRecipes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [filters, setFilters] = useState({
    maxCalories: 1000,
    maxSodium: 600,
    maxCookTime: 60,
    heartHealthy: false,
    diabeticFriendly: false,
    weeknightFriendly: false,
    source: 'all'
  });
  const [sortBy, setSortBy] = useState('name');

  // Load recipes from CSV (in production, this would be an API call)
  useEffect(() => {
    loadRecipes();
  }, []);

  const loadRecipes = async () => {
    try {
      // In production, replace with actual API call
      // For demo, we'll load from a sample JSON file
      const response = await fetch('/sample_recipes.json');
      const data = await response.json();
      setRecipes(data);
      setFilteredRecipes(data);
      setLoading(false);
    } catch (error) {
      console.error('Error loading recipes:', error);
      // For demo purposes, use sample data
      const sampleData = generateSampleRecipes();
      setRecipes(sampleData);
      setFilteredRecipes(sampleData);
      setLoading(false);
    }
  };

  // Apply filters whenever search, filters, or sort changes
  useEffect(() => {
    applyFilters();
  }, [searchQuery, filters, sortBy, recipes]);

  const applyFilters = () => {
    let filtered = [...recipes];

    // Search filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(recipe =>
        recipe.name.toLowerCase().includes(query) ||
        recipe.ingredients.toLowerCase().includes(query) ||
        recipe.cuisine.toLowerCase().includes(query)
      );
    }

    // Nutrition filters
    filtered = filtered.filter(recipe =>
      recipe.calories <= filters.maxCalories &&
      recipe.sodium_mg <= filters.maxSodium &&
      recipe.total_time_minutes <= filters.maxCookTime
    );

    // Dietary filters
    if (filters.heartHealthy) {
      filtered = filtered.filter(r => r.is_heart_healthy);
    }
    if (filters.diabeticFriendly) {
      filtered = filtered.filter(r => r.is_diabetic_friendly);
    }
    if (filters.weeknightFriendly) {
      filtered = filtered.filter(r => r.is_weeknight_friendly);
    }

    // Source filter
    if (filters.source !== 'all') {
      filtered = filtered.filter(r => r.source === filters.source);
    }

    // Sort
    filtered.sort((a, b) => {
      switch (sortBy) {
        case 'name':
          return a.name.localeCompare(b.name);
        case 'calories':
          return a.calories - b.calories;
        case 'cookTime':
          return a.total_time_minutes - b.total_time_minutes;
        case 'protein':
          return b.protein_g - a.protein_g;
        default:
          return 0;
      }
    });

    setFilteredRecipes(filtered);
  };

  const handleSearchChange = (query) => {
    setSearchQuery(query);
  };

  const handleFilterChange = (newFilters) => {
    setFilters(newFilters);
  };

  const handleSortChange = (newSort) => {
    setSortBy(newSort);
  };

  if (loading) {
    return (
      <div className="app loading">
        <div className="loading-spinner"></div>
        <p>Loading delicious recipes...</p>
      </div>
    );
  }

  return (
    <div className="app">
      <header className="app-header">
        <div className="header-content">
          <h1>🍳 Recipe Database Browser</h1>
          <p className="subtitle">{recipes.length} healthy recipes for your meal planning</p>
        </div>
      </header>

      <main className="app-main">
        <div className="content-wrapper">
          {/* Stats Panel */}
          <StatsPanel 
            total={recipes.length}
            filtered={filteredRecipes.length}
          />

          {/* Search Bar */}
          <SearchBar 
            onSearchChange={handleSearchChange}
            onSortChange={handleSortChange}
            sortBy={sortBy}
          />

          <div className="main-content">
            {/* Filter Panel */}
            <aside className="filter-sidebar">
              <FilterPanel
                filters={filters}
                onFilterChange={handleFilterChange}
              />
            </aside>

            {/* Recipe Grid */}
            <div className="recipe-grid-container">
              {filteredRecipes.length === 0 ? (
                <div className="no-results">
                  <h3>No recipes found</h3>
                  <p>Try adjusting your filters or search query</p>
                </div>
              ) : (
                <div className="recipe-grid">
                  {filteredRecipes.map((recipe, index) => (
                    <RecipeCard key={index} recipe={recipe} />
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </main>

      <footer className="app-footer">
        <p>Recipe Database Aggregator | Portfolio Project by Abby</p>
        <p className="tech-stack">Built with React + Python + Salesforce</p>
      </footer>
    </div>
  );
}

// Sample data generator for demo purposes
function generateSampleRecipes() {
  const sources = ['TheMealDB', 'Edamam', 'Spoonacular'];
  const cuisines = ['Italian', 'Mexican', 'Asian', 'American', 'Mediterranean'];
  const proteins = ['Chicken', 'Beef', 'Fish', 'Vegetarian', 'Pork'];
  
  const sampleNames = [
    'Lemon Herb Grilled Chicken',
    'Mediterranean Salmon Bowl',
    'Quinoa Vegetable Stir-Fry',
    'Turkey Chili',
    'Baked Lemon Pepper Chicken',
    'Beef and Broccoli',
    'Garlic Shrimp Pasta',
    'Vegetarian Buddha Bowl',
    'Honey Garlic Chicken',
    'Mexican Chicken Fajitas',
    'Thai Peanut Noodles',
    'Greek Chicken Salad',
    'Teriyaki Salmon',
    'Veggie Lasagna',
    'Slow Cooker Pot Roast'
  ];

  return sampleNames.map((name, i) => ({
    name,
    ingredients: 'Sample ingredients list | olive oil | garlic | herbs | protein',
    instructions: 'Sample cooking instructions...',
    servings: 4,
    prep_time_minutes: Math.floor(Math.random() * 20) + 5,
    cook_time_minutes: Math.floor(Math.random() * 40) + 10,
    total_time_minutes: Math.floor(Math.random() * 60) + 15,
    calories: Math.floor(Math.random() * 400) + 200,
    protein_g: Math.floor(Math.random() * 40) + 15,
    carbs_g: Math.floor(Math.random() * 50) + 10,
    fat_g: Math.floor(Math.random() * 20) + 5,
    fiber_g: Math.floor(Math.random() * 8) + 2,
    sugar_g: Math.floor(Math.random() * 10) + 2,
    sodium_mg: Math.floor(Math.random() * 800) + 200,
    meal_type: 'Dinner',
    cuisine: cuisines[i % cuisines.length],
    protein_type: proteins[i % proteins.length],
    source: sources[i % sources.length],
    source_url: 'https://example.com',
    image_url: 'https://via.placeholder.com/300x200',
    is_heart_healthy: Math.random() > 0.5,
    is_diabetic_friendly: Math.random() > 0.6,
    is_weeknight_friendly: Math.random() > 0.4
  }));
}

export default App;
