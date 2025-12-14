# 🚀 Complete Setup Guide

**Recipe Database Aggregator - From Zero to Running**

This guide will take you from a fresh clone to a fully running system in **30 minutes**.

---

## 📋 Prerequisites

Before starting, ensure you have:

- [ ] **Python 3.8+** installed ([python.org](https://python.org))
- [ ] **Node.js 16+** installed ([nodejs.org](https://nodejs.org))
- [ ] **Git** installed ([git-scm.com](https://git-scm.com))
- [ ] **Code editor** (VS Code recommended)

---

## 🎯 Step 1: Initial Setup (5 minutes)

### Clone or Download Project

```bash
# If from Git
git clone https://github.com/yourusername/recipe-database-project.git
cd recipe-database-project

# If downloaded as ZIP
unzip recipe-database-project.zip
cd recipe-database-project
```

### Create Virtual Environment (Python)

```bash
# Create virtual environment
python -m venv venv

# Activate it
# On Mac/Linux:
source venv/bin/activate

# On Windows:
venv\Scripts\activate
```

### Install Python Dependencies

```bash
pip install -r requirements.txt
```

**Expected output**: Successfully installed 15+ packages

---

## 🔑 Step 2: Get Free API Keys (10 minutes)

### Edamam Recipe API

1. Go to: [developer.edamam.com](https://developer.edamam.com/)
2. Click "Sign Up" → Choose "Recipe Search API"
3. Select **Free Developer** plan
4. Copy your `APP_ID` and `APP_KEY`

**Free Tier**: 10,000 requests/month, 10 requests/minute

### Spoonacular Food API

1. Go to: [spoonacular.com/food-api](https://spoonacular.com/food-api)
2. Click "Get Started"
3. Select **Free** plan
4. Copy your `API_KEY`

**Free Tier**: 150 requests/day

### Salesforce (Optional - for import features)

1. Sign up at: [developer.salesforce.com](https://developer.salesforce.com/)
2. Create a new Developer Edition org (free)
3. Go to: Setup → My Personal Information → Reset Security Token
4. Save your username, password, and security token

---

## ⚙️ Step 3: Configure Environment (2 minutes)

Create `.env` file from template:

```bash
cp .env.example .env
```

Edit `.env` with your API keys:

```bash
# Use your actual values here
EDAMAM_APP_ID=abc123xyz
EDAMAM_APP_KEY=def456uvw
SPOONACULAR_API_KEY=ghi789rst

# Optional - for Salesforce import
SF_USERNAME=your.email@example.com
SF_PASSWORD=yourpassword
SF_SECURITY_TOKEN=yourtoken123
```

---

## 🍳 Step 4: Collect Initial Recipes (5 minutes)

### Run First Collection

```bash
python scripts/recipe_aggregator.py
```

**What happens**:
- ✅ Fetches 100 recipes from TheMealDB
- ✅ Fetches 100 recipes from Edamam
- ✅ Fetches 150 recipes from Spoonacular
- ✅ Saves to `recipe_database.csv`

**Expected result**: ~350 unique recipes in 3-5 minutes

### Apply Quality Filters

```bash
python scripts/recipe_quality_filter.py
```

**What happens**:
- ✅ Validates nutrition data
- ✅ Removes unrealistic values
- ✅ Calculates quality scores
- ✅ Saves to `HIGH_QUALITY_RECIPES.csv`

**Expected result**: ~250-300 high-quality recipes

---

## 🌐 Step 5: Launch React App (5 minutes)

### Install React Dependencies

```bash
cd src/recipe-browser-app
npm install
```

### Create Sample Data File

```bash
# Go back to project root
cd ../..

# Create sample JSON from CSV
python << 'EOF'
import pandas as pd
import json

# Load high-quality recipes
df = pd.read_csv('HIGH_QUALITY_RECIPES.csv')

# Convert to list of dicts
recipes = df.to_dict('records')

# Save as JSON for React app
with open('src/recipe-browser-app/public/sample_recipes.json', 'w') as f:
    json.dump(recipes, f, indent=2)

print(f"✅ Created sample_recipes.json with {len(recipes)} recipes")
EOF
```

### Start Development Server

```bash
cd src/recipe-browser-app
npm start
```

**What happens**:
- ✅ Opens [http://localhost:3000](http://localhost:3000) automatically
- ✅ Shows recipe browser with search and filters
- ✅ Hot reloading enabled

---

## ✅ Step 6: Verify Everything Works

### Test Checklist

Run through this checklist:

**Python Scripts**:
- [ ] `recipe_aggregator.py` creates CSV with 300+ recipes
- [ ] `recipe_quality_filter.py` creates filtered CSV
- [ ] No errors in console/terminal

**React App**:
- [ ] App loads at localhost:3000
- [ ] Can see recipe cards displayed
- [ ] Search works (type "chicken")
- [ ] Filters update results
- [ ] Sort options work

---

## 🎓 Step 7: Next Steps (Optional)

### Import to Salesforce (if configured)

```bash
# From project root
python scripts/salesforce_importer.py
```

### Run Automated Daily Collection

```bash
# This runs continuously - press Ctrl+C to stop
python scripts/automated_recipe_collector.py
```

### Build React App for Production

```bash
cd src/recipe-browser-app
npm run build

# Creates optimized build in build/ directory
```

---

## 🔧 Troubleshooting

### "ModuleNotFoundError: No module named 'pandas'"

**Solution**: Make sure virtual environment is activated and dependencies installed

```bash
source venv/bin/activate  # Mac/Linux
pip install -r requirements.txt
```

### "API request failed with status 401"

**Solution**: Check your API keys in `.env` file

```bash
# View current .env
cat .env

# Make sure APP_ID and APP_KEY are correct
```

### "npm: command not found"

**Solution**: Install Node.js from [nodejs.org](https://nodejs.org)

### React app shows "Failed to compile"

**Solution**: Delete node_modules and reinstall

```bash
cd src/recipe-browser-app
rm -rf node_modules
npm install
npm start
```

### "Port 3000 is already in use"

**Solution**: Kill the process or use different port

```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill

# Or use different port
PORT=3001 npm start
```

---

## 📊 Expected Results

After completing setup, you should have:

**Files Created**:
- ✅ `recipe_database.csv` (~350 recipes)
- ✅ `HIGH_QUALITY_RECIPES.csv` (~250 recipes)
- ✅ `SALESFORCE_IMPORT_READY.csv` (~250 recipes)
- ✅ `src/recipe-browser-app/public/sample_recipes.json`

**Services Running**:
- ✅ React app at http://localhost:3000
- ✅ Working search and filter functionality
- ✅ Recipe cards displaying with nutrition data

**Portfolio Value**:
- ✅ Working end-to-end data pipeline
- ✅ Full-stack application (Python + React)
- ✅ Professional documentation
- ✅ Deployment-ready code

---

## 🎉 Success!

You now have a complete recipe database system running!

### Quick Commands Reference

```bash
# Collect more recipes
python scripts/recipe_aggregator.py

# Filter for quality
python scripts/recipe_quality_filter.py

# Import to Salesforce
python scripts/salesforce_importer.py

# Run React app
cd src/recipe-browser-app && npm start

# Build for production
cd src/recipe-browser-app && npm run build
```

---

## 📞 Need Help?

- **Check logs**: Look in `recipe_collector.log`
- **API limits**: Free tier limits reset daily
- **Python errors**: Verify virtual environment is active
- **React errors**: Check browser console (F12)

---

**Setup Time**: ~30 minutes  
**Next**: Review [README.md](../README.md) for portfolio presentation tips
