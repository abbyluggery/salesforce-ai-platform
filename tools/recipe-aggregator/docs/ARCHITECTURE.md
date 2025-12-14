# 🏗️ System Architecture

## Overview

The Recipe Database Aggregator is designed as a **modular, event-driven data pipeline** with clear separation of concerns.

---

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                    EXTERNAL APIS (Free Tier)                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │TheMealDB │  │  Edamam  │  │Spoonacular│  │   USDA   │    │
│  │Unlimited │  │10K/month │  │ 150/day  │  │Unlimited │    │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘    │
└───────┼─────────────┼─────────────┼─────────────┼───────────┘
        │             │             │             │
        └─────────────┴──────┬──────┴─────────────┘
                             │
                    ┌────────▼────────┐
                    │ API Rate Limiter│
                    │  & Scheduler    │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐   ┌────────────────┐   ┌──────────────┐
│Recipe         │   │Nutrition       │   │ Metadata     │
│Parser         │   │Calculator      │   │ Extractor    │
└───────┬───────┘   └────────┬───────┘   └──────┬───────┘
        │                    │                   │
        └────────────────────┼───────────────────┘
                             │
                    ┌────────▼────────┐
                    │  Deduplicator   │
                    │  (Name-based)   │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Quality Filter │
                    │  - Validation   │
                    │  - Scoring      │
                    └────────┬────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
                ▼            ▼            ▼
        ┌───────────┐ ┌──────────┐ ┌─────────────┐
        │Master CSV │ │Salesforce│ │ Analysis DB │
        │ Database  │ │ Meal__c  │ │  (Python)   │
        └─────┬─────┘ └────┬─────┘ └─────┬───────┘
              │            │             │
              └────────────┼─────────────┘
                           │
                  ┌────────▼────────┐
                  │  React Web App  │
                  │  (Recipe Browser)│
                  └─────────────────┘
```

---

## Component Design

### **1. Recipe Aggregator** (`recipe_aggregator.py`)

**Responsibility**: Fetch recipes from multiple APIs

**Key Classes**:
```python
class RecipeAggregator:
    - fetch_from_mealdb()
    - fetch_from_edamam()
    - fetch_from_spoonacular()
    - deduplicate_recipe()
    - save_to_csv()
```

**Design Patterns**:
- **Strategy Pattern**: Different fetching strategies per API
- **Factory Pattern**: Creates recipe objects from various formats
- **Template Method**: Common fetching workflow

**Rate Limiting**:
- TheMealDB: No limit, but 0.1s delay between requests
- Edamam: 10/min max, 6s delay
- Spoonacular: 150/day, 1s delay

---

### **2. Automated Collector** (`automated_recipe_collector.py`)

**Responsibility**: Schedule and orchestrate daily collection

**Key Classes**:
```python
class AutomatedRecipeCollector:
    - collect_daily_recipes()
    - merge_with_master()
    - create_salesforce_import()
    - cleanup_old_files()
    - generate_weekly_report()
```

**Scheduling Strategy**:
```
Monday:    Full collection (all APIs)
Tue/Thu/Sat: Spoonacular only (150 recipes)
Wed/Fri:   Edamam only (100 recipes)
Sunday:    TheMealDB + Weekly report
```

**Data Flow**:
1. Fetch from scheduled APIs
2. Save to daily_YYYYMMDD.csv
3. Merge with master_recipe_database.csv
4. Update SALESFORCE_IMPORT_READY.csv
5. Log results

---

### **3. Quality Filter** (`recipe_quality_filter.py`)

**Responsibility**: Ensure data quality and relevance

**Filtering Pipeline**:
```
Input: Raw recipes
  ↓
1. Nutrition Data Check (must have calories, protein, sodium)
  ↓
2. Realistic Values (50-1200 cal, <5000mg sodium, <8hr cook)
  ↓
3. Heart-Healthy Scoring (sodium<600 = +3, fiber>=5 = +1)
  ↓
