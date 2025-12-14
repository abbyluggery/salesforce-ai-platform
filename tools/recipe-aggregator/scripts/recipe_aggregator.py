"""
Recipe Database Aggregator

Fetches recipes from multiple free APIs and builds a comprehensive database.
Handles deduplication, rate limiting, and data quality.

Author: Abby (Portfolio Project)
Date: December 2025
"""

import requests
import pandas as pd
import time
from tqdm import tqdm
import os
from dotenv import load_dotenv
import hashlib
import logging

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class RecipeAggregator:
    """
    Aggregates recipes from multiple free APIs.
    
    Supported sources:
    - TheMealDB (unlimited, no key needed)
    - Edamam (10,000/month free tier)
    - Spoonacular (150/day free tier)
    """
    
    def __init__(self):
        self.recipes = []
        self.seen_names = set()  # For deduplication
        
        # API Keys from environment
        self.edamam_id = os.getenv('EDAMAM_APP_ID')
        self.edamam_key = os.getenv('EDAMAM_APP_KEY')
        self.spoonacular_key = os.getenv('SPOONACULAR_API_KEY')
        
        logger.info("🍳 Recipe Aggregator initialized")
    
    def deduplicate_recipe(self, name):
        """
        Check if recipe name has already been seen.
        Uses normalized name (lowercase, no spaces) for comparison.
        
        Args:
            name (str): Recipe name to check
            
        Returns:
            bool: True if duplicate, False if new
        """
        # Create hash of normalized name
        normalized = name.lower().strip().replace(' ', '').replace('-', '')
        
        if normalized in self.seen_names:
            return True
        
        self.seen_names.add(normalized)
        return False
    
    # ===== SOURCE 1: TheMealDB =====
    def fetch_from_mealdb(self, num_recipes=100):
        """
        Fetch recipes from TheMealDB (completely free, unlimited)
        
        Args:
            num_recipes (int): Target number of recipes to fetch
        """
        logger.info(f"🍽️  Fetching from TheMealDB (target: {num_recipes} recipes)...")
        base_url = 'https://www.themealdb.com/api/json/v1/1'
        
        try:
            # Get all categories
            categories_url = f'{base_url}/categories.php'
            response = requests.get(categories_url, timeout=10)
            response.raise_for_status()
            categories = response.json()['categories']
            
            recipes_collected = 0
            
            # Iterate through categories
            for category in tqdm(categories, desc="TheMealDB Categories"):
                if recipes_collected >= num_recipes:
                    break
                
                cat_name = category['strCategory']
                
                # Get meals in this category
                meals_url = f'{base_url}/filter.php?c={cat_name}'
                try:
                    meals_response = requests.get(meals_url, timeout=10)
                    meals_response.raise_for_status()
                    meals = meals_response.json().get('meals', [])
                    
                    if not meals:
                        continue
                    
                    # Get details for each meal (limit to avoid too many requests)
                    for meal in meals[:10]:  # Max 10 per category
                        if recipes_collected >= num_recipes:
                            break
                        
                        meal_id = meal['idMeal']
                        detail_url = f'{base_url}/lookup.php?i={meal_id}'
                        
                        detail_response = requests.get(detail_url, timeout=10)
                        detail_response.raise_for_status()
                        detail = detail_response.json()['meals'][0]
                        
                        # Skip duplicates
                        if self.deduplicate_recipe(detail['strMeal']):
                            continue
                        
                        # Parse ingredients
                        ingredients = []
                        for i in range(1, 21):
                            ing = detail.get(f'strIngredient{i}', '').strip()
                            measure = detail.get(f'strMeasure{i}', '').strip()
                            if ing:
                                ingredients.append(f"{measure} {ing}".strip())
                        
                        # Add recipe
                        self.recipes.append({
                            'name': detail['strMeal'],
                            'ingredients': ' | '.join(ingredients),
                            'instructions': detail['strInstructions'],
                            'meal_type': 'Dinner',
                            'cuisine': detail.get('strArea', 'Unknown'),
                            'source': 'TheMealDB',
                            'source_url': detail.get('strSource', ''),
                            'image_url': detail.get('strMealThumb', ''),
                            'servings': 4,
                            'prep_time_minutes': 0,
                            'cook_time_minutes': 0,
                            'calories': 0,  # Not provided by TheMealDB
                            'protein_g': 0,
                            'carbs_g': 0,
                            'fat_g': 0,
                            'fiber_g': 0,
                            'sugar_g': 0,
                            'sodium_mg': 0
                        })
                        
                        recipes_collected += 1
                        time.sleep(0.1)  # Be respectful
                
                except Exception as e:
                    logger.warning(f"Error fetching category {cat_name}: {e}")
                    continue
            
            logger.info(f"✅ TheMealDB: Collected {recipes_collected} recipes")
            
        except Exception as e:
            logger.error(f"❌ TheMealDB fetch failed: {e}")
    
    # ===== SOURCE 2: Edamam =====
    def fetch_from_edamam(self, num_recipes=100, search_terms=None):
        """
        Fetch recipes from Edamam Recipe Search API
        Free tier: 10 requests/min, 10,000/month
        
        Args:
            num_recipes (int): Target number of recipes
            search_terms (list): Search terms to use
        """
        logger.info(f"🥗 Fetching from Edamam (target: {num_recipes} recipes)...")
        
        if not self.edamam_id or not self.edamam_key:
            logger.warning("⚠️  Edamam API keys not found in .env file")
            logger.info("Sign up at: https://developer.edamam.com/")
            return
        
        base_url = 'https://api.edamam.com/api/recipes/v2'
        
        if not search_terms:
            search_terms = ['chicken', 'beef', 'salmon', 'pasta', 'vegetarian',
                          'soup', 'salad', 'pork', 'shrimp', 'turkey']
        
        recipes_collected = 0
        
        for term in tqdm(search_terms, desc="Edamam Searches"):
            if recipes_collected >= num_recipes:
                break
            
            params = {
                'type': 'public',
                'q': term,
                'app_id': self.edamam_id,
                'app_key': self.edamam_key,
                'to': 10
            }
            
            try:
                response = requests.get(base_url, params=params, timeout=15)
                response.raise_for_status()
                data = response.json()
                
                for hit in data.get('hits', []):
                    if recipes_collected >= num_recipes:
                        break
                    
                    recipe = hit['recipe']
                    
                    # Skip duplicates
                    if self.deduplicate_recipe(recipe['label']):
                        continue
                    
                    # Extract nutrition
                    nutrients = recipe.get('totalNutrients', {})
                    servings = recipe.get('yield', 4)
                    
                    self.recipes.append({
                        'name': recipe['label'],
                        'ingredients': ' | '.join(recipe.get('ingredientLines', [])),
                        'instructions': recipe.get('url', ''),
                        'meal_type': recipe.get('mealType', ['Dinner'])[0].title(),
                        'cuisine': recipe.get('cuisineType', ['Unknown'])[0].title(),
                        'servings': int(servings),
                        'prep_time_minutes': 0,
                        'cook_time_minutes': 0,
                        'calories': int(nutrients.get('ENERC_KCAL', {}).get('quantity', 0) / servings),
                        'protein_g': round(nutrients.get('PROCNT', {}).get('quantity', 0) / servings, 1),
                        'carbs_g': round(nutrients.get('CHOCDF', {}).get('quantity', 0) / servings, 1),
                        'fat_g': round(nutrients.get('FAT', {}).get('quantity', 0) / servings, 1),
                        'fiber_g': round(nutrients.get('FIBTG', {}).get('quantity', 0) / servings, 1),
                        'sugar_g': round(nutrients.get('SUGAR', {}).get('quantity', 0) / servings, 1),
                        'sodium_mg': int(nutrients.get('NA', {}).get('quantity', 0) / servings),
                        'source': 'Edamam',
                        'source_url': recipe.get('url', ''),
                        'image_url': recipe.get('image', '')
                    })
                    
                    recipes_collected += 1
                
                # Rate limiting: 10 requests/min = 6 seconds between
                time.sleep(6)
                
            except Exception as e:
                logger.warning(f"Error fetching Edamam term '{term}': {e}")
                continue
        
        logger.info(f"✅ Edamam: Collected {recipes_collected} recipes")
    
    # ===== SOURCE 3: Spoonacular =====
    def fetch_from_spoonacular(self, num_recipes=150):
        """
        Fetch recipes from Spoonacular API
        Free tier: 150 points/day (1 point = 1 request)
        
        Args:
            num_recipes (int): Target number of recipes
        """
        logger.info(f"🥄 Fetching from Spoonacular (target: {num_recipes} recipes)...")
        
        if not self.spoonacular_key:
            logger.warning("⚠️  Spoonacular API key not found in .env file")
            logger.info("Sign up at: https://spoonacular.com/food-api")
            return
        
        base_url = 'https://api.spoonacular.com/recipes/complexSearch'
        recipes_collected = 0
        
        # Fetch in batches of 10
        for offset in tqdm(range(0, num_recipes, 10), desc="Spoonacular Batches"):
            if recipes_collected >= num_recipes:
                break
            
            params = {
                'apiKey': self.spoonacular_key,
                'number': 10,
                'offset': offset,
                'addRecipeNutrition': True,
                'fillIngredients': True
            }
            
            try:
                response = requests.get(base_url, params=params, timeout=15)
                response.raise_for_status()
                data = response.json()
                
                for recipe in data.get('results', []):
                    if recipes_collected >= num_recipes:
                        break
                    
                    # Skip duplicates
                    if self.deduplicate_recipe(recipe['title']):
                        continue
                    
                    # Extract nutrition
                    nutrition = recipe.get('nutrition', {}).get('nutrients', [])
                    nutrients_dict = {n['name']: n['amount'] for n in nutrition}
                    
                    # Parse ingredients
                    ingredients = []
                    for ing in recipe.get('extendedIngredients', []):
                        ingredients.append(ing.get('original', ''))
                    
                    servings = recipe.get('servings', 4)
                    
                    self.recipes.append({
                        'name': recipe['title'],
                        'ingredients': ' | '.join(ingredients),
                        'instructions': '',  # Would need separate API call
                        'servings': servings,
                        'prep_time_minutes': recipe.get('preparationMinutes', 0),
                        'cook_time_minutes': recipe.get('cookingMinutes', 0),
                        'calories': int(nutrients_dict.get('Calories', 0) / servings),
                        'protein_g': round(nutrients_dict.get('Protein', 0) / servings, 1),
                        'carbs_g': round(nutrients_dict.get('Carbohydrates', 0) / servings, 1),
                        'fat_g': round(nutrients_dict.get('Fat', 0) / servings, 1),
                        'fiber_g': round(nutrients_dict.get('Fiber', 0) / servings, 1),
                        'sugar_g': round(nutrients_dict.get('Sugar', 0) / servings, 1),
                        'sodium_mg': int(nutrients_dict.get('Sodium', 0) / servings),
                        'meal_type': 'Dinner',
                        'cuisine': 'Various',
                        'source': 'Spoonacular',
                        'source_url': recipe.get('sourceUrl', ''),
                        'image_url': recipe.get('image', '')
                    })
                    
                    recipes_collected += 1
                
                time.sleep(1)  # Be respectful
                
            except Exception as e:
                logger.error(f"Error fetching Spoonacular batch at offset {offset}: {e}")
                break
        
        logger.info(f"✅ Spoonacular: Collected {recipes_collected} recipes")
    
    # ===== SAVE & EXPORT =====
    def save_to_csv(self, filename='recipe_database.csv'):
        """
        Save all collected recipes to CSV
        
        Args:
            filename (str): Output filename
            
        Returns:
            pd.DataFrame: Recipe dataframe
        """
        df = pd.DataFrame(self.recipes)
        
        if len(df) == 0:
            logger.warning("⚠️  No recipes to save!")
            return df
        
        # Calculate total_time_minutes
        df['total_time_minutes'] = (
            df.get('prep_time_minutes', 0) + 
            df.get('cook_time_minutes', 0)
        )
        
        # Add computed flags
        df['is_heart_healthy'] = df.get('sodium_mg', 999999) < 600
        df['is_diabetic_friendly'] = df.get('sugar_g', 999999) < 10
        df['is_weeknight_friendly'] = df['total_time_minutes'] <= 30
        
        # Save
        df.to_csv(filename, index=False)
        logger.info(f"✅ Saved {len(df)} recipes to {filename}")
        
        return df
    
    def print_summary(self):
        """Print collection summary"""
        df = pd.DataFrame(self.recipes)
        
        if len(df) == 0:
            logger.warning("⚠️  No recipes collected!")
            return
        
        print("\n" + "="*60)
        print("📊 RECIPE COLLECTION SUMMARY")
        print("="*60)
        print(f"Total Recipes: {len(df)}")
        print(f"Unique Recipes: {len(self.seen_names)}")
        
        print(f"\nBy Source:")
        print(df['source'].value_counts())
        
        if 'calories' in df.columns and df['calories'].notna().sum() > 0:
            print(f"\nWith Nutrition Data: {df['calories'].notna().sum()}")
            print(f"Average Calories: {df['calories'].mean():.0f}")
        
        if 'sodium_mg' in df.columns and df['sodium_mg'].notna().sum() > 0:
            print(f"Heart-Healthy (<600mg sodium): {(df['sodium_mg'] < 600).sum()}")
        
        if 'total_time_minutes' in df.columns:
            print(f"Weeknight-Friendly (≤30min): {(df['total_time_minutes'] <= 30).sum()}")
        
        print("="*60)


# ===== MAIN EXECUTION =====
if __name__ == "__main__":
    print("""
╔══════════════════════════════════════════════════════════╗
║        RECIPE DATABASE AGGREGATOR                        ║
║        Collecting recipes from free APIs...              ║
╚══════════════════════════════════════════════════════════╝
""")
    
    aggregator = RecipeAggregator()
    
    # Fetch from all available sources
    aggregator.fetch_from_mealdb(num_recipes=100)
    aggregator.fetch_from_edamam(num_recipes=100)
    aggregator.fetch_from_spoonacular(num_recipes=150)
    
    # Save results
    df = aggregator.save_to_csv('recipe_database.csv')
    aggregator.print_summary()
    
    print("\n🎉 Recipe database created successfully!")
    print("\nNext steps:")
    print("1. Review recipe_database.csv")
    print("2. Run: python scripts/recipe_quality_filter.py")
    print("3. Import to Salesforce")
