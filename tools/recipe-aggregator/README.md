# Recipe Aggregator

A full-stack ETL pipeline that collects recipes from multiple APIs, validates data quality, and provides a React-based browser for search and filtering. Designed for integration with Salesforce meal planning systems.

---

## Overview

This system solves a common problem in meal planning: **building a quality recipe database without manual data entry**. It aggregates recipes from three free APIs, applies quality filtering for health-conscious meals, and exports in formats ready for enterprise systems.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    EXTERNAL APIS (Free Tier)                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                   │
│  │TheMealDB │  │  Edamam  │  │Spoonacular│                   │
│  │Unlimited │  │10K/month │  │ 150/day  │                    │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘                    │
└───────┼─────────────┼─────────────┼──────────────────────────┘
        │             │             │
        └─────────────┴──────┬──────┘
                             │
                    ┌────────▼────────┐
                    │ Recipe Aggregator│
                    │   (Python)       │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Quality Filter │
                    │  - Validation   │
                    │  - Deduplication│
                    │  - Scoring      │
                    └────────┬────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
                ▼            ▼            ▼
        ┌───────────┐ ┌──────────┐ ┌─────────────┐
        │    CSV    │ │Salesforce│ │ React App   │
        │  Export   │ │ Meal__c  │ │  (Browser)  │
        └───────────┘ └──────────┘ └─────────────┘
```

---

## Design Decisions

### 1. Multi-API Strategy

*Challenge:* No single free API provides enough recipes with complete nutrition data.

*Approach:* Aggregate from three sources with different rate limits:
- **TheMealDB** - Unlimited, no auth, but no nutrition data
- **Edamam** - 10,000/month, rich nutrition data
- **Spoonacular** - 150/day, detailed ingredients

*Why:* Combining sources yields 1,000+ recipes with 80%+ nutrition coverage. Each API's strengths compensate for others' weaknesses.

### 2. Quality Scoring Algorithm

*Challenge:* Raw API data includes unrealistic values and incomplete records.

*Approach:* Multi-stage quality filter:
1. **Completeness check** - Must have calories, protein, sodium
2. **Range validation** - 50-1200 cal, <5000mg sodium, <8hr cook time
3. **Heart-healthy scoring** - Sodium <600mg (+3), Fiber >5g (+1)
4. **Weeknight-friendly flag** - Total time <30 minutes

*Why:* Health-conscious users need trustworthy nutrition data. Quality scores enable smart filtering.

### 3. Normalized Deduplication

*Challenge:* Same recipe appears across multiple APIs with slight name variations.

*Approach:* Normalize names (lowercase, strip spaces/punctuation) and hash for comparison. First occurrence wins.

*Why:* Prevents duplicate meals in planning, maintains data integrity.

### 4. Salesforce-Ready Export

*Challenge:* Enterprise meal planning requires structured data in Salesforce.

*Approach:* Export format maps directly to Salesforce `Meal__c` custom object fields. CSV includes all computed fields (is_heart_healthy, quality_score).

*Why:* Zero transformation needed for Salesforce import. See [Salesforce Integration Guide](docs/SALESFORCE_INTEGRATION.md).

---

## Technical Stack

### Backend (Python)

| Component | Technology | Purpose |
|-----------|------------|---------|
| Core | Python 3.8+ | ETL orchestration |
| Data | pandas | Data manipulation |
| HTTP | requests | API calls |
| Env | python-dotenv | Configuration |
| Salesforce | simple-salesforce | Direct import |

### Frontend (React)

| Component | Technology | Purpose |
|-----------|------------|---------|
| Framework | React 18 | UI rendering |
| State | useState/useEffect | State management |
| Styling | CSS Custom Props | Theming |
| HTTP | Axios | Data fetching |

---

## Key Features

### Python Aggregator (`scripts/recipe_aggregator.py`)

- **500+ lines** of production-ready code
- Rate limiting with exponential backoff
- Automatic deduplication
- Quality scoring algorithm
- CSV and JSON export
- Comprehensive logging

### React Browser (`src/`)

- **Real-time search** across name, ingredients, cuisine
- **Advanced filters**: Calories, sodium, cook time sliders
- **Dietary filters**: Heart-healthy, diabetic-friendly, weeknight
- **Sort options**: Name, calories, time, protein
- **Responsive design**: Mobile, tablet, desktop
- **Statistics panel**: Total, filtered, match percentage

---

## Quick Start

### Python Setup

```bash
# Install dependencies
pip install -r requirements.txt

