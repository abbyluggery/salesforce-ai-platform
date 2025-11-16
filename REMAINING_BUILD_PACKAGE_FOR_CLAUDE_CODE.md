# Remaining Build Package for Claude Code
## NeuroThrive Holistic Life Assistant - Missing Components

**Created:** 2025-11-15
**Target Org:** abbyluggery179@agentforce.com
**Project Completion:** 88% → Target: 100%
**Estimated Remaining Work:** 20-30 hours

---

## 📋 **EXECUTIVE SUMMARY**

This document contains a complete inventory of remaining work needed to finish the NeuroThrive platform. Use this as a Claude Code sprint package to deploy your credits strategically.

**Current Status:**
- ✅ **Job Search Platform:** 95% complete
- ⚠️ **Meal Planning Platform:** 85% complete (blocked by recipe data cleanup)
- ⚠️ **Wellness Tracking:** 90% complete (OAuth setup needed)
- ✅ **Coupon Platform:** 90% complete

**Critical Path Items:**
1. Fix remaining wellness flow XML errors (2 hours)
2. Complete OAuth setup for PWA sync (1 hour manual, 2 hours testing)
3. Build unified dashboard (8-12 hours)
4. Deploy and test all remaining LWC components (6-8 hours)
5. Recipe data cleanup (user task - 2-3 hours)

---

## 🚨 **CRITICAL BLOCKERS (Must Fix First)**

### 1. Wellness Flows - XML Errors

**Status:** 2 of 3 flows failing deployment

#### Flow 1: Weekly_Mood_Summary.flow
**Error:** `Element actionCalls is duplicated at this location in type Flow (134:16)`
**File:** `force-app/main/default/flows/Weekly_Mood_Summary.flow-meta.xml`
**Fix Required:** Edit XML to remove duplicate `<actionCalls>` element at line 134

**Claude Code Task:**
```
Read force-app/main/default/flows/Weekly_Mood_Summary.flow-meta.xml
Identify and remove the duplicate <actionCalls> element
Ensure flow has valid XML structure
Test deployment
```

#### Flow 2: Daily_Win_Reminder.flow
**Error:** `invalid flow element Get_Todays_Wins`
**File:** `force-app/main/default/flows/Daily_Win_Reminder.flow-meta.xml`
**Fix Required:** Flow references missing element "Get_Todays_Wins"

**Claude Code Task:**
```
Read force-app/main/default/flows/Daily_Win_Reminder.flow-meta.xml
Identify what Get_Todays_Wins element should do (likely query Win_Entry__c records for today)
Either:
  A) Create the missing element with proper SOQL query
  B) Update flow to reference a different existing element
  C) Rebuild the flow logic if broken
Test deployment
```

### 2. HolisticDashboardController - Deployment Failure

**Status:** Failing with MoodTrackerService reference error
**Error:** `Variable does not exist: MoodTrackerService (381:32)`
**File:** `force-app/main/default/classes/HolisticDashboardController.cls`

**Claude Code Task:**
```
Read force-app/main/default/classes/HolisticDashboardController.cls
Verify MoodTrackerService.cls exists and is deployed
Check for:
  - Typos in class name
  - Missing @AuraEnabled annotations
  - Incorrect method references
  - Access modifier issues
Fix and redeploy
```

---

## 🎯 **PRIORITY 1: Core Functionality Completion**

### A. Lightning Web Components (6-8 hours)

All LWC components exist in GitHub but need deployment testing and fixes.

#### 1. holisticDashboard LWC
**Location:** `force-app/main/default/lwc/holisticDashboard/`
**Status:** Pulled from GitHub, not yet deployed
**Dependencies:** HolisticDashboardController.cls (currently broken)

**Claude Code Task:**
```
Fix HolisticDashboardController.cls first (see blocker #2)
Deploy holisticDashboard LWC:
  - holisticDashboard.html
  - holisticDashboard.js
  - holisticDashboard.js-meta.xml
  - holisticDashboard.css
Test deployment
Add component to Lightning App Builder
Test data loading from controller
Fix any console errors
```