4. Cook Time Balance (keep all quick, sample medium/long)
  ↓
5. Duplicate Removal (normalized name matching)
  ↓
6. Quality Scoring (0-10 scale)
  ↓
Output: High-quality recipes
```

**Quality Score Formula**:
```python
quality_score = (
    heart_score * 2 +              # Most important
    (1 if weeknight_friendly else 0) * 3 +
    (1 if balanced_macros else 0) * 2 +
    (1 if high_protein else 0) +
    (1 if low_sugar else 0)
)
```

---

### **4. Salesforce Importer** (`salesforce_importer.py`)

**Responsibility**: Bulk import to Salesforce

**Key Classes**:
```python
class SalesforceRecipeImporter:
    - get_existing_recipes()
    - import_recipes()
    - bulk_insert(batch_size=200)
```

**Import Strategy**:
1. Query existing recipe names from Salesforce
2. Filter out duplicates (case-insensitive match)
3. Batch import 200 records at a time
4. Log success/errors
5. Retry failed batches once

**Field Mapping**:
```
CSV Column → Salesforce Field
name → Name
calories → Calories__c
protein_g → Protein_g__c
... (18 total fields)
```

---

### **5. React Browser** (`recipe-browser-app/`)

**Responsibility**: User-friendly recipe search and display

**Component Hierarchy**:
```
<App>
  ├── <SearchBar>
  ├── <FilterPanel>
  │   ├── <NutritionFilters>
  │   ├── <CookTimeFilter>
  │   └── <DietaryFilters>
  ├── <RecipeGrid>
  │   └── <RecipeCard> × n
  └── <RecipeDetail>
```

**State Management**:
```javascript
{
  recipes: [],              // All loaded recipes
  filteredRecipes: [],      // After filters applied
  searchQuery: "",
  filters: {
    maxCalories: 1000,
    maxSodium: 600,
    maxCookTime: 60,
    heartHealthy: false,
    diabeticFriendly: false
  },
  sortBy: "quality_score"
}
```

---

## Data Models

### **Recipe Entity**

```typescript
interface Recipe {
  // Identification
  name: string;
  source: "TheMealDB" | "Edamam" | "Spoonacular";
  source_url: string;
  
  // Content
  ingredients: string;  // Pipe-delimited
  instructions: string;
  
  // Timing
  prep_time_minutes: number;
  cook_time_minutes: number;
  total_time_minutes: number;  // Computed
  
  // Nutrition (per serving)
  servings: number;
  calories: number;
  protein_g: number;
  carbs_g: number;
  fat_g: number;
  fiber_g: number;
  sugar_g: number;
  sodium_mg: number;
  
  // Classifications
  meal_type: "Breakfast" | "Lunch" | "Dinner" | "Snack";
  protein_type: "Chicken" | "Beef" | "Fish" | "Vegetarian" | etc;
  cuisine: string;
  difficulty: "Easy" | "Medium" | "Hard";
  
  // Computed Flags
  is_heart_healthy: boolean;      // sodium < 600
  is_diabetic_friendly: boolean;  // sugar < 10
  is_weeknight_friendly: boolean; // total_time <= 30
  