# Configure API keys
cp .env.example .env
# Edit .env with your keys

# Run aggregator
python scripts/recipe_aggregator.py
```

### React Setup

```bash
cd src
npm install
npm start
# Opens at http://localhost:3000
```

---

## API Rate Limits

| API | Free Tier | Rate Limit | Auth Required |
|-----|-----------|------------|---------------|
| TheMealDB | Unlimited | None | No |
| Edamam | 10,000/month | 10/minute | Yes (App ID + Key) |
| Spoonacular | 150/day | 1/second | Yes (API Key) |

---

## Output Formats

### CSV Export

```csv
name,calories,protein_g,carbs_g,fat_g,sodium_mg,is_heart_healthy,quality_score,...
"Grilled Salmon",350,42,5,18,380,true,8,...
```

### JSON Export (for React)

```json
{
  "recipes": [
    {
      "name": "Grilled Salmon",
      "calories": 350,
      "protein_g": 42,
      "is_heart_healthy": true,
      "quality_score": 8
    }
  ]
}
```

---

## Project Structure

```
recipe-aggregator/
├── scripts/
│   └── recipe_aggregator.py    # Main ETL script (500+ LOC)
├── src/
│   ├── App.js                  # React main app
│   ├── App.css                 # Main styles
│   ├── index.js                # React entry
│   ├── package.json            # React dependencies
│   └── components/
│       ├── RecipeCard.js       # Recipe display
│       ├── FilterPanel.js      # Advanced filters
│       ├── FilterPanel.css
│       ├── SearchBar.js        # Search & sort
│       ├── SearchBar.css
│       ├── StatsPanel.js       # Statistics
│       └── StatsPanel.css
├── public/
│   └── index.html              # HTML template
├── docs/
│   ├── ARCHITECTURE.md         # System design
│   ├── SETUP_GUIDE.md          # Detailed setup
│   └── SALESFORCE_INTEGRATION.md # SF field mapping
├── requirements.txt            # Python dependencies
├── .env.example                # Environment template
└── README.md
```

---

## What This Demonstrates

**For technical reviewers**, this project shows:

1. **Data Engineering** - ETL pipeline design, multi-source aggregation, deduplication
2. **API Integration** - Rate limiting, error handling, OAuth patterns
3. **Data Quality** - Validation, scoring algorithms, range filtering
4. **Full-Stack Development** - Python backend + React frontend
5. **Enterprise Integration** - Salesforce-ready data export

---

## Salesforce Integration

This aggregator is designed to feed the `Meal__c` object in Salesforce meal planning systems.

**Field Mapping Preview:**

| CSV Column | Salesforce Field | Type |
|------------|------------------|------|
| name | Name | Text |
| calories | Calories__c | Number |
| protein_g | Protein_g__c | Number |
| is_heart_healthy | Is_Heart_Healthy__c | Checkbox |

See [docs/SALESFORCE_INTEGRATION.md](docs/SALESFORCE_INTEGRATION.md) for complete mapping.

---

## Documentation

- [Architecture Overview](docs/ARCHITECTURE.md) - System design and data flow
- [Setup Guide](docs/SETUP_GUIDE.md) - Detailed installation instructions
- [Salesforce Integration](docs/SALESFORCE_INTEGRATION.md) - Field mapping for Meal__c

---

## License

MIT License - See LICENSE file for details.

---

## Author

**Abby Luggery**
- GitHub: [@abbyluggery](https://github.com/abbyluggery)
- LinkedIn: [linkedin.com/in/abby-luggery-02a4b815a](https://www.linkedin.com/in/abby-luggery-02a4b815a/)

---

*Building data pipelines that make healthy eating accessible.*