**Expected Features:**
- Unified view of mood, energy, meals, and job search progress
- Chart.js integration for data visualization
- Real-time data refresh
- Mobile-responsive layout

#### 2. mealPlanCalendar LWC
**Location:** `force-app/main/default/lwc/mealPlanCalendar/`
**Status:** Pulled from GitHub, needs deployment + testing

**Claude Code Task:**
```
Deploy mealPlanCalendar LWC
Test on Weekly_Meal_Plan__c record page
Verify features:
  - Calendar view of weekly meals
  - Drag-drop meal reordering
  - Quick meal swap functionality
  - Shopping list preview
Fix any bugs found during testing
```

#### 3. shoppingListManager LWC
**Location:** `force-app/main/default/lwc/shoppingListManager/`
**Status:** Pulled from GitHub, needs deployment + testing

**Claude Code Task:**
```
Deploy shoppingListManager LWC
Test on Shopping_List__c record page
Verify features:
  - Ingredient grouping by store aisle
  - Coupon matching display
  - Check-off items as purchased
  - Savings calculator
Fix any bugs
```

#### 4. interviewPrepAgent LWC
**Location:** `force-app/main/default/lwc/interviewPrepAgent/`
**Status:** Backend 95% complete, LWC needs deployment

**Claude Code Task:**
```
Deploy interviewPrepAgent LWC
Add to Opportunity record page
Test workflow:
  1. Start interview session
  2. Generate practice questions (uses Claude AI)
  3. Record responses
  4. Get AI feedback on STAR method
  5. View company research
Fix any API integration issues
```

### B. Test Classes (4-6 hours)

**Status:** 11 wellness test classes pulled from GitHub, ready to deploy

**Files to Deploy:**
```
force-app/main/default/classes/
├── DailyRoutineAPITest.cls
├── DailyRoutineInvocableTest.cls
├── EnergyAdaptiveSchedulerTest.cls
├── HolisticDashboardControllerTest.cls
├── ImposterSyndromeAnalyzerTest.cls
├── MoodInsightsInvocableTest.cls
├── MoodTrackerServiceTest.cls
├── NegativeThoughtDetectorTest.cls
├── RoutineTaskTimerServiceTest.cls
├── TherapySessionManagerTest.cls
└── WinParserServiceTest.cls
```

**Claude Code Task:**
```
Deploy all 11 test classes
Run all tests: sf apex run test --test-level RunLocalTests
Current test results: 54 passing tests (before wellness tests)
Target: 75%+ code coverage
Fix any failing tests
Document final coverage percentage
```

---

## 🎯 **PRIORITY 2: Integration & Polish**

### A. PWA ↔ Salesforce OAuth Setup (1 hour manual + 2 hours testing)

**Status:** Backend 100% deployed, OAuth manual setup pending

**Manual Steps Required (USER):**
1. Setup → App Manager → New Connected App
2. Configure OAuth settings:
   - Callback URL: `https://abbyluggery179.my.salesforce.com/services/oauth2/callback`
   - OAuth Scopes: api, refresh_token, offline_access
   - Enable: "Require Secret for Web Server Flow"
3. Copy Consumer Key and Consumer Secret
4. Setup → CORS → Add: `https://abbyluggery179.my.salesforce.com`
5. Setup → Remote Site Settings → Add: `https://api.anthropic.com`

**Claude Code Task (After Manual Setup):**
```
Update neurothrive-pwa/js/salesforce-api.js with:
  - Consumer Key from Connected App
  - Consumer Secret from Connected App
  - Instance URL

Test OAuth flow:
  1. Open PWA in browser
  2. Click login
  3. Authorize Salesforce
  4. Verify token storage
  5. Test API call: getDailyRoutine('2025-11-15')
  6. Test upsertDailyRoutine()

Test offline sync:
  1. Save routine while online
  2. Disconnect internet
  3. Make changes
  4. Reconnect
  5. Verify auto-sync

Document any errors and fixes
```

