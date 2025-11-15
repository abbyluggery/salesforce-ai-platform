# Claude Code Execution Guide - 4-Day Sprint

**Repository:** https://github.com/abbyluggery/salesforce-wellness-platform

**Goal:** Build 18 wellness features autonomously using Claude Code via GitHub over 4 days

**Expected Completion:** 70-85% (12-15 features completed)

---

## Prerequisites Completed ✅

- [x] Salesforce project pushed to GitHub (clean branch without API keys)
- [x] Issue template created (`.github/ISSUE_TEMPLATE/feature.md`)
- [x] 18 detailed issues documented (`GITHUB_ISSUES_FOR_CLAUDE_CODE.md`)
- [x] Existing codebase has 75%+ test coverage
- [x] Claude AI API integration already working (`ClaudeAPIService.cls`)

---

## Quick Start: Create GitHub Issues

### Option 1: Use Batch Script (Windows)

```bash
cd "c:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant"
create-github-issues.bat
```

This will create all 18 issues automatically using GitHub CLI.

### Option 2: Manual Creation

If the script doesn't work, manually create issues using the detailed specifications in `GITHUB_ISSUES_FOR_CLAUDE_CODE.md`. Each issue includes:

- Feature description
- Acceptance criteria (checkboxes)
- Technical requirements (code snippets)
- Estimated effort
- Priority level
- Files to create/modify

**To create manually:**
1. Go to https://github.com/abbyluggery/salesforce-wellness-platform/issues
2. Click "New Issue"
3. Copy content from `GITHUB_ISSUES_FOR_CLAUDE_CODE.md` (one issue at a time)
4. Add labels: `claude-code`, `priority: high/medium/low`, `backend/frontend`, `day-1/2/3/4`
5. Click "Submit new issue"
6. Repeat for all 18 issues

---

## How to Use Claude Code on GitHub

### Step 1: Enable Claude Code on Your Repository

1. **Install Claude Code GitHub App:**
   - Go to https://github.com/apps/claude-code (or find in GitHub Marketplace)
   - Click "Install"
   - Select repository: `abbyluggery/salesforce-wellness-platform`
   - Grant permissions for code, issues, pull requests

2. **Configure Repository Settings:**
   - Go to repository Settings → Actions → General
   - Enable "Allow GitHub Actions to create pull requests"
   - Enable "Allow Claude Code bot to push to main branch" (or use branch protection)

### Step 2: Assign Issues to Claude Code

For each issue you want Claude Code to work on:

1. Open the issue
2. Add a comment: `@claude-code please implement this feature`
3. Claude Code will:
   - Analyze the requirements
   - Create a new branch
   - Implement the feature
   - Write tests
   - Create a pull request
   - Comment on the issue with PR link

**OR** use labels:

1. Add label `claude-code-ready` to issues
2. Claude Code will automatically pick up labeled issues

### Step 3: Monitor Progress

**Daily Check-In (10-15 minutes):**

1. **Check Pull Requests:**
   - Go to https://github.com/abbyluggery/salesforce-wellness-platform/pulls
   - Review Claude Code's PRs
   - Check test coverage (should be 75%+)
   - Merge if acceptable, or comment with feedback

2. **Check Issue Progress:**
   - Go to https://github.com/abbyluggery/salesforce-wellness-platform/issues
   - Filter by label: `claude-code`
   - See which issues are completed, in-progress, or blocked

3. **Check Build Status:**
   - Go to https://github.com/abbyluggery/salesforce-wellness-platform/actions
   - Verify Salesforce deployments are passing
   - Check test coverage reports

### Step 4: Provide Feedback

If Claude Code's implementation needs changes:

1. **Comment on Pull Request:**
   ```
   @claude-code please make these changes:
   - Add validation rule for field X
   - Update test class to cover edge case Y
   - Fix formatting in method Z
   ```

2. Claude Code will:
   - Update the PR with requested changes
   - Re-run tests
   - Comment when ready for re-review

---

## 4-Day Execution Plan

### DAY 1: Database Objects (5 issues)
**Priority:** HIGH
**Expected Completion:** 100% (all 5 issues)

**Issues to Assign:**
1. ✅ #1: Create `Gratitude_Entry__c` object
2. ✅ #2: Create `Therapy_Step_Completion__c` object
3. ✅ #3: Create `Negative_Thought_Analysis__c` object
4. ✅ #4: Create `Routine_Task_Timer__c` object
5. ✅ #5: Create `Evening_Routine_Tracking__c` object