  // Quality Metrics
  quality_score: number;  // 0-10
  heart_score: number;    // 0-6
}
```

---

## API Integration

### **TheMealDB API**

**Endpoints Used**:
```
GET /api/json/v1/1/categories.php
GET /api/json/v1/1/filter.php?c={category}
GET /api/json/v1/1/lookup.php?i={id}
```

**Rate Limit**: Unlimited (donate for faster speeds)
**Authentication**: None required
**Response Format**: JSON

### **Edamam Recipe API**

**Endpoint**:
```
GET /api/recipes/v2
```

**Parameters**:
```
type: "public"
q: {search_term}
app_id: {your_app_id}
app_key: {your_app_key}
to: 10
```

**Rate Limit**: 10 requests/min, 10,000/month
**Authentication**: App ID + App Key
**Response Format**: JSON with embedded nutrition

### **Spoonacular API**

**Endpoint**:
```
GET /recipes/complexSearch
```

**Parameters**:
```
apiKey: {your_key}
number: 10
addRecipeNutrition: true
fillIngredients: true
```

**Rate Limit**: 150 points/day (1 point = 1 request)
**Authentication**: API Key
**Response Format**: JSON with detailed nutrition

---

## Deployment Architecture

### **Local Development**

```
┌─────────────────┐
│  Developer      │
│  Laptop         │
│  ┌───────────┐  │
│  │ Python    │  │
│  │ Scripts   │  │
│  └─────┬─────┘  │
│        │        │
│  ┌─────▼─────┐  │
│  │ React Dev │  │
│  │ Server    │  │
│  └───────────┘  │
└─────────────────┘
```

### **Production (Future)**

```
┌──────────────┐    ┌──────────────┐
│  AWS Lambda  │    │   Netlify    │
│  (Python     │    │   (React)    │
│   Collector) │    │              │
└──────┬───────┘    └──────┬───────┘
       │                   │
       ▼                   ▼
┌──────────────────────────────┐
│       Salesforce             │
│       (Data Storage)         │
└──────────────────────────────┘
```

---

## Security Considerations

### **API Key Management**
- Store in `.env` file (never commit)
- Use environment variables in production
- Rotate keys quarterly

### **Data Privacy**
- No personal user data collected
- Recipe sources properly attributed
- Respect API Terms of Service

### **Salesforce Security**
- Use security token for API access
- Implement IP restrictions
- Enable 2FA on account

---

## Performance Optimization

### **Collection Performance**
- Parallel API calls (future enhancement)
- Batch processing (200 records)
- Caching strategy (daily vs. weekly)

### **Current Metrics**:
- API Response Time: <500ms avg
- Processing Time: ~2 min for 150 recipes
- Import Time: ~30 sec for 200 records

### **Future Optimizations**:
- Redis caching for duplicate detection
- Async/await for concurrent API calls
- Database indexing on recipe names

---

## Error Handling Strategy

### **Retry Logic**:
```python
max_retries = 3
for attempt in range(max_retries):
    try:
        response = api_call()
        break
    except RequestException:
        if attempt == max_retries - 1:
            log_error()
        time.sleep(2 ** attempt)  # Exponential backoff
```

### **Fallback Strategy**:
- API fails → Skip to next source
- Salesforce fails → Save to CSV for manual import
- Quality filter fails → Use unfiltered data

---

## Monitoring & Logging

### **Log Levels**:
```python
logging.INFO:  Daily collection summaries
logging.WARNING: Skipped recipes, API limits hit
logging.ERROR: API failures, import errors
```

### **Log Files**:
- `recipe_collector.log` - Daily collection logs
- `import_log_YYYYMMDD_HHMMSS.txt` - Import results
- `weekly_report_YYYYMMDD.txt` - Weekly summaries

---

## Testing Strategy

### **Unit Tests**:
- Recipe deduplication logic
- Nutrition validation
- Quality score calculation

### **Integration Tests**:
- API mocking for reliable tests
- Salesforce sandbox import
- End-to-end pipeline

### **Manual Testing**:
- Weekly review of collected recipes
- Spot-check nutrition accuracy
- UI/UX testing on React app

---

## Future Enhancements

1. **Machine Learning**:
   - Recipe recommendation engine
   - Automatic ingredient parsing
   - Cuisine classification

2. **Advanced Features**:
   - Meal plan generator (7-day plans)
   - Shopping list creation
   - Nutrition goal tracking

3. **Scalability**:
   - Move to cloud functions (AWS Lambda)
   - Implement caching (Redis)
   - Add database (PostgreSQL)

4. **Mobile**:
   - React Native app
   - Offline support
   - Photo upload for recipes

---

**Last Updated**: December 2025
**Version**: 1.0.0
