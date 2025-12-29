# Enterprise Salesforce Platform with AI Integration

A comprehensive Salesforce application featuring AI-powered job search automation, resume generation, interview preparation, wellness tracking, and meal planning - demonstrating enterprise-grade architecture across **90 Apex classes** and **28 custom objects**.

> **Last Updated:** December 29, 2025

---

## Platform Overview

This platform combines multiple integrated systems built on Salesforce Lightning:

| Module | Purpose | Key Technologies |
|--------|---------|------------------|
| **Job Search** | AI-powered job analysis and application tracking | Claude API, REST endpoints, Queueable Apex |
| **Resume Generator** | Dynamic resume/cover letter creation with PDF export | Visualforce PDF, AI content generation |
| **Interview Prep** | AI coaching with STAR method analysis | Claude API, real-time feedback |
| **Wellness Tracker** | Energy-adaptive scheduling and mood tracking | Flow Builder, scheduled automation |
| **Meal Planning** | Recipe management with grocery optimization | NLP parsing, coupon matching algorithms |

---

## Architecture

### System Design

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SALESFORCE PLATFORM                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   EXTERNAL CLIENTS (Parallel Access)                                        │
│   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐                   │
│   │   Chrome     │   │     PWA      │   │   Mobile     │                   │
│   │  Extension   │   │   Client     │   │    App       │                   │
│   └──────┬───────┘   └──────┬───────┘   └──────┬───────┘                   │
│          │                  │                  │                            │
│          └──────────────────┼──────────────────┘                            │
│                             ▼                                               │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                        REST API LAYER                                │  │
│   │   JobPostingAPI  │  DailyRoutineAPI  │  MealPlanTodayAPI            │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                             │                                               │
│   ┌─────────────────────────┼─────────────────────────────────────────┐    │
│   │                         ▼                                          │    │
│   │   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐               │    │
│   │   │  Claude AI  │  │  Business   │  │   Async     │               │    │
│   │   │   Service   │  │   Logic     │  │ Processing  │               │    │
│   │   │             │  │  Services   │  │ (Queueable) │               │    │
│   │   └──────┬──────┘  └──────┬──────┘  └──────┬──────┘               │    │
│   │          │                │                │                       │    │
│   │          └────────────────┼────────────────┘                       │    │
│   │                           ▼                                        │    │
│   │   ┌─────────────────────────────────────────────────────────────┐ │    │
│   │   │                    TRIGGER LAYER                             │ │    │
│   │   │  OpportunityTrigger  │  JobPostingTrigger  │  MealTrigger   │ │    │
│   │   └─────────────────────────────────────────────────────────────┘ │    │
│   │                           │                                        │    │
│   │                           ▼                                        │    │
│   │   ┌─────────────────────────────────────────────────────────────┐ │    │
│   │   │                   DATA LAYER                                 │ │    │
│   │   │  28 Custom Objects  │  200+ Fields  │  Custom Metadata      │ │    │
│   │   └─────────────────────────────────────────────────────────────┘ │    │
│   │                      SERVICE LAYER                                 │    │
│   └────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                    SCHEDULED AUTOMATION                              │  │
│   │  Batch Jobs  │  Scheduled Apex  │  Flow Automation (18 Flows)       │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Data Model (Entity Relationship)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           JOB SEARCH DOMAIN                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Master_Resume__c ──────────┐                                              │
│         │                    │                                              │
│         ▼                    ▼                                              │
│   Master_Resume_Config__c    Job_Posting__c ◄───── Company_Research__c     │
│                                   │                                         │
│                                   ▼                                         │
│                           Resume_Package__c                                 │
│                                   │                                         │
│                                   ▼                                         │
│                             Opportunity (Standard)                          │
│                                   │                                         │
│                    ┌──────────────┴──────────────┐                          │
│                    ▼                             ▼                          │
│         Interview_Prep_Session__c      Interview_Response__c               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          MEAL PLANNING DOMAIN                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Meal__c ◄──────────────── Meal_Ingredient__c                             │
│      │                                                                      │
│      ▼                                                                      │
│   Planned_Meal__c ──────────► Weekly_Meal_Plan__c                          │
│      │                              │                                       │
│      └──────────────┬───────────────┘                                       │
│                     ▼                                                       │
│              Shopping_List__c                                               │
│                     │                                                       │
│                     ▼                                                       │
│           Shopping_List_Item__c ◄──────── Store_Coupon__c                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          WELLNESS DOMAIN                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Contact (Standard) ──────────► Daily_Routine__c                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Job Search Domain (10 Objects):**
| Object | Purpose |
|--------|---------|
| `Job_Posting__c` | Job listings with AI analysis scores, red flags, requirements |
| `Resume_Package__c` | Tailored resumes with job-specific customization |
| `Master_Resume__c` | Master resume template data |
| `Master_Resume_Config__c` | Search preferences and criteria |
| `Company_Research__c` | AI-generated company intelligence |
| `Interview_Prep_Session__c` | Interview practice sessions |
| `Interview_Response__c` | STAR-method interview answers with AI feedback |
| `Opportunity` | Application pipeline with custom stages |
| `Contact` | User profile and preferences |
| `Knowledge__kav` | Knowledge articles for interview prep |

