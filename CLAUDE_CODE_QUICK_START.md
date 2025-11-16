# ⚡ CLAUDE CODE QUICK START GUIDE
## Execute NeuroThrive Build Completion in 8-10 Hours

**Target**: Complete remaining 12-15% of multi-platform ecosystem
**Repository**: https://github.com/abbyluggery/salesforce-wellness-platform
**Full Package**: See CLAUDE_CODE_DEPLOYMENT_PACKAGE.md for detailed instructions

---

## 🎯 QUICK EXECUTION SEQUENCE

### Prerequisites (5 minutes)
```bash
# Clone repository
git clone https://github.com/abbyluggery/salesforce-wellness-platform.git
cd salesforce-wellness-platform

# Authenticate to Salesforce org
sf org login web --alias neurothrive --set-default
# Login as: abbyluggery179@agentforce.com

# Verify connection
sf org display --target-org neurothrive
```

---

## 📋 7-SESSION EXECUTION PLAN

### **SESSION 1: Fix Salesforce Flows** (2 hours)

**Goal**: Resolve 2 critical flow XML errors

**Quick Commands**:
```bash
# Fix 1: Remove duplicate actionCalls from Weekly_Mood_Summary.flow
# Edit force-app/main/default/flows/Weekly_Mood_Summary.flow-meta.xml
# Line 134: Remove duplicate <actionCalls> block

# Fix 2: Add missing Get_Todays_Wins element to Daily_Win_Reminder.flow
# Edit force-app/main/default/flows/Daily_Win_Reminder.flow-meta.xml
# Add <recordLookups> element (see deployment package for exact XML)

# Deploy both flows
sf project deploy start --source-dir force-app/main/default/flows/Weekly_Mood_Summary.flow-meta.xml --target-org neurothrive --wait 15
sf project deploy start --source-dir force-app/main/default/flows/Daily_Win_Reminder.flow-meta.xml --target-org neurothrive --wait 15
```

**Success Indicator**: Both flows deploy without errors

---

### **SESSION 2: Deploy Apex Updates** (1 hour)

**Goal**: Deploy 5 modified Apex classes

**Quick Commands**:
```bash
# Deploy meal planning updates
sf project deploy start --metadata ApexClass:IngredientParser,ApexClass:IngredientParserTest,ApexClass:MealPlanCalendarController,ApexClass:ShoppingListGenerator,ApexClass:ShoppingListGeneratorTest --target-org neurothrive --wait 15

# Deploy field metadata
sf project deploy start --source-dir "force-app/main/default/objects/Negative_Thought_Analysis__c/fields/Original_Thought__c.field-meta.xml" --target-org neurothrive --wait 15

# Verify deployment
sf apex test run --tests IngredientParserTest,ShoppingListGeneratorTest --target-org neurothrive --wait 15 --result-format human
```

**Success Indicator**: All classes deployed, tests pass

---

### **SESSION 3: Deploy Dashboard** (1 hour)

**Goal**: Deploy HolisticDashboardController and LWC

**Quick Commands**:
```bash
# Deploy controller
sf project deploy start --metadata ApexClass:HolisticDashboardController --target-org neurothrive --wait 15

# Deploy LWC component
sf project deploy start --metadata LightningComponentBundle:holisticDashboard --target-org neurothrive --wait 15

# Verify in org
# Navigate to: App Launcher → NeuroThrive Assistant → Holistic Dashboard tab
```

**Success Indicator**: Dashboard loads without errors

---

### **SESSION 4: Configure OAuth** (2 hours)

**Goal**: Setup NeuroThrive PWA OAuth integration

**Quick Steps**:

1. **Create Connected App** (Salesforce Setup):
   - Setup → App Manager → New Connected App
   - Name: NeuroThrive PWA
   - Callback URL: `http://localhost:8080/oauth/callback`
   - Scopes: api, refresh_token, openid
   - Save and retrieve Consumer Key + Secret

