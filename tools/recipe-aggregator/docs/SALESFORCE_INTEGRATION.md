# Salesforce Integration Guide

**Recipe Aggregator to Meal__c Field Mapping**

This document provides the complete field mapping between the Recipe Aggregator CSV output and the Salesforce `Meal__c` custom object.

---

## Overview

The Recipe Aggregator exports data in CSV format that maps directly to the `Meal__c` object in Salesforce. This enables bulk import of recipe data for meal planning applications.

**Target Object**: `Meal__c`
**Import Method**: Data Loader or Bulk API
**Record Volume**: Typically 300-1,000 recipes per collection run

---

## Complete Field Mapping

### Core Fields

| CSV Column | Salesforce Field | API Name | Type | Notes |
|------------|------------------|----------|------|-------|
| `name` | Meal Name | `Name` | Text(80) | Standard Name field |
| `source_api` | Source | `Source__c` | Picklist | TheMealDB, Edamam, Spoonacular |
| `cuisine_type` | Cuisine Type | `Cuisine_Type__c` | Picklist | Italian, Mexican, Asian, etc. |
| `meal_type` | Meal Type | `Meal_Type__c` | Picklist | Breakfast, Lunch, Dinner, Snack |
| `source_url` | Recipe URL | `Recipe_URL__c` | URL | Link to original recipe |

### Nutrition Fields

| CSV Column | Salesforce Field | API Name | Type | Range |
|------------|------------------|----------|------|-------|
| `calories` | Calories | `Calories__c` | Number(6,0) | 50-1200 |
| `protein_g` | Protein (g) | `Protein_g__c` | Number(5,1) | 0-100 |
| `carbs_g` | Carbohydrates (g) | `Carbs_g__c` | Number(5,1) | 0-200 |
| `fat_g` | Fat (g) | `Fat_g__c` | Number(5,1) | 0-100 |
| `fiber_g` | Fiber (g) | `Fiber_g__c` | Number(4,1) | 0-50 |
| `sodium_mg` | Sodium (mg) | `Sodium_mg__c` | Number(6,0) | 0-5000 |
| `sugar_g` | Sugar (g) | `Sugar_g__c` | Number(5,1) | 0-100 |
| `cholesterol_mg` | Cholesterol (mg) | `Cholesterol_mg__c` | Number(5,0) | 0-500 |
| `saturated_fat_g` | Saturated Fat (g) | `Saturated_Fat_g__c` | Number(4,1) | 0-50 |

### Time Fields

| CSV Column | Salesforce Field | API Name | Type | Notes |
|------------|------------------|----------|------|-------|
| `prep_time_minutes` | Prep Time (min) | `Prep_Time_Minutes__c` | Number(4,0) | 0-480 |
| `cook_time_minutes` | Cook Time (min) | `Cook_Time_Minutes__c` | Number(4,0) | 0-480 |
| `total_time_minutes` | Total Time (min) | `Total_Time_Minutes__c` | Number(4,0) | Formula or imported |

### Computed/Flag Fields

| CSV Column | Salesforce Field | API Name | Type | Criteria |
|------------|------------------|----------|------|----------|
| `is_heart_healthy` | Heart Healthy | `Is_Heart_Healthy__c` | Checkbox | Sodium <600mg, Fiber >5g |
| `is_diabetic_friendly` | Diabetic Friendly | `Is_Diabetic_Friendly__c` | Checkbox | Sugar <10g, Carbs <45g |
| `is_weeknight_friendly` | Weeknight Friendly | `Is_Weeknight_Friendly__c` | Checkbox | Total time <30 min |
| `quality_score` | Quality Score | `Quality_Score__c` | Number(2,0) | 1-10 scale |
| `servings` | Servings | `Servings__c` | Number(2,0) | 1-12 |

### Text Fields

| CSV Column | Salesforce Field | API Name | Type | Notes |
|------------|------------------|----------|------|-------|
| `ingredients` | Ingredients | `Ingredients__c` | Long Text Area | Comma-separated list |
| `instructions` | Instructions | `Instructions__c` | Long Text Area | Step-by-step |
| `image_url` | Image URL | `Image_URL__c` | URL | Recipe image |

---

## Data Loader Configuration

### Step 1: Prepare CSV

Ensure your CSV has headers matching the first column in the mapping tables above.

```csv
name,calories,protein_g,carbs_g,fat_g,sodium_mg,is_heart_healthy,quality_score
"Grilled Salmon",350,42,5,18,380,true,8
"Chicken Stir Fry",425,35,40,12,620,false,7
```

### Step 2: Data Loader Settings

1. Open Salesforce Data Loader
2. Select **Insert** operation
3. Choose object: `Meal__c`
4. Browse to your CSV file
5. Create field mapping (auto-match by name works for most fields)

### Step 3: Field Mapping File