**Morning (9 AM):**
- Assign all 5 issues to Claude Code
- Add comment: `@claude-code please implement this feature`

**Afternoon (2 PM):**
- Review PRs (likely 2-3 completed by now)
- Merge if tests pass
- Provide feedback if needed

**Evening (6 PM):**
- Review remaining PRs
- Merge all completed
- Check for any blockers

**Expected Result:** 5 new custom objects deployed to Salesforce

---

### DAY 2: Apex Service Classes (6 issues)
**Priority:** HIGH (4), MEDIUM (2)
**Expected Completion:** 80-90% (5-6 issues)

**Issues to Assign (in order of priority):**
1. ✅ #6: Build `WinParserService` (AI win extraction)
2. ✅ #7: Build `MoodTrackerService` (mood analysis)
3. ✅ #8: Build `ImposterSyndromeAnalyzer` (AI imposter detection)
4. ✅ #9: Build `NegativeThoughtDetector` (CBT distortions)
5. ⚠️ #10: Build `TherapySessionManager` (therapy protocols)
6. ⚠️ #11: Build `RoutineTaskTimerService` (routine optimization)

**Morning (9 AM):**
- Assign HIGH priority issues (#6-9) first
- Let Claude Code work on these in parallel

**Afternoon (2 PM):**
- Review PRs for #6 and #7 (likely completed)
- Test AI integration manually
- Verify Claude API callouts work
- Merge if passing

**Evening (6 PM):**
- Review PRs for #8 and #9
- Assign MEDIUM priority issues (#10-11) if HIGH issues are done
- Merge completed work

**Expected Result:** 4-6 new Apex service classes with 75%+ test coverage

**Note:** These are complex AI integrations. Claude Code may need guidance on:
- Claude API prompt engineering
- Error handling for AI responses
- Test class mocking strategies

---

### DAY 3: Flows & API Enhancements (3 issues)
**Priority:** HIGH (1), MEDIUM (2)
**Expected Completion:** 100% (all 3 issues)

**Issues to Assign:**
1. ✅ #14: Enhance `DailyRoutineAPI` (4 new endpoints) - **Start with this**
2. ✅ #12: Create `Weekly_Mood_Summary` scheduled flow
3. ✅ #13: Create `Daily_Win_Reminder` scheduled flow

**Morning (9 AM):**
- Assign #14 first (API enhancements)
- This is critical for PWA integration

**Midday (12 PM):**
- Review API PR
- Test endpoints manually:
  ```bash
  # Test in Salesforce Developer Console or Postman
  POST /services/apexrest/routine/daily/gratitude
  POST /services/apexrest/routine/daily/wins
  POST /services/apexrest/routine/daily/mood
  GET /services/apexrest/routine/daily/therapy/protocols
  ```
- Merge if working

**Afternoon (2 PM):**
- Assign #12 and #13 (flows)
- Flows are simpler - Claude Code should handle these quickly

**Evening (6 PM):**
- Review flow PRs
- Activate flows in Salesforce
- Verify scheduled triggers are configured
- Merge

**Expected Result:**
- 4 new API endpoints ready for PWA integration
- 2 scheduled flows running on daily/weekly cadence

---

### DAY 4: Polish & Integration (4 issues)
**Priority:** HIGH (2), MEDIUM (1), LOW (2)
**Expected Completion:** 60-80% (2-3 issues)

**Issues to Assign (in priority order):**
1. ✅ #18: Update `HolisticDashboard` with wellness metrics - **HIGHEST PRIORITY**
2. ✅ #15: Add auto-analysis triggers
3. ⚠️ #16: Create wellness reports & list views
4. ⚠️ #17: Add field history tracking

**Morning (9 AM):**
- Assign #18 first (dashboard update)
- This is critical for user-facing experience

**Midday (12 PM):**
- Review dashboard PR
- Test in Salesforce UI
- Verify wellness metrics display correctly
- Merge if working

**Afternoon (2 PM):**
- Assign #15 (triggers)
- This adds automation
- Test trigger firing in Salesforce

**Evening (6 PM):**
- Assign #16 and #17 if time allows
- These are polish items
- Merge any completed work

**Expected Result:**
- Unified dashboard showing wellness data
- Auto-analysis triggers activated
- (Bonus) Reports and field tracking configured

---

## Testing Strategy

### After Each Day's Work

**1. Deploy to Salesforce:**
```bash
# If not auto-deployed by CI/CD
sf project deploy start --source-dir force-app --target-org YOUR_ORG
```

**2. Run All Tests:**
```bash
sf apex run test --test-level RunLocalTests --target-org YOUR_ORG --wait 15 --result-format human
```

**3. Verify Coverage:**
- Target: 75%+ overall coverage
- Each new class must have 75%+ coverage
- Check coverage report in Salesforce Setup → Apex Test Execution

**4. Manual Testing:**

**Day 1 (Objects):**
- Create sample records for each new object
- Verify validation rules fire correctly
- Test lookup relationships

**Day 2 (Apex):**
- Run Execute Anonymous to test each service
- Verify AI integrations work (Claude API calls)
- Test error handling (what happens if API is down?)

**Day 3 (Flows/API):**
- Test API endpoints via Postman or Developer Console
- Verify scheduled flows are scheduled correctly
- Test flow execution manually

**Day 4 (Dashboard):**
- Open dashboard in Salesforce UI
- Verify all metrics display
- Test on mobile browser
- Verify charts render

---

## Common Issues & Solutions

### Issue 1: Claude Code Doesn't Respond
**Symptoms:** No PR created after 30+ minutes
**Causes:**
- Claude Code not installed on repository
- Issue doesn't have `claude-code` label
- Issue is too vague

**Solutions:**
- Verify Claude Code app is installed
- Add `claude-code-ready` label
- Add clarifying comment with more details

---

### Issue 2: PR Fails Tests
**Symptoms:** PR created but CI/CD tests fail
**Causes:**
- Test coverage below 75%
- Compilation errors
- Invalid SOQL queries

**Solutions:**
- Comment on PR: `@claude-code please fix test coverage - currently at 65%, needs 75%+`
- Provide specific error message
- Ask Claude Code to add more test methods

---

### Issue 3: PR Doesn't Follow Salesforce Best Practices
**Symptoms:** Code works but isn't bulkified or efficient
**Causes:**
- Claude Code may not know Salesforce governor limits
- Non-bulkified SOQL queries

**Solutions:**
- Comment: `@claude-code please bulkify this code - move SOQL outside of loops`
- Reference Salesforce best practices documentation
- Ask for specific changes

---

### Issue 4: AI Integration Doesn't Work
**Symptoms:** `ClaudeAPIService` callouts fail
**Causes:**
- API key not configured
- Remote site setting missing
- Prompt engineering issues

**Solutions:**
- Verify Named Credential is configured
- Check Remote Site Settings for `https://api.anthropic.com`
- Provide example prompt in comment

---

### Issue 5: Flows Don't Schedule
**Symptoms:** Flow created but not scheduled
**Causes:**
- Flow not activated
- Schedule not configured

**Solutions:**
- Manually activate flow in Salesforce Setup
- Configure schedule via Process Automation → Flows
- Verify flow status is "Active"

---

## Success Metrics

### Target Completion Rates

| Day | Features | Expected Completion | Actual Completion |
|-----|----------|---------------------|-------------------|
| Day 1 | 5 objects | 100% (5/5) | ___ |
| Day 2 | 6 Apex classes | 85% (5/6) | ___ |
| Day 3 | 3 flows/API | 100% (3/3) | ___ |
| Day 4 | 4 polish items | 70% (3/4) | ___ |
| **Total** | **18 features** | **80% (14-15/18)** | **___** |

### Quality Metrics

- [ ] Overall test coverage ≥ 75%
- [ ] All new Apex classes have test classes
- [ ] All objects have validation rules
- [ ] All API endpoints tested
- [ ] All flows activated and scheduled
- [ ] Dashboard displays wellness metrics
- [ ] No compilation errors
- [ ] No governor limit violations

---

## After 4-Day Sprint

### Integration with PWA

Once Salesforce backend is complete:

1. **Test OAuth Flow:**
   - Open NeuroThrive PWA: http://localhost:8080
   - Click "Login with Salesforce"
   - Verify authentication works
   - Check that access token is saved

2. **Test API Sync:**
   ```javascript
   // In PWA console:
   await salesforceAPI.createGratitudeEntry({
       gratitudeText: "Test gratitude",
       category: "Personal",
       intensity: 8
   });
   ```

3. **Verify Bidirectional Sync:**
   - Create gratitude entry in PWA
   - Check Salesforce org for new record
   - Create win entry in Salesforce
   - Check PWA dashboard for update

4. **Test Dashboard:**
   - Open HolisticDashboard in Salesforce
   - Verify wellness metrics show PWA data
   - Test on mobile device

---

## Deployment Checklist

Before going to production:

### Salesforce Org
- [ ] All 18 features deployed
- [ ] Test coverage ≥ 75%
- [ ] All validation rules tested
- [ ] All triggers tested with bulk data (200 records)
- [ ] All flows activated and scheduled
- [ ] Field history tracking enabled
- [ ] Reports added to dashboard
- [ ] User permissions configured

### PWA
- [ ] OAuth authentication working
- [ ] All API endpoints tested
- [ ] Offline sync working
- [ ] Service worker registered
- [ ] Push notifications configured
- [ ] IndexedDB storage working

### Integration
- [ ] PWA → Salesforce sync tested
- [ ] Salesforce → PWA sync tested
- [ ] Error handling tested (what if Salesforce is down?)
- [ ] Token refresh working
- [ ] CORS configured correctly

---

## Budget Tracking

**GitHub Credits Used:**
- Day 1: ___ credits
- Day 2: ___ credits
- Day 3: ___ credits
- Day 4: ___ credits
- **Total:** ___ credits

**Average per feature:** ___ credits ÷ ___ features = ___ credits/feature

---

## Final Deliverables

After 4-day sprint, you should have:

1. **5 New Custom Objects:**
   - Gratitude_Entry__c
   - Therapy_Step_Completion__c
   - Negative_Thought_Analysis__c
   - Routine_Task_Timer__c
   - Evening_Routine_Tracking__c

2. **6+ New Apex Classes:**
   - WinParserService
   - MoodTrackerService
   - ImposterSyndromeAnalyzer
   - NegativeThoughtDetector
   - TherapySessionManager
   - RoutineTaskTimerService

3. **2 Scheduled Flows:**
   - Weekly_Mood_Summary
   - Daily_Win_Reminder

4. **Enhanced APIs:**
   - DailyRoutineAPI with 4 new endpoints

5. **Auto-Analysis Triggers:**
   - MoodEntryTrigger
   - WinEntryTrigger

6. **Enhanced Dashboard:**
   - HolisticDashboard with wellness metrics

7. **Reports & Views:**
   - 5+ wellness reports
   - List views for all objects

---

## Troubleshooting

### Claude Code Not Working?

**Check GitHub App Status:**
1. Go to https://github.com/settings/installations
2. Find "Claude Code" app
3. Verify it has access to `salesforce-wellness-platform`
4. Check permissions (code, issues, PRs)

**Check Repository Settings:**
1. Settings → Actions → General
2. Verify "Allow GitHub Actions" is enabled
3. Verify "Allow bot to create PRs" is enabled

**Check Issue Format:**
1. Issue must have clear acceptance criteria
2. Issue must have `claude-code` label
3. Issue description should include code examples

---

## Support

**If you encounter issues:**

1. **Check GitHub Issues:**
   - https://github.com/anthropics/claude-code/issues
   - Search for similar problems

2. **Check Claude Code Documentation:**
   - https://docs.anthropic.com/claude-code

3. **Manual Fallback:**
   - If Claude Code can't complete a feature, use the detailed specs in `GITHUB_ISSUES_FOR_CLAUDE_CODE.md`
   - Implement manually or via Claude Chat
   - Mark issue as completed in GitHub

---

## Summary

**You are now ready to:**
1. ✅ Create 18 GitHub issues (use `create-github-issues.bat`)
2. ✅ Assign issues to Claude Code
3. ✅ Monitor progress daily (10-15 min per day)
4. ✅ Review and merge PRs
5. ✅ Test integrated features
6. ✅ Deploy to production

**Expected outcome in 4 days:**
- 14-15 features completed (80%)
- 75%+ test coverage maintained
- PWA ↔ Salesforce integration working
- Unified dashboard displaying all platforms
- Ready for production use

**Good luck! 🚀**