**Files Involved:**
- `neurothrive-pwa/js/salesforce-api.js` (383 lines)
- `neurothrive-pwa/js/sync-manager.js` (407 lines)
- `force-app/main/default/classes/DailyRoutineAPI.cls` (329 lines)

### B. Unified Dashboard Build (8-12 hours)

**Status:** Not started - HIGHEST IMPACT FEATURE

**Requirements:**
- Lightning App page showing all 4 platforms in one view
- Real-time data from Job Search, Meals, Wellness, and Coupons
- Chart.js visualizations
- Mobile-responsive
- Action buttons for quick tasks

**Claude Code Task:**
```
Create Lightning App: "NeuroThrive Dashboard"

Components to build:
1. jobSearchSummaryCard.lwc
   - Active applications count
   - Upcoming interviews
   - Recent AI insights
   - Quick actions: Add Job, Research Company

2. mealPlanningSummaryCard.lwc
   - This week's meal plan
   - Shopping list preview
   - Coupon savings total
   - Quick actions: Generate Plan, View Recipes

3. wellnessSummaryCard.lwc
   - Today's mood/energy
   - Weekly trend chart
   - Wins logged this week
   - Quick actions: Log Mood, Add Win

4. savingsSummaryCard.lwc
   - Total savings this month
   - Coupons expiring soon
   - Best deals this week
   - Quick actions: Browse Coupons

5. unifiedDashboard.lwc (parent container)
   - Grid layout manager
   - Date range selector
   - Sync status indicator
   - Settings menu

Deploy and configure:
  - Create Lightning App Page
  - Add all components
  - Set up page-level filters
  - Configure security permissions
  - Test on desktop and mobile
```

**Data Sources:**
- Job_Posting__c, Opportunity (job search)
- Weekly_Meal_Plan__c, Meal__c, Recipe__c (meals)
- Daily_Routine__c, Mood_Entry__c, Win_Entry__c (wellness)
- Store_Coupon__c, Shopping_List__c (savings)

### C. Cross-Platform Reports & Dashboards (4-6 hours)

**Status:** Basic reports exist, need holistic views

**Claude Code Task:**
```
Create Lightning Report Types:
1. "Job Search + Wellness Correlation"
   - Opportunities with Daily_Routine__c (join on date)
   - Show: Mood score trends during job search

2. "Meal Planning + Savings Analysis"
   - Meal plans with matched coupons
   - Show: Actual savings vs potential savings

3. "Weekly Holistic Summary"
   - All platforms combined by week
   - Show: Progress across all life areas

Create Lightning Dashboard:
"NeuroThrive Insights Dashboard"
  - 10-12 components
  - Charts showing trends across platforms
  - KPIs: Mood average, Job apps sent, Meals planned, $ saved
  - Filters: Date range, Category

Build in Setup → Reports → New Report Type
Build in Setup → Dashboards → New Dashboard
```

---

## 🎯 **PRIORITY 3: Email & Automation**

### A. Flow Activation & Testing (2-3 hours)

**Status:** 16 flows built, activation status unknown

**Flows to Verify:**
```
1. Generate_Resume_Package_for_Opportunity ✅ (confirmed working)
2. Generate_Meal_Plan_Wizard ⏳ (needs testing)
3. Auto_Generate_Shopping_Lists ⏳ (needs testing)
4. Daily_Wellness_Log ✅ (deployed Nov 15)
5. Weekly_Mood_Summary ❌ (XML error - see blocker #1)
6. Daily_Win_Reminder ❌ (XML error - see blocker #1)
7. Opportunity_Research_Company ✅ (deployed Nov 13)
8. OpportunityInterviewSync (trigger-based) ✅
9. [7 more flows to identify and test]
```

**Claude Code Task:**
```
Query all flows in org:
sf project retrieve start --metadata Flow --target-org abbyluggery179@agentforce.com

For each flow:
  1. Check activation status (Active/Draft)
  2. Activate if in Draft
  3. Test end-to-end
  4. Document any errors
  5. Fix errors found
  6. Retest

Create test scenarios document for each flow
```