2. **Setup Remote Site**:
   - Setup → Remote Site Settings → New
   - Name: NeuroThrive_Localhost
   - URL: `http://localhost:8080`

3. **Configure PWA** (neurothrive-pwa repo):
   ```bash
   cd ../neurothrive-pwa
   cp js/config.template.js js/config.js
   # Edit js/config.js with Consumer Key and Secret
   echo "js/config.js" >> .gitignore
   ```

4. **Test OAuth**:
   ```bash
   python -m http.server 8080
   # Open http://localhost:8080
   # Click "Login to Salesforce"
   # Verify token in localStorage
   ```

**Success Indicator**: OAuth login succeeds, token stored

---

### **SESSION 5: Integration Testing** (2 hours)

**Goal**: Test end-to-end data flow across platforms

**Test 1: Morning Routine** (30 min):
```bash
# 1. Voice: "Good morning, Claude" (Claude Assistant)
# 2. PWA: Log routine at http://localhost:8080
# 3. Verify in Salesforce:
sf data query --query "SELECT Id, Morning_Routine_Complete__c FROM Daily_Routine__c WHERE Routine_Date__c = TODAY" --target-org neurothrive
```

**Test 2: Job Application** (45 min):
```bash
# 1. Create test job in Salesforce
# 2. Voice: "Run job search routine"
# 3. PWA: Log application
# 4. Verify job status updated
```

**Test 3: Imposter Syndrome** (45 min):
```bash
# 1. PWA: Use imposter syndrome counter
# 2. Verify session in Salesforce:
sf data query --query "SELECT Id, Original_Thought__c FROM Imposter_Syndrome_Session__c WHERE CreatedDate = TODAY" --target-org neurothrive
```

**Success Indicator**: All 3 tests pass, data syncs correctly

---

### **SESSION 6: Commit to GitHub** (1 hour)

**Goal**: Push all changes to GitHub

**Quick Commands**:
```bash
cd salesforce-wellness-platform

# Stage modified files
git add force-app/main/default/classes/
git add force-app/main/default/flows/
git add force-app/main/default/objects/
git add force-app/main/default/lwc/

# Stage documentation
git add COMPLETE_MULTI_PLATFORM_BUILD_STATUS.md
git add CLAUDE_CODE_DEPLOYMENT_PACKAGE.md
git add CLAUDE_CODE_QUICK_START.md

# Commit
git commit -m "Complete remaining 12% of NeuroThrive build

Critical fixes:
- Fix Weekly_Mood_Summary and Daily_Win_Reminder flows
- Deploy IngredientParser, MealPlanCalendarController, ShoppingListGenerator updates
- Deploy HolisticDashboardController with LWC
- Configure OAuth for NeuroThrive PWA
- Complete end-to-end integration testing

Status: 100% production-ready

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to GitHub
git push origin clean-main
```

**Success Indicator**: All commits pushed to GitHub

---

### **SESSION 7: Validation** (1 hour)

**Goal**: Verify 100% completion

**Validation Checklist**:
```bash
# Count components
sf data query --query "SELECT COUNT() FROM ApexClass WHERE NamespacePrefix = null" --target-org neurothrive
# Expected: 93

sf data query --query "SELECT COUNT() FROM EntityDefinition WHERE IsCustomSetting = false AND QualifiedApiName LIKE '%__c'" --target-org neurothrive
# Expected: 26

# Check flow status
sf data query --query "SELECT DeveloperName, ActiveVersion.Status FROM FlowDefinition WHERE DeveloperName IN ('Weekly_Mood_Summary', 'Daily_Win_Reminder')" --target-org neurothrive
# Expected: Both Active

# Test OAuth token
# In PWA: localStorage.getItem('sf_tokens')
# Expected: Valid token with refresh_token

# Test API call
# In PWA console: Test DailyRoutineAPI endpoint
# Expected: 200 OK response
```

