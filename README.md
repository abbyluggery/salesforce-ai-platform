# Enterprise Salesforce Platform with AI Integration

A comprehensive Salesforce application featuring AI-powered job search automation, resume generation, interview preparation, wellness tracking, and meal planning - demonstrating enterprise-grade architecture across **143 Apex classes** and **42 custom objects**.

> **Last Updated:** December 27, 2025

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
┌────────────────────────────────────────────────────────────────────────┐
│                         SALESFORCE PLATFORM                            │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐             │
│  │   Chrome     │    │   PWA        │    │   Mobile     │             │
│  │  Extension   │───►│   Client     │───►│    App       │             │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘             │
│         │                   │                   │                      │
│         └───────────────────┼───────────────────┘                      │
│                             ▼                                          │
│                   ┌─────────────────┐                                  │
│                   │   REST APIs     │                                  │
│                   │  JobPostingAPI  │                                  │
│                   │  DailyRoutineAPI│                                  │
│                   │  MealPlanAPI    │                                  │
│                   └────────┬────────┘                                  │
│                            │                                           │
│         ┌──────────────────┼──────────────────┐                        │
│         ▼                  ▼                  ▼                        │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                │
│  │   Claude    │    │   Business  │    │   Batch &   │                │
│  │  API Layer  │    │    Logic    │    │  Scheduled  │                │
│  │             │    │             │    │    Jobs     │                │
│  └─────────────┘    └─────────────┘    └─────────────┘                │
│         │                  │                  │                        │
│         └──────────────────┼──────────────────┘                        │
│                            ▼                                           │
│                   ┌─────────────────┐                                  │
│                   │  Custom Objects │                                  │
│                   │   (42 objects)  │                                  │
│                   │   200+ fields   │                                  │
│                   └─────────────────┘                                  │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### Data Model

**Job Search Domain:**
- `Job_Posting__c` - Job listings with AI analysis scores, red flags, requirements extraction
- `Resume_Package__c` - Generated resumes with job-specific customization
- `Master_Resume__c` / `Master_Resume_Config__c` - Template management
- `Company_Research__c` - AI-generated company intelligence
- `Interview_Prep_Session__c` / `Interview_Response__c` - Practice sessions with feedback

**Wellness Domain:**
- `Daily_Routine__c` - Energy, mood, routine completion tracking
- Standard `Opportunity` - Application pipeline with custom stages

**Meal Planning Domain:**
- `Weekly_Meal_Plan__c` / `Planned_Meal__c` - Meal scheduling
- `Meal__c` / `Meal_Ingredient__c` - Recipe database with nutrition
- `Shopping_List__c` / `Shopping_List_Item__c` - Automated list generation
- `Store_Coupon__c` - Coupon matching for savings optimization

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
- **Flows:** 17 automation flows for reminders, summaries, check-ins
- **Scheduled:** `WalgreensOfferSyncScheduler`, `EnergyAdaptiveScheduler`
- **Queueable:** Async AI analysis, batch PDF generation

**Why:** Layered automation ensures the right tool for each use case - immediate (triggers), user-initiated (flows), and background (scheduled).

---

## Technical Statistics

| Metric | Count |
|--------|-------|
| Apex Classes | 143 |
| Custom Objects | 42 |
| Big Objects | 3 |
| Custom Fields | 200+ |
| Lightning Web Components | 11 |
| Flows | 22 |
| Triggers | 9 |
| Job API Adapters | 8 |
| Test Classes | 40+ |
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

**Job Search API Adapters:**
- `ArbeitnowAPIAdapter.cls` - Remote/EU jobs
- `RemoteOKAPIAdapter.cls` - Remote-first positions
- `JobicyAPIAdapter.cls` - Remote job aggregator
- `AdzunaAPIAdapter.cls` - 11-country job search
- `HimalayasAPIAdapter.cls` - Remote company database
- `JoobleAPIAdapter.cls` - Aggregated listings
- `TheirStackAPIAdapter.cls` - Tech company jobs
- `JobSearchService.cls` - Unified multi-API orchestrator

**Data Retention & Archival:**
- `MealIngredientArchiveService.cls` - Big Object archival
- `DataRetentionService.cls` - Automated cleanup
- `JobArchiveService.cls` - Job posting archival

### Lightning Web Components

- `holisticDashboard` - Unified view across all modules
- `interviewPrepAgent` - AI coaching interface
- `mealPlanCalendar` - Interactive meal scheduling
- `shoppingListManager` - Multi-store list management
- `wellnessTracker` - Daily check-in interface
- `energySchedulerUI` - Energy pattern visualization
- `jobSearchRunButton` - Manual job search trigger
- `resumeViewer` - Mobile-optimized resume display
- `jobPostingResearch` - Company research integration
- `dailyRoutineCard` - Quick routine check-in
- `mealNutritionChart` - Nutritional visualization

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

1. **Enterprise Architecture** - 42-object data model with Big Objects for archival, proper relationships, triggers, and automation
2. **AI Integration** - Production-ready Claude API integration with error handling and hallucination prevention
3. **Apex Expertise** - 143 classes covering REST APIs, Queueable, Batch, Scheduled, Invocable patterns
4. **Multi-API Integration** - 8 job search API adapters with unified orchestration
5. **Full-Stack Salesforce** - 11 LWC components, Visualforce PDF, Flow Builder, Reports/Dashboards
6. **Algorithm Design** - NLP parsing, fuzzy matching, scoring algorithms
7. **Data Management** - Big Object archival for storage optimization
8. **Test Coverage** - 75%+ coverage with positive, negative, and bulk testing

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
git clone https://github.com/abbyluggery/Full-ND-app-build.git

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