### B. Email Templates Enhancement (2-3 hours)

**Status:** 5 text-only email templates deployed, need HTML versions

**Existing Templates:**
- Initial_Application_Email.email
- Follow_Up_After_Application.email
- Thank_You_After_Phone_Screen.email
- Thank_You_After_Technical_Interview.email
- Thank_You_After_Final_Interview.email

**Claude Code Task:**
```
Create HTML versions with:
  - Professional styling
  - Merge fields for personalization
  - Company logo placeholder
  - Mobile-responsive design
  - Unsubscribe footer

Add 3 new templates:
  - Weekly_Meal_Plan_Summary.email (sent Sundays)
  - Wellness_Check_In.email (sent daily if mood < 5)
  - Coupon_Expiration_Alert.email (sent 3 days before expiry)

Test email sends from flows
```

### C. Scheduled Jobs Setup (1 hour)

**Status:** Schedulers built but not activated

**Jobs to Schedule:**

```apex
// 1. Walgreens Coupon Sync - Every Sunday 6:00 AM
String cronExp = '0 0 6 ? * SUN';
System.schedule('Walgreens Weekly Coupon Sync', cronExp, new WalgreensOfferSyncScheduler());

// 2. Weekly Mood Summary - Every Sunday 8:00 PM
String cronExp = '0 0 20 ? * SUN';
System.schedule('Weekly Mood Summary Email', cronExp, new MoodSummaryScheduler());

// 3. Daily Win Reminder - Every day 7:00 PM
String cronExp = '0 0 19 * * ?';
System.schedule('Daily Win Reminder', cronExp, new DailyWinReminderScheduler());

// 4. Coupon Expiration Check - Every day 9:00 AM
String cronExp = '0 0 9 * * ?';
System.schedule('Coupon Expiration Alerts', cronExp, new CouponExpirationScheduler());
```

**Claude Code Task:**
```
Verify all scheduler classes exist
If missing, create them
Schedule all jobs via Execute Anonymous
Test job execution by running immediately
Document scheduled job IDs
```

---

## 🎯 **PRIORITY 4: Manual Configuration Tasks**

These require user interaction and cannot be fully automated by Claude Code.

### A. Quick Action Setup (30 minutes - USER)

**Company Research Button on Opportunity:**
Follow guide: [QUICK_ACTION_SETUP_GUIDE.md](QUICK_ACTION_SETUP_GUIDE.md)

1. Setup → Object Manager → Opportunity → Buttons, Links, and Actions
2. New Action → "Research Company"
3. Flow: Opportunity_Research_Company
4. Add to page layout

### B. Recipe Data Cleanup (2-3 hours - USER)

**Status:** CRITICAL BLOCKER for meal planning

**Problem:** 63 of 116 recipes have mismatched ingredient/instruction data

**Tools Created:**
- `data/CLEAR_BAD_DATA.csv` - Recipes to review
- `MISMATCH_REPORT.md` - Detailed errors
- `IMPORT_FIX_INSTRUCTIONS.md` - Fix steps

**User Task:**
1. Open `data/ALL_21_RECIPES_FIXED_Reviewed.xlsx`
2. Cross-reference with `MISMATCH_REPORT.md`
3. Fix mismatched recipes
4. Export corrected CSV
5. Use Data Loader to update Recipe__c records

### C. Permission Sets & Sharing (1-2 hours)

**Status:** Field-level security and object permissions need configuration

**User Task:**
1. Create Permission Set: "NeuroThrive Full Access"
2. Grant access to all custom objects:
   - Job_Posting__c, Opportunity (extended)
   - Recipe__c, Meal__c, Meal_Ingredient__c, Weekly_Meal_Plan__c
   - Store_Coupon__c, Shopping_List__c, Shopping_List_Item__c
   - Daily_Routine__c, Mood_Entry__c, Win_Entry__c, Imposter_Syndrome_Session__c
   - Resume_Package__c, Master_Resume__c, Interview_Prep_Session__c