**Meal Planning Domain (8 Objects):**
| Object | Purpose |
|--------|---------|
| `Meal__c` | Recipe database with instructions and nutrition |
| `Meal_Ingredient__c` | Parsed ingredients with quantities and units |
| `Weekly_Meal_Plan__c` | 7-14 day meal schedules |
| `Planned_Meal__c` | Individual meal slots (breakfast, lunch, dinner) |
| `Shopping_List__c` | Aggregated grocery lists by store |
| `Shopping_List_Item__c` | Line items with quantities and coupon matches |
| `Store_Coupon__c` | Coupon data for savings optimization |
| `Walgreens_API_Settings__c` | API configuration for coupon sync |

**Wellness Domain (1 Object):**
| Object | Purpose |
|--------|---------|
| `Daily_Routine__c` | Energy levels, mood, routine completion tracking |

**Journal Business Domain (4 Objects):**
| Object | Purpose |
|--------|---------|
| `Journal_Customer__c` | E-commerce customer records |
| `Journal_Product__c` | Product catalog |
| `Journal_Sale__c` | Sales transactions |
| `Marketing_Content__c` | Marketing materials and campaigns |

**Email Automation (2 Objects):**
| Object | Purpose |
|--------|---------|
| `Email_Journey__c` | Automated email sequences |
| `Email_Send__c` | Individual email send tracking |

**Custom Metadata (3 Types):**
| Metadata Type | Purpose |
|---------------|---------|
| `API_Configuration__mdt` | External API settings |
| `Lulu_API_Settings__mdt` | Print-on-demand API config |
| `Pinterest_API_Settings__mdt` | Pinterest integration config |

---

## Design Decisions

### 1. AI Integration Architecture

**Challenge:** Integrating external AI (Claude) with Salesforce while handling rate limits, timeouts, and maintaining data consistency.

**Approach:**
- `ClaudeAPIService.cls` - Centralized API client with retry logic and error handling
- `JobPostingAnalysisQueue.cls` - Queueable Apex for async processing
- Named Credentials for secure API key storage
- Structured JSON response parsing with 20+ hallucination prevention rules

**Why:** Queueable pattern prevents governor limit issues on bulk operations. Centralized service ensures consistent error handling across all AI features.

### 2. Neurodivergent-Friendly Scoring System

**Challenge:** Traditional job matching is subjective. Users need objective, explainable scores.

**Approach:**
- 0-100 scoring with explicit criteria weighting
- Red flag detection (unrealistic requirements, culture warning signs)
- Skills gap analysis with specific recommendations
- Energy-adaptive scheduling based on tracked patterns

**Why:** Quantified scores reduce decision fatigue. Explicit criteria make the AI's reasoning transparent and trustworthy.

### 3. PDF Generation Strategy

**Challenge:** Salesforce doesn't natively support complex PDF generation with dynamic content.

**Approach:**
- `ResumePDFGenerator.cls` + `ResumePDFController.cls` - Visualforce-based PDF rendering
- `ResumePDFGeneratorAsync.cls` - Async generation for large documents
- ATS-optimized formatting (clean structure, no tables, keyword placement)

**Why:** Visualforce PDF provides full control over layout. Async processing handles complex resumes without timeout issues.

### 4. NLP Ingredient Parsing

**Challenge:** Recipe ingredients come in varied formats ("2 cups flour", "flour, 2c", "2 C. all-purpose flour").

**Approach:**
- `IngredientParser.cls` - Regex-based parser handling 50+ variations
- Unit normalization (cups, c, C, cup → standardized)
- Fuzzy matching for coupon-to-ingredient pairing
- 90%+ accuracy on real-world recipe data

**Why:** Automated parsing eliminates manual data entry. Fuzzy matching maximizes coupon savings discovery.

### 5. Multi-Layer Automation

**Challenge:** Users need proactive assistance without manual triggering.

**Approach:**
- **Triggers:** `OpportunityCreationTrigger` - Auto-creates records on status change
- **Flows:** 18 automation flows for reminders, summaries, check-ins
- **Scheduled:** `WalgreensOfferSyncScheduler`, `EnergyAdaptiveScheduler`
- **Queueable:** Async AI analysis, batch PDF generation

**Why:** Layered automation ensures the right tool for each use case - immediate (triggers), user-initiated (flows), and background (scheduled).

---

## Technical Statistics

| Metric | Count |
|--------|-------|
| Apex Classes | 90 |
| Custom Objects | 28 |
| Custom Metadata Types | 3 |
| Custom Fields | 200+ |
| Lightning Web Components | 6 |
| Flows | 18 |
| Triggers | 6 |
| Test Classes | 30+ |
| Code Coverage | 75%+ |

### Key Apex Classes

