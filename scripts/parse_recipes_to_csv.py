"""
Parse RECIPES_DATABASE.md and create CSV for Salesforce Meal__c import
"""
import re
import csv

def parse_recipes_md(file_path):
    """Parse the RECIPES.md file and extract meal data"""
    meals = []

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split by recipe sections (marked by **Recipe Name**)
    recipe_sections = re.split(r'\n\*\*([^*]+)\*\*\n', content)

    current_meal = None

    for i in range(1, len(recipe_sections), 2):
        if i + 1 >= len(recipe_sections):
            break

        name = recipe_sections[i].strip()
        details = recipe_sections[i + 1]

        # Extract details
        cook_time_match = re.search(r'Cook Time:\s*(\d+)', details)
        servings_match = re.search(r'Servings:\s*(\d+)', details)
        dietary_match = re.search(r'Dietary:\s*([^\n]+)', details)
        sodium_match = re.search(r'Sodium:\s*<(\d+)mg', details)
        category_match = re.search(r'Category:\s*([^\n]+)', details)
        ingredients_match = re.search(r'Key Ingredients:\s*([^\n]+)', details)

        # Determine meal type from category or recipe name
        meal_type = 'Dinner'  # Default
        if category_match:
            category = category_match.group(1).lower()
            if 'breakfast' in category or 'brunch' in category:
                meal_type = 'Breakfast'
            elif 'snack' in category or 'dessert' in category:
                meal_type = 'Snack'
            elif 'smoothie' in name.lower():
                meal_type = 'Breakfast'

        # Determine dietary flags
        is_heart_healthy = False
        is_diabetic_friendly = False
        if dietary_match:
            dietary = dietary_match.group(1).lower()
            is_heart_healthy = 'heart-healthy' in dietary or 'heart healthy' in dietary
            is_diabetic_friendly = 'diabetic-friendly' in dietary or 'diabetic friendly' in dietary

        # Extract sodium (estimate if not provided)
        sodium = None
        if sodium_match:
            sodium = int(sodium_match.group(1))
        elif is_heart_healthy:
            sodium = 450  # Estimate for heart-healthy meals
        else:
            sodium = 600  # Conservative estimate

        # Build recipe content
        recipe_content = f"Cook Time: {cook_time_match.group(1) if cook_time_match else '30'} minutes\n"
        recipe_content += f"Servings: {servings_match.group(1) if servings_match else '4'}\n\n"
        if ingredients_match:
            recipe_content += f"Key Ingredients: {ingredients_match.group(1)}\n\n"
        recipe_content += "Full recipe details available in original database."

        meal = {
            'Name': name[:80],  # Salesforce name field limit
            'Cook_Time_Minutes__c': int(cook_time_match.group(1)) if cook_time_match else 30,
            'Sodium_mg__c': sodium,
            'Protein_g__c': 25,  # Estimate - can be updated later
            'Fiber_g__c': 5,     # Estimate - can be updated later
            'Meal_Type__c': meal_type,
            'Is_Heart_Healthy__c': 'TRUE' if is_heart_healthy else 'FALSE',
            'Is_Diabetic_Friendly__c': 'TRUE' if is_diabetic_friendly else 'FALSE',
            'Recipe_Content__c': recipe_content
        }

        meals.append(meal)

    return meals

def write_csv(meals, output_file):
    """Write meals to CSV file for Salesforce Data Loader"""
    fieldnames = [
        'Name',
        'Cook_Time_Minutes__c',
        'Sodium_mg__c',
        'Protein_g__c',
        'Fiber_g__c',
        'Meal_Type__c',
        'Is_Heart_Healthy__c',
        'Is_Diabetic_Friendly__c',
        'Recipe_Content__c'
    ]

    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(meals)

    print(f"Created CSV with {len(meals)} recipes")
    print(f"File: {output_file}")

if __name__ == '__main__':
    recipes_file = '../RECIPES_DATABASE.md'
    output_csv = '../data/Meal__c_import.csv'

    print("Parsing recipes...")
    meals = parse_recipes_md(recipes_file)

    print(f"Found {len(meals)} recipes")

    import os
    os.makedirs('../data', exist_ok=True)

    print("Writing CSV...")
    write_csv(meals, output_csv)

    print("\nDone! Ready to import into Salesforce")
    print(f"\nNext steps:")
    print(f"1. Open Salesforce Data Loader")
    print(f"2. Select 'Insert' operation")
    print(f"3. Select 'Meal__c' object")
    print(f"4. Choose file: {output_csv}")
    print(f"5. Map fields and insert!")