**Create Summary Document**:
```bash
cat > DEPLOYMENT_COMPLETE.md << 'EOF'
# NeuroThrive Build - 100% COMPLETE

## Deployment Summary
- Date: [Current Date]
- Executor: Claude Code
- Time: 8-10 hours
- Status: ✅ PRODUCTION READY

## Components Deployed
- Flows fixed: 2 ✅
- Apex classes: 6 ✅
- LWC components: 1 ✅
- OAuth configuration: ✅
- Integration tests: 3/3 passed ✅

## Platform Status
- Salesforce: 100% ✅
- NeuroThrive PWA: 100% ✅
- Overall: PRODUCTION READY ✅

## Next Steps
- Deploy PWA to GitHub Pages
- Begin Claude Assistant Phase 3
- Create demo video
- Update portfolio materials
EOF

git add DEPLOYMENT_COMPLETE.md
git commit -m "Add deployment completion summary"
git push origin clean-main
```

**Success Indicator**: All validation checks pass

---

## 🎯 KEY FILES REFERENCE

### Must Read Before Starting
1. **COMPLETE_MULTI_PLATFORM_BUILD_STATUS.md** - Overall context (85% complete status)
2. **CLAUDE_CODE_DEPLOYMENT_PACKAGE.md** - Detailed instructions for each session

### Flow Files to Edit
- `force-app/main/default/flows/Weekly_Mood_Summary.flow-meta.xml`
- `force-app/main/default/flows/Daily_Win_Reminder.flow-meta.xml`

### Apex Classes to Deploy
- `force-app/main/default/classes/IngredientParser.cls`
- `force-app/main/default/classes/MealPlanCalendarController.cls`
- `force-app/main/default/classes/ShoppingListGenerator.cls`
- `force-app/main/default/classes/HolisticDashboardController.cls`

### OAuth Configuration
- Salesforce Setup → App Manager → New Connected App
- Salesforce Setup → Remote Site Settings
- neurothrive-pwa/js/config.js (create from template)

---

## ⚡ SPEED RUN COMMANDS (Copy-Paste Ready)

```bash
# Setup (5 min)
git clone https://github.com/abbyluggery/salesforce-wellness-platform.git
cd salesforce-wellness-platform
sf org login web --alias neurothrive --set-default

# Session 1: Flows (2 hours - includes manual XML editing)
# Edit flow files, then:
sf project deploy start --source-dir force-app/main/default/flows/ --target-org neurothrive --wait 15

# Session 2: Apex (1 hour)
sf project deploy start --metadata ApexClass:IngredientParser,ApexClass:IngredientParserTest,ApexClass:MealPlanCalendarController,ApexClass:ShoppingListGenerator,ApexClass:ShoppingListGeneratorTest --target-org neurothrive --wait 15
sf apex test run --tests IngredientParserTest,ShoppingListGeneratorTest --target-org neurothrive --wait 15

# Session 3: Dashboard (1 hour)
sf project deploy start --metadata ApexClass:HolisticDashboardController,LightningComponentBundle:holisticDashboard --target-org neurothrive --wait 15

# Session 4: OAuth (2 hours - includes manual Salesforce Setup)
# Create Connected App, then test at http://localhost:8080

# Session 5: Testing (2 hours - manual testing)
# Execute 3 test scenarios

# Session 6: Git (1 hour)
git add -A
git commit -m "Complete NeuroThrive build - 100%"
git push origin clean-main

# Session 7: Validation (1 hour)
sf data query --query "SELECT COUNT() FROM ApexClass" --target-org neurothrive
sf data query --query "SELECT COUNT() FROM EntityDefinition WHERE QualifiedApiName LIKE '%__c'" --target-org neurothrive
```

---

## 🚨 CRITICAL SUCCESS FACTORS

### Before Each Session
- ✅ Read session instructions in CLAUDE_CODE_DEPLOYMENT_PACKAGE.md
- ✅ Verify org authentication still valid
- ✅ Check git status before making changes
- ✅ Review error logs from previous session