3. Grant CRUD permissions on all fields
4. Assign to user(s)

### D. Field History Tracking (30 minutes)

**User Task:**
Setup → Object Manager → [Object] → Fields & Relationships → Set History Tracking

**Enable tracking on:**
- Opportunity.StageName
- Job_Posting__c.Status__c
- Weekly_Meal_Plan__c.Status__c
- Daily_Routine__c.Mood__c

---

## 🎯 **PRIORITY 5: AppExchange Readiness (Optional)**

If pursuing AppExchange listing:

### A. Managed Package Creation (8-12 hours)

**Claude Code Task:**
```
Create namespace: "neurothrive" or "neurothriveapp"

Configure managed package:
  - Package name: NeuroThrive Holistic Life Assistant
  - Version: 1.0.0
  - Description: AI-powered platform for job search, meal planning, wellness tracking, and savings optimization

Add all components to package:
  - Objects (18)
  - Classes (82)
  - LWC (4+)
  - Flows (16)
  - Reports (18)
  - Dashboards (2+)

Create installation guide
Test install in scratch org
```

### B. License Validation (4-6 hours)

**Claude Code Task:**
```
Create License Management Architecture:

1. Custom Object: License__c
   - License_Key__c (Text, Unique)
   - Valid_Until__c (Date)
   - User_Limit__c (Number)
   - Active_Users__c (Number)
   - Account__c (Lookup)

2. Apex Class: LicenseValidator.cls
   - validateLicense(String key)
   - checkExpiration()
   - enforceUserLimit()

3. Trigger: LicenseValidationTrigger
   - Prevent object access if license invalid
   - Show error messages

4. Visualforce Page: LicenseSetup.page
   - Enter license key
   - View license status
   - Renewal link

Test license enforcement
```

### C. Security Review Preparation (6-8 hours)

**Claude Code Task:**
```
Run Security Scanner:
sf scanner run --target "force-app" --format html --outfile security-report.html

Fix all Critical and High issues:
  - SOQL injection risks
  - XSS vulnerabilities
  - CRUD/FLS violations
  - Hardcoded credentials

Implement:
  - Security.stripInaccessible() for all queries
  - WITH SECURITY_ENFORCED in SOQL
  - escapeSingleQuotes() for dynamic SOQL
  - Schema.sObjectType security checks

Document security improvements
```

---

## 📦 **DEPLOYMENT PACKAGE SUMMARY**

### Files Ready to Deploy (Already Created)

**Apex Classes (82 total):**
- ✅ 72 deployed
- ⏳ 11 test classes pending
- ❌ 1 broken (HolisticDashboardController)

**Lightning Web Components (4 total):**
- ⏳ holisticDashboard
- ⏳ mealPlanCalendar
- ⏳ shoppingListManager
- ⏳ interviewPrepAgent

**Flows (16 total):**
- ✅ 13 working
- ❌ 2 broken (XML errors)
- ⏳ 1 needs activation testing

**Custom Objects (18 total):**
- ✅ All deployed

**Custom Fields (100+ total):**
- ✅ All deployed

---

## 🛠️ **CLAUDE CODE SPRINT PLAN**

### Session 1: Fix Critical Blockers (3-4 hours)
```
1. Fix Weekly_Mood_Summary.flow XML (remove duplicate element)
2. Fix Daily_Win_Reminder.flow (create missing element or rebuild)
3. Fix HolisticDashboardController.cls (resolve MoodTrackerService reference)
4. Deploy holisticDashboard LWC
5. Test all fixes
```

### Session 2: Deploy & Test LWC Components (4-6 hours)
```
1. Deploy mealPlanCalendar LWC + test
2. Deploy shoppingListManager LWC + test
3. Deploy interviewPrepAgent LWC + test
4. Fix any bugs found during testing
5. Create Lightning App pages for each component
```

### Session 3: Test Coverage & Quality (4-6 hours)
```
1. Deploy all 11 wellness test classes
2. Run full test suite
3. Fix failing tests
4. Achieve 75%+ coverage
5. Document test results
```