**AI Integration:**
- `ClaudeAPIService.cls` - Universal AI client (500+ LOC)
- `JobPostingAnalyzer.cls` - Job fit analysis with scoring
- `QuestionGenerator.cls` - Interview question generation
- `SessionAnalyzer.cls` - Interview performance analysis
- `CompanyResearcher.cls` - Automated company research

**Resume System:**
- `ResumeGenerator.cls` - Dynamic resume creation (600+ LOC)
- `ResumePDFGenerator.cls` - PDF export with formatting
- `OpportunityResumeGeneratorInvocable.cls` - Flow-callable generation

**Wellness:**
- `EnergyAdaptiveScheduler.cls` - Pattern-based scheduling
- `DailyRoutineInvocable.cls` - Flow integration
- `HolisticDashboardController.cls` - Unified metrics view

**Meal Planning:**
- `MealPlanGenerator.cls` - 14-day planning algorithm (500+ LOC)
- `ShoppingListGenerator.cls` - Automated list creation (600+ LOC)
- `IngredientParser.cls` - NLP ingredient extraction
- `CouponMatcher.cls` - Fuzzy matching for savings

**External Integrations:**
- `WalgreensAPIService.cls` - Coupon sync
- `JobPostingAPI.cls` - REST endpoint for Chrome extension
- `DailyRoutineAPI.cls` - PWA sync endpoint

### Lightning Web Components

| Component | Purpose |
|-----------|---------|
| `holisticDashboard` | Unified view across all wellness modules |
| `interviewPrepAgent` | AI coaching interface with STAR method guidance |
| `mealPlanCalendar` | Interactive drag-and-drop meal scheduling |
| `shoppingListManager` | Multi-store list management with coupon integration |
| `wellnessTracker` | Daily energy and mood check-in interface |
| `energySchedulerUI` | Energy pattern visualization and recommendations |

---

## API Endpoints

### Job Posting API
```
POST /services/apexrest/jobposting

{
  "title": "Senior Salesforce Developer",
  "company": "Acme Corp",
  "description": "Job description...",
  "salaryMin": "120000",
  "salaryMax": "150000"
}

Response: { "success": true, "jobId": "a01...", "message": "Analyzing..." }
```

### Daily Routine API
```
POST /services/apexrest/routine/daily

{
  "date": "2025-12-13",
  "energyLevel": 7,
  "mood": "Good",
  "morningRoutineComplete": true
}
```

---

## Automation Flows

| Flow | Type | Trigger |
|------|------|---------|
| Weekly_Mood_Summary | Scheduled | Sunday 8 PM |
| Daily_Win_Reminder | Scheduled | Daily 7 PM |
| Daily_Wellness_Log | Screen | User-initiated |
| Generate_Meal_Plan_Wizard | Screen | User-initiated |
| Auto_Generate_Shopping_Lists | Record-Triggered | Meal plan creation |
| Interview_Prep_Flow | Screen | User-initiated |
| Check_Contact_Fields_Daily | Scheduled | Daily |

---

## What This Demonstrates

**For technical reviewers**, this project shows:

1. **Enterprise Architecture** - 28-object data model with proper relationships, triggers, and automation
2. **AI Integration** - Production-ready Claude API integration with error handling and hallucination prevention
3. **Apex Expertise** - 90 classes covering REST APIs, Queueable, Batch, Scheduled, Invocable patterns
4. **Full-Stack Salesforce** - 6 LWC components, Visualforce PDF, Flow Builder, Reports/Dashboards
5. **Algorithm Design** - NLP parsing, fuzzy matching, scoring algorithms
6. **Test Coverage** - 75%+ coverage with positive, negative, and bulk testing

---

## Development Approach

This system was architected using AI-assisted development workflows. I designed the data model, made all architectural decisions, and can explain every component:

- Why Queueable over Future for AI calls
- Why Visualforce over Lightning for PDF generation
- Why scheduled flows over time-based workflow
- How the scoring algorithm weights different factors
- How the NLP parser handles edge cases

---

## Installation

### Prerequisites
- Salesforce org (Developer, Sandbox, or Production)
- Claude AI API key from Anthropic
- Chrome browser (for extension)

### Quick Start
```bash
# Clone repository
git clone https://github.com/abbyluggery/salesforce-ai-platform.git

# Deploy to Salesforce
sf project deploy start --source-dir force-app --target-org YOUR_ORG

# Run tests
sf apex run test --test-level RunLocalTests --target-org YOUR_ORG
```

### Configuration
1. Create Named Credential for Claude API
2. Configure custom metadata for API settings
3. Activate flows in Setup → Flows
4. Schedule batch jobs via Execute Anonymous

---

## License

MIT License - See LICENSE file for details.

---

## Author

**Abby Luggery**
- GitHub: [@abbyluggery](https://github.com/abbyluggery)
- LinkedIn: [linkedin.com/in/abby-luggery-02a4b815a](https://www.linkedin.com/in/abby-luggery-02a4b815a/)

---

*Built for neurodivergent job seekers who need systems that actually work.*