### During Each Session
- ✅ Follow exact XML structure for flow fixes
- ✅ Deploy classes in dependency order
- ✅ Run tests after each Apex deployment
- ✅ Verify OAuth credentials are correct
- ✅ Test thoroughly before committing

### After Each Session
- ✅ Document any issues encountered
- ✅ Verify deployment success in Salesforce org
- ✅ Update session checklist
- ✅ Commit changes incrementally

---

## 📊 TIME BUDGET

| Session | Task | Estimated Time |
|---------|------|----------------|
| 1 | Fix Salesforce Flows | 2 hours |
| 2 | Deploy Apex Updates | 1 hour |
| 3 | Deploy Dashboard | 1 hour |
| 4 | Configure OAuth | 2 hours |
| 5 | Integration Testing | 2 hours |
| 6 | Commit to GitHub | 1 hour |
| 7 | Validation | 1 hour |
| **TOTAL** | | **10 hours** |

**Minimum Viable Completion**: Sessions 1-3 (4 hours) gets Salesforce to 100%

**Full Completion**: All 7 sessions (10 hours) gets entire ecosystem to 100%

---

## 💡 PRO TIPS

### For Flow Fixes
- Use VS Code with Salesforce extensions for XML syntax highlighting
- Validate XML structure before deploying
- Use --dry-run flag to test deployment first
- Keep backup of original flow files

### For OAuth Setup
- Test callback URL in browser first (should show 404, not error)
- Copy Consumer Key/Secret carefully (no extra spaces)
- Use incognito/private browser for OAuth testing
- Check browser console for detailed error messages

### For Testing
- Test offline mode by disabling network in DevTools
- Check IndexedDB in browser for sync queue items
- Verify Salesforce records created with SOQL queries
- Document any data inconsistencies immediately

### For Git Operations
- Commit after each successful session
- Use descriptive commit messages
- Push to remote frequently
- Tag completion milestone: `git tag v1.0-complete`

---

## 🎉 SUCCESS CRITERIA

### You've succeeded when:
- ✅ All 19 Salesforce flows are active (no errors)
- ✅ All 93 Apex classes deployed (no failures)
- ✅ HolisticDashboard LWC loads without errors
- ✅ OAuth login works in NeuroThrive PWA
- ✅ Data syncs from PWA to Salesforce
- ✅ All 3 integration tests pass
- ✅ All code committed to GitHub
- ✅ Component counts match expected values

### Final Validation Query
```bash
# Run this to confirm 100% completion
sf data query --query "SELECT COUNT(Id) FROM ApexClass" --target-org neurothrive && \
sf data query --query "SELECT COUNT(Id) FROM EntityDefinition WHERE QualifiedApiName LIKE '%__c'" --target-org neurothrive && \
sf data query --query "SELECT COUNT(Id) FROM FlowDefinition WHERE ActiveVersion.Status = 'Active'" --target-org neurothrive

# Expected Results:
# ApexClass: 93
# Custom Objects: 26
# Active Flows: 19
```

---

## 📞 NEED HELP?

### Common Issues
See **Troubleshooting Guide** in CLAUDE_CODE_DEPLOYMENT_PACKAGE.md

### Documentation
- **Detailed Instructions**: CLAUDE_CODE_DEPLOYMENT_PACKAGE.md
- **Build Status**: COMPLETE_MULTI_PLATFORM_BUILD_STATUS.md
- **PWA Setup**: neurothrive-pwa/PHASE1_TESTING_GUIDE.md

### Reference Materials
- Salesforce CLI: https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta
- OAuth Guide: https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_web_server_flow.htm

---

## 🚀 READY TO EXECUTE?

1. **Open**: CLAUDE_CODE_DEPLOYMENT_PACKAGE.md for detailed instructions
2. **Authenticate**: `sf org login web --alias neurothrive`
3. **Start**: Session 1 - Fix Salesforce Flows
4. **Execute**: Follow 7-session plan
5. **Validate**: Run success criteria checks
6. **Celebrate**: 100% production-ready ecosystem! 🎉

**Let's complete this build!** 💪