### Session 4: Unified Dashboard Build (8-12 hours)
```
1. Create 5 summary card LWC components
2. Create parent unifiedDashboard LWC
3. Create Apex controllers for each card
4. Build Lightning App page
5. Test and polish
```

### Session 5: Integration & Automation (4-6 hours)
```
1. Complete OAuth setup and testing
2. Create cross-platform reports
3. Build NeuroThrive Insights Dashboard
4. Activate and test all flows
5. Schedule batch jobs
```

### Session 6: Polish & Documentation (3-4 hours)
```
1. Create HTML email templates
2. Test email automation end-to-end
3. Run security scanner and fix issues
4. Create user documentation
5. Final end-to-end testing
```

**Total Estimated Time: 26-38 hours**

---

## 📊 **SUCCESS METRICS**

### Before Claude Code Sprint:
- Overall Completion: 88%
- Deployed Components: ~200
- Broken Components: 3
- Untested Components: 15+
- Code Coverage: 59%

### After Claude Code Sprint:
- Overall Completion: 100%
- Deployed Components: ~220
- Broken Components: 0
- Untested Components: 0
- Code Coverage: 75%+
- Production-Ready: Yes

---

## 📁 **FILES TO FOCUS ON**

### High Priority Fixes:
```
force-app/main/default/flows/Weekly_Mood_Summary.flow-meta.xml (XML error)
force-app/main/default/flows/Daily_Win_Reminder.flow-meta.xml (missing element)
force-app/main/default/classes/HolisticDashboardController.cls (reference error)
```

### High Priority Deployments:
```
force-app/main/default/lwc/holisticDashboard/
force-app/main/default/lwc/mealPlanCalendar/
force-app/main/default/lwc/shoppingListManager/
force-app/main/default/lwc/interviewPrepAgent/
```

### High Priority Creations:
```
Unified Dashboard LWC (new build)
Cross-platform reports (new build)
HTML email templates (new build)
```

---

## 🎯 **RECOMMENDED APPROACH**

**For Maximum Impact:**
1. Start with Session 1 (fix blockers) - clears technical debt
2. Then Session 4 (unified dashboard) - highest user value
3. Then Session 2 (LWC components) - completes features
4. Then Session 3 (test coverage) - production readiness
5. Then Session 5 (integration) - polish
6. Finally Session 6 (documentation) - launch ready

**For Fastest Deployment:**
1. Session 1 → Session 3 → Session 6
2. Skip unified dashboard and cross-platform features
3. Focus on getting existing features production-ready

**For Best Portfolio:**
1. Session 1 → Session 4 → Session 2 → Session 6
2. Prioritize visual components and unified experience
3. Demonstrates full-stack capability

---

## 📞 **STARTING A CLAUDE CODE SESSION**

**Recommended Initial Prompt:**

```
I'm completing the NeuroThrive Holistic Life Assistant Salesforce platform.
I have 88% completion and need to finish the remaining 12%.

Context files to read first:
- REMAINING_BUILD_PACKAGE_FOR_CLAUDE_CODE.md (this file)
- UNIFIED_PROJECT_COMPLETION_ROADMAP_UPDATED_NOV13.md
- WELLNESS_DEPLOYMENT_SUCCESS.md
- PWA_SYNC_DEPLOYMENT_COMPLETE.md

Priority: Start with Session 1 (Fix Critical Blockers)

Target org: abbyluggery179@agentforce.com

Please begin by fixing the 3 critical blockers:
1. Weekly_Mood_Summary.flow XML error
2. Daily_Win_Reminder.flow missing element error
3. HolisticDashboardController.cls reference error

After fixing, deploy holisticDashboard LWC and test.
```

---

**Package Created:** 2025-11-15
**Last Updated:** 2025-11-15
**Estimated Completion Date:** December 2025 (with Claude Code sprints)
**Project Status:** Production-Ready After Completion

🚀 **Ready to finish strong!**
