# Recipe Data Import Guide

## What We've Created

✅ **116 Recipes Extracted** from your Family Meal Dietician database
✅ **CSV File Ready** for Salesforce Data Loader import
✅ **All Recipe Data Mapped** to Meal__c object fields

---

## Files Created

1. **RECIPES_DATABASE.md** - Your complete recipe database (830 lines)
2. **data/Meal__c_import.csv** - CSV file with 116 recipes ready to import
3. **scripts/parse_recipes_to_csv.py** - Python script to parse recipes

---

## Import Methods

### Option 1: Salesforce Data Loader (Recommended)

1. **Download Data Loader** (if not installed):
   - https://developer.salesforce.com/tools/data-loader

2. **Open Data Loader**:
   - Login to your org: abbyluggery179@agentforce.com

3. **Insert Records**:
   - Click "Insert"
   - Select Object: `Meal__c`
   - Choose CSV: `data/Meal__c_import.csv`

4. **Map Fields**:
   - Name → Name
   - Cook_Time_Minutes__c → Cook_Time_Minutes__c
   - Sodium_mg__c → Sodium_mg__c
   - Protein_g__c → Protein_g__c
   - Fiber_g__c → Fiber_g__c
   - Meal_Type__c → Meal_Type__c
   - Is_Heart_Healthy__c → Is_Heart_Healthy__c
   - Is_Diabetic_Friendly__c → Is_Diabetic_Friendly__c
   - Recipe_Content__c → Recipe_Content__c

5. **Finish**:
   - Review and insert
   - Check for errors
   - View success/error logs

---

### Option 2: Apex Anonymous Script

If you prefer to use Apex, run this script in Developer Console:

```apex
// Read CSV and create Meal records
List<Meal__c> meals = new List<Meal__c>();

// Sample meals (you would paste the full data here or use the Data Loader)
meals.add(new Meal__c(
    Name = 'Baked Lemon Pepper Chicken',
    Cook_Time_Minutes__c = 30,
    Sodium_mg__c = 450,
    Protein_g__c = 35,
    Fiber_g__c = 5,
    Meal_Type__c = 'Dinner',
    Is_Heart_Healthy__c = true,
    Is_Diabetic_Friendly__c = true,
    Recipe_Content__c = 'Cook Time: 30 minutes\nServings: 5\n\nKey Ingredients: Chicken breast, lemon, black pepper, herbs'
));

// ... add more meals ...

insert meals;
System.debug('Inserted ' + meals.size() + ' meals');
```

---

## What Each Recipe Includes

Each imported meal will have:

- **Name**: Recipe name (e.g., "Baked Salmon with Herb Butter")
- **Cook Time**: Minutes to prepare
- **Sodium**: mg per serving (heart-healthy compliance)
- **Protein**: grams per serving
- **Fiber**: grams per serving
- **Meal Type**: Breakfast, Lunch, Dinner, or Snack
- **Heart Healthy**: Boolean flag
- **Diabetic Friendly**: Boolean flag
- **Recipe Content**: Cook time, servings, key ingredients

---

## After Import

Once your 116 recipes are imported, you can:

1. **Create Weekly Meal Plans**:
   - Use the recipes to build Weekly_Meal_Plan__c records
   - Assign meals to specific days

2. **Generate Planned Meals**:
   - Link meals to dates via Planned_Meal__c

3. **Test the API**:
   - Call `/services/apexrest/mealplan/today`
   - Should return meals for today's date

4. **Connect PWA**:
   - Configure PWA with your Salesforce credentials
   - Pull today's meals into the app

---

## Verification Queries

After import, verify your data:

```sql
-- Count total meals
SELECT COUNT() FROM Meal__c

-- Count by meal type
SELECT Meal_Type__c, COUNT(Id)
FROM Meal__c
GROUP BY Meal_Type__c

-- Heart-healthy meals
SELECT COUNT() FROM Meal__c WHERE Is_Heart_Healthy__c = true

-- Quick weeknight meals
SELECT Name, Cook_Time_Minutes__c
FROM Meal__c
WHERE Cook_Time_Minutes__c <= 30
ORDER BY Cook_Time_Minutes__c
```

---

## Next Steps

1. **Import the 116 recipes** using Data Loader
2. **Create your first Weekly Meal Plan** record
3. **Add Planned Meals** for this week
4. **Test the API** to see meals returned
5. **Configure PWA** to display your meals

---

## Recipe Summary

From your Family Meal Dietician database:

- **116 recipes** total
- **Weeknight recipes** (≤30 min): ~50
- **Weekend recipes** (30-60 min): ~40
- **Slow cooker recipes**: ~26
- **All optimized** for heart-healthy, diabetic-friendly diets
- **Sodium levels** tracked for compliance

---

**Created**: November 5, 2025
**Source**: Family Meal Dietician Skill Package
**Status**: Ready to import! 🎉