Save as `meal_mapping.sdl`:

```
name=Name
calories=Calories__c
protein_g=Protein_g__c
carbs_g=Carbs_g__c
fat_g=Fat_g__c
fiber_g=Fiber_g__c
sodium_mg=Sodium_mg__c
sugar_g=Sugar_g__c
is_heart_healthy=Is_Heart_Healthy__c
is_diabetic_friendly=Is_Diabetic_Friendly__c
is_weeknight_friendly=Is_Weeknight_Friendly__c
quality_score=Quality_Score__c
prep_time_minutes=Prep_Time_Minutes__c
cook_time_minutes=Cook_Time_Minutes__c
total_time_minutes=Total_Time_Minutes__c
servings=Servings__c
cuisine_type=Cuisine_Type__c
meal_type=Meal_Type__c
source_api=Source__c
source_url=Recipe_URL__c
image_url=Image_URL__c
ingredients=Ingredients__c
instructions=Instructions__c
```

---

## Bulk API Integration (Apex)

For automated imports, use this Apex class pattern:

```apex
public class RecipeImportService {

    public static List<Meal__c> convertCSVToMeals(String csvContent) {
        List<Meal__c> meals = new List<Meal__c>();
        List<String> lines = csvContent.split('\n');

        // Skip header row
        for (Integer i = 1; i < lines.size(); i++) {
            List<String> fields = lines[i].split(',');

            Meal__c meal = new Meal__c(
                Name = fields[0].removeStart('"').removeEnd('"'),
                Calories__c = Decimal.valueOf(fields[1]),
                Protein_g__c = Decimal.valueOf(fields[2]),
                Carbs_g__c = Decimal.valueOf(fields[3]),
                Fat_g__c = Decimal.valueOf(fields[4]),
                Sodium_mg__c = Decimal.valueOf(fields[5]),
                Is_Heart_Healthy__c = Boolean.valueOf(fields[6]),
                Quality_Score__c = Decimal.valueOf(fields[7])
            );

            meals.add(meal);
        }

        return meals;
    }

    public static void importMeals(List<Meal__c> meals) {
        // Upsert based on Name to avoid duplicates
        Schema.SObjectField nameField = Meal__c.Fields.Name;
        Database.upsert(meals, nameField, false);
    }
}
```

---

## Data Quality Rules

The Recipe Aggregator enforces these quality rules before export:

### Validation Rules

| Field | Rule | Action |
|-------|------|--------|
| Calories | 50-1200 range | Reject if outside |
| Sodium | <5000mg | Reject if higher |
| Cook Time | <480 min (8 hours) | Reject if longer |
| Name | Not empty | Reject if blank |
| Protein | >0 for main dishes | Warning only |

### Deduplication

- Recipes are deduplicated by normalized name (lowercase, no punctuation)
- First occurrence wins when duplicates found across APIs
- Unique constraint recommended on `Name` field in Salesforce

---

## Sample Data

After running the aggregator, expect output like:

| name | calories | protein_g | sodium_mg | is_heart_healthy | quality_score |
|------|----------|-----------|-----------|------------------|---------------|
| Grilled Salmon with Herbs | 350 | 42 | 380 | true | 8 |
| Vegetable Stir Fry | 285 | 12 | 520 | true | 7 |
| Chicken Parmesan | 650 | 45 | 890 | false | 6 |
| Greek Salad | 220 | 8 | 450 | true | 9 |

---

## Salesforce Object Definition

For reference, the `Meal__c` object should have these field definitions:

```xml
<!-- Example field definition -->
<fields>
    <fullName>Calories__c</fullName>
    <label>Calories</label>
    <precision>6</precision>
    <scale>0</scale>
    <type>Number</type>
</fields>

<fields>
    <fullName>Is_Heart_Healthy__c</fullName>
    <label>Heart Healthy</label>
    <defaultValue>false</defaultValue>
    <type>Checkbox</type>
</fields>
```

See the full object definition at:
`salesforce-ai-platform/force-app/main/default/objects/Meal__c/`

---

## Integration Workflow

```
┌─────────────────┐
│ Recipe APIs     │
│ (3 sources)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Python          │
│ Aggregator      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Quality Filter  │
│ & Scoring       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ CSV Export      │
│ (mapped fields) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Salesforce      │
│ Data Loader     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Meal__c Object  │
│ (Ready for use) │
└─────────────────┘
```

---

## Related Documentation

- [Architecture Overview](ARCHITECTURE.md) - System design
- [Setup Guide](SETUP_GUIDE.md) - Installation instructions
- [Main README](../README.md) - Project overview

---

## Author

**Abby Luggery**
- GitHub: [@abbyluggery](https://github.com/abbyluggery)
- Salesforce Platform: [salesforce-ai-platform](https://github.com/abbyluggery/salesforce-ai-platform)
