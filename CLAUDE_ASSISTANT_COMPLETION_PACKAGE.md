# 🤖 CLAUDE PERSONAL ASSISTANT - COMPLETION DEPLOYMENT PACKAGE
## For Claude Code Execution via GitHub

**Generated**: November 16, 2025
**Target Repository**: https://github.com/abbyluggery/Claude-Personal-Assistant
**Current Status**: 60% Complete → Goal: 90% Complete
**Estimated Time**: 12-16 hours across 4 sessions
**Execution Mode**: Claude Code via GitHub integration

---

## 📊 CURRENT STATUS ANALYSIS

### What's Already Built ✅

**Phase 1: Foundation (COMPLETE)**
- 5 voice commands implemented and documented
- iOS Shortcuts integration configured
- Android Google Assistant hooks configured
- Claude API integration established
- Privacy-first architecture defined
- Comprehensive roadmap (80 pages)
- Setup documentation complete

**Documentation Complete:**
- `holistic_claude_assistant_implementation_roadmap.md` (80 pages)
- `INTEGRATION_PLAN.md`
- `PHASE2_COMPLETE.md` and `PHASE2_UI_COMPLETE.md`
- `TODAY_SUMMARY.md`
- `README.md` with feature overview
- Voice command setup guides in `/voice-commands/`

**Architecture Defined:**
- Local SQLite with AES-256 encryption
- No mandatory cloud sync (privacy-first)
- MVVM architecture pattern
- Neurodivergent-first design principles

---

## 🎯 WHAT'S MISSING (To Reach 90%)

### 1. Android Native App (40% of remaining work)

**Missing Components:**
- Kotlin/Jetpack Compose UI implementation
- SQLite database schema creation
- Repository pattern data layer
- ViewModel layer with LiveData
- Settings screen
- Home dashboard screen
- Quick action widgets

**Files Needed:**
```
/android/
├── app/
│   ├── src/main/
│   │   ├── java/com/neurothrive/assistant/
│   │   │   ├── data/
│   │   │   │   ├── local/
│   │   │   │   │   ├── AppDatabase.kt
│   │   │   │   │   ├── dao/
│   │   │   │   │   │   ├── MoodEntryDao.kt
│   │   │   │   │   │   ├── WinEntryDao.kt
│   │   │   │   │   │   ├── JobPostingDao.kt
│   │   │   │   │   │   └── DailyRoutineDao.kt
│   │   │   │   │   ├── entities/
│   │   │   │   │   │   ├── MoodEntry.kt
│   │   │   │   │   │   ├── WinEntry.kt
│   │   │   │   │   │   ├── JobPosting.kt
│   │   │   │   │   │   └── DailyRoutine.kt
│   │   │   │   │   └── SecurityUtils.kt (AES-256 encryption)
│   │   │   │   ├── repository/
│   │   │   │   │   ├── MoodRepository.kt
│   │   │   │   │   ├── WinRepository.kt
│   │   │   │   │   ├── JobRepository.kt
│   │   │   │   │   └── DailyRoutineRepository.kt
│   │   │   ├── ui/
│   │   │   │   ├── theme/
│   │   │   │   │   ├── Color.kt
│   │   │   │   │   ├── Theme.kt
│   │   │   │   │   └── Type.kt
│   │   │   │   ├── home/
│   │   │   │   │   ├── HomeScreen.kt
│   │   │   │   │   ├── HomeViewModel.kt
│   │   │   │   │   └── components/
│   │   │   │   │       ├── SummaryCard.kt
│   │   │   │   │       ├── QuickActionButton.kt
│   │   │   │   │       └── MoodChart.kt
│   │   │   │   ├── mood/
│   │   │   │   │   ├── MoodLogScreen.kt
│   │   │   │   │   └── MoodViewModel.kt
│   │   │   │   ├── wins/
│   │   │   │   │   ├── WinLogScreen.kt
│   │   │   │   │   └── WinViewModel.kt
│   │   │   │   ├── settings/
│   │   │   │   │   ├── SettingsScreen.kt
│   │   │   │   │   └── SettingsViewModel.kt
│   │   │   │   └── MainActivity.kt
│   │   │   └── ClaudeAssistantApplication.kt
│   │   ├── res/
│   │   │   ├── values/
│   │   │   │   ├── strings.xml
│   │   │   │   ├── colors.xml
│   │   │   │   └── themes.xml
│   │   │   └── drawable/
│   │   │       └── ic_launcher_*.xml
│   │   └── AndroidManifest.xml
│   ├── build.gradle.kts
│   └── proguard-rules.pro
├── gradle/
│   └── libs.versions.toml
├── build.gradle.kts
├── settings.gradle.kts
└── README.md
```

---

### 2. Salesforce Integration Bridge (30% of remaining work)

**Missing Components:**
- REST API client for Salesforce
- OAuth 2.0 token management
- Sync queue with retry logic
- Conflict resolution (last-write-wins)
- Batch sync for offline data

**Files Needed:**
```
/android/app/src/main/java/com/neurothrive/assistant/
├── api/
│   ├── SalesforceApiClient.kt
│   ├── models/
│   │   ├── SalesforceMoodEntry.kt
│   │   ├── SalesforceWinEntry.kt
│   │   ├── SalesforceJobPosting.kt
│   │   └── SalesforceDailyRoutine.kt
│   ├── auth/
│   │   ├── OAuthManager.kt
│   │   └── TokenStorage.kt (encrypted)
│   └── sync/
│       ├── SyncManager.kt
│       ├── SyncWorker.kt (WorkManager)
│       ├── ConflictResolver.kt
│       └── SyncQueue.kt
```

**Salesforce Endpoints to Connect To:**
- `POST /services/apexrest/DailyRoutineAPI/routines` - Log mood, energy, pain
- `GET /services/apexrest/DailyRoutineAPI/routines` - Fetch routines
- `GET /services/data/v59.0/sobjects/Win_Entry__c` - Fetch wins
- `POST /services/data/v59.0/sobjects/Win_Entry__c` - Create win
- `GET /services/data/v59.0/sobjects/Job_Posting__c` - Fetch jobs
- `POST /services/data/v59.0/sobjects/Job_Posting__c` - Create job

---

### 3. Enhanced Voice Command Integration (20% of remaining work)

**Missing Components:**
- Voice-to-text processing
- Intent parsing logic
- Response generation
- TTS (text-to-speech) output
- Context preservation between commands

**Files Needed:**
```
/android/app/src/main/java/com/neurothrive/assistant/
├── voice/
│   ├── VoiceCommandProcessor.kt
│   ├── IntentClassifier.kt
│   ├── CommandExecutor.kt
│   ├── ClaudeIntegration.kt
│   └── TTSManager.kt
```

**Enhanced Commands:**
- "How am I feeling this week?" - Analyze mood trends
- "What did I accomplish today?" - List today's wins
- "Any new job matches?" - Check Salesforce for ND-friendly jobs
- "Prepare for interview at [Company]" - Load company research
- "What's my meal plan?" - Fetch planned meals

---

### 4. Dashboard UI Components (10% of remaining work)

**Missing Components:**
- Summary cards (like Salesforce unified dashboard)
- Charts/graphs for mood trends
- Quick action buttons
- Settings configuration screen

**Files Needed:**
```
/android/app/src/main/java/com/neurothrive/assistant/ui/
├── components/
│   ├── JobSearchCard.kt (matches jobSearchSummaryCard LWC)
│   ├── WellnessCard.kt (matches wellnessSummaryCard LWC)
│   ├── MealPlanningCard.kt (matches mealPlanningSummaryCard LWC)
│   ├── SavingsCard.kt (matches savingsSummaryCard LWC)
│   ├── MoodTrendChart.kt (line chart for 7-day mood)
│   └── QuickActionGrid.kt
```

---

## 🚀 SESSION-BY-SESSION EXECUTION PLAN

### SESSION 1: Android Foundation (3-4 hours)

**Goal**: Create Android project structure and database layer

**Tasks:**
1. Initialize Android project with Kotlin/Jetpack Compose
2. Configure build.gradle with dependencies
3. Create SQLite database schema (AppDatabase.kt)
4. Implement DAOs for all entities
5. Create entity classes with encryption
6. Build SecurityUtils for AES-256 encryption
7. Write unit tests for database layer

**Deliverables:**
- Functional Android app with empty UI
- Encrypted SQLite database
- All entity/DAO classes
- Unit tests passing

**Commands to Run:**
```bash
# Create project structure
mkdir -p android/app/src/main/java/com/neurothrive/assistant/{data,ui,api,voice}
mkdir -p android/app/src/main/res/values

# Initialize Git if needed
cd android
git init
git add .
git commit -m "feat: initialize Android project with database layer"
git push origin main
```

---

### SESSION 2: Salesforce Integration (3-4 hours)

**Goal**: Build REST API client and OAuth 2.0 authentication

**Tasks:**
1. Create SalesforceApiClient with Retrofit
2. Implement OAuthManager for token flow
3. Build TokenStorage with encryption
4. Create API model classes
5. Implement SyncManager with WorkManager
6. Build ConflictResolver (last-write-wins)
7. Create SyncQueue for offline operations
8. Write integration tests

**Deliverables:**
- Functional OAuth 2.0 login flow
- API client connecting to Salesforce
- Sync queue with retry logic
- Integration tests passing

**Salesforce Connected App Configuration:**
```
Setup → App Manager → New Connected App
- Name: Claude Personal Assistant
- Callback URL: neurothrive://oauth/callback
- Selected OAuth Scopes:
  - Access and manage your data (api)
  - Perform requests on your behalf at any time (refresh_token, offline_access)
  - Access your basic information (id, profile, email, address, phone)
```

**Test API Connection:**
```kotlin
// In SalesforceApiClientTest.kt
@Test
fun testDailyRoutineAPIConnection() {
    val client = SalesforceApiClient(context)
    val response = client.createDailyRoutine(
        moodLevel = 7,
        energyLevel = 6,
        painLevel = 2
    )
    assertEquals(201, response.statusCode)
}
```

---

### SESSION 3: Voice Commands & Claude Integration (3-4 hours)

**Goal**: Implement voice processing and Claude API integration

**Tasks:**
1. Create VoiceCommandProcessor
2. Build IntentClassifier with pattern matching
3. Implement CommandExecutor
4. Integrate Claude API client
5. Build TTSManager for responses
6. Create context preservation system
7. Write voice command tests

**Deliverables:**
- Voice commands processed locally
- Claude API integration for complex queries
- Text-to-speech responses
- Context maintained between commands

**Voice Command Examples:**

```kotlin
// VoiceCommandProcessor.kt
class VoiceCommandProcessor(private val context: Context) {

    fun process(command: String): CommandResult {
        return when (IntentClassifier.classify(command)) {
            Intent.LOG_MOOD -> processMoodLog(command)
            Intent.LOG_WIN -> processWinLog(command)
            Intent.CHECK_JOBS -> processJobCheck()
            Intent.ANALYZE_WEEK -> processWeeklyAnalysis()
            Intent.INTERVIEW_PREP -> processInterviewPrep(command)
            else -> processWithClaude(command)
        }
    }

    private fun processMoodLog(command: String): CommandResult {
        // Extract mood level from natural language
        val mood = NLPUtils.extractMoodLevel(command)
        val energy = NLPUtils.extractEnergyLevel(command)

        // Save to local DB
        moodRepository.logMood(mood, energy)

        // Queue for Salesforce sync
        syncQueue.add(SyncOperation.CREATE_MOOD_ENTRY, mood)

        return CommandResult(
            success = true,
            message = "Mood logged: $mood/10. Stay strong! 💙",
            ttsText = "I've logged your mood as $mood out of 10"
        )
    }
}
```

---

### SESSION 4: Dashboard UI (2-3 hours)

**Goal**: Build Material Design 3 dashboard with summary cards

**Tasks:**
1. Create HomeScreen composable
2. Build 4 summary cards (matches Salesforce LWC)
3. Implement MoodTrendChart with MPAndroidChart
4. Create QuickActionGrid
5. Build navigation
6. Implement dark theme support
7. Add accessibility labels

**Deliverables:**
- Beautiful dashboard UI
- Summary cards with real data
- Mood trend chart
- Quick actions functional

**UI Implementation:**

```kotlin
// HomeScreen.kt
@Composable
fun HomeScreen(viewModel: HomeViewModel = hiltViewModel()) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = { TopAppBar(title = { Text("NeuroThrive") }) }
    ) { padding ->
        LazyColumn(
            modifier = Modifier.padding(padding),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Date range filter (Today, Week, Month)
            item { DateRangeSelector(viewModel) }

            // 4 Summary Cards (matches Salesforce dashboard)
            item {
                JobSearchCard(
                    totalApplications = uiState.totalJobs,
                    weeklyApplications = uiState.weeklyJobs,
                    interviews = uiState.interviews,
                    offers = uiState.offers
                )
            }
            item {
                WellnessCard(
                    todayMood = uiState.todayMood,
                    todayEnergy = uiState.todayEnergy,
                    winsLogged = uiState.winsCount,
                    moodEntries = uiState.moodEntries
                )
            }
            item {
                MealPlanningCard(
                    mealsPlanned = uiState.mealsPlanned,
                    mealsCompleted = uiState.mealsCompleted,
                    savings = uiState.couponSavings
                )
            }
            item {
                SavingsCard(
                    totalSavings = uiState.totalSavings,
                    activeCoupons = uiState.activeCoupons
                )
            }

            // Mood Trend Chart
            item {
                MoodTrendChart(
                    moodData = uiState.last7DaysMood
                )
            }

            // Quick Actions
            item {
                QuickActionGrid(
                    onLogMood = { viewModel.navigateToMoodLog() },
                    onLogWin = { viewModel.navigateToWinLog() },
                    onAddJob = { viewModel.navigateToAddJob() },
                    onSync = { viewModel.syncWithSalesforce() }
                )
            }
        }
    }
}
```

---

## 📋 DETAILED IMPLEMENTATION SPECIFICATIONS

### 1. Database Schema (SQLite)

```kotlin
// AppDatabase.kt
@Database(
    entities = [
        MoodEntry::class,
        WinEntry::class,
        JobPosting::class,
        DailyRoutine::class,
        MealPlan::class,
        ShoppingList::class
    ],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun moodEntryDao(): MoodEntryDao
    abstract fun winEntryDao(): WinEntryDao
    abstract fun jobPostingDao(): JobPostingDao
    abstract fun dailyRoutineDao(): DailyRoutineDao
    abstract fun mealPlanDao(): MealPlanDao
    abstract fun shoppingListDao(): ShoppingListDao
}

// MoodEntry.kt
@Entity(tableName = "mood_entries")
data class MoodEntry(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val moodLevel: Int, // 1-10
    val energyLevel: Int, // 1-10
    val painLevel: Int, // 1-10
    val timestamp: Long = System.currentTimeMillis(),
    val notes: String? = null,
    val syncedToSalesforce: Boolean = false,
    val salesforceId: String? = null
)

// WinEntry.kt
@Entity(tableName = "win_entries")
data class WinEntry(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val description: String,
    val category: String? = null, // "career", "health", "personal"
    val timestamp: Long = System.currentTimeMillis(),
    val syncedToSalesforce: Boolean = false,
    val salesforceId: String? = null
)

// JobPosting.kt
@Entity(tableName = "job_postings")
data class JobPosting(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val jobTitle: String,
    val companyName: String,
    val url: String,
    val salaryMin: Double? = null,
    val salaryMax: Double? = null,
    val remotePolicy: String? = null,
    val description: String? = null,
    val fitScore: Double? = null,
    val ndFriendlinessScore: Double? = null,
    val greenFlags: String? = null,
    val redFlags: String? = null,
    val datePosted: Long = System.currentTimeMillis(),
    val syncedToSalesforce: Boolean = false,
    val salesforceId: String? = null
)

// DailyRoutine.kt
@Entity(tableName = "daily_routines")
data class DailyRoutine(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val date: Long,
    val moodLevel: Int,
    val energyLevel: Int,
    val painLevel: Int,
    val sleepQuality: Int? = null,
    val exerciseMinutes: Int? = null,
    val hydrationOunces: Int? = null,
    val mealsEaten: Int? = null,
    val journalEntry: String? = null,
    val syncedToSalesforce: Boolean = false,
    val salesforceId: String? = null
)
```

---

### 2. Salesforce API Client

```kotlin
// SalesforceApiClient.kt
class SalesforceApiClient(private val context: Context) {

    private val baseUrl = "https://abbyluggery179.my.salesforce.com"
    private val oauthManager = OAuthManager(context)

    private val retrofit = Retrofit.Builder()
        .baseUrl(baseUrl)
        .addConverterFactory(GsonConverterFactory.create())
        .client(
            OkHttpClient.Builder()
                .addInterceptor(AuthInterceptor(oauthManager))
                .build()
        )
        .build()

    private val service = retrofit.create(SalesforceApiService::class.java)

    suspend fun createDailyRoutine(routine: DailyRoutine): Result<String> {
        return try {
            val request = DailyRoutineRequest(
                Mood_Level__c = routine.moodLevel,
                Energy_Level__c = routine.energyLevel,
                Pain_Level__c = routine.painLevel,
                Sleep_Quality__c = routine.sleepQuality,
                Date__c = SimpleDateFormat("yyyy-MM-dd").format(Date(routine.date))
            )
            val response = service.createDailyRoutine(request)
            Result.success(response.id)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createWinEntry(win: WinEntry): Result<String> {
        return try {
            val request = WinEntryRequest(
                Description__c = win.description,
                Category__c = win.category,
                Date__c = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(Date(win.timestamp))
            )
            val response = service.createWinEntry(request)
            Result.success(response.id)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createJobPosting(job: JobPosting): Result<String> {
        return try {
            val request = JobPostingRequest(
                Job_Title__c = job.jobTitle,
                Company_Name__c = job.companyName,
                Job_URL__c = job.url,
                Salary_Min__c = job.salaryMin,
                Salary_Max__c = job.salaryMax,
                Remote_Policy__c = job.remotePolicy,
                Description__c = job.description
            )
            val response = service.createJobPosting(request)
            Result.success(response.id)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun fetchMoodEntries(startDate: Long, endDate: Long): Result<List<SalesforceMoodEntry>> {
        return try {
            val start = SimpleDateFormat("yyyy-MM-dd").format(Date(startDate))
            val end = SimpleDateFormat("yyyy-MM-dd").format(Date(endDate))
            val query = "SELECT Id, Mood_Level__c, Energy_Level__c, Pain_Level__c, CreatedDate " +
                       "FROM Daily_Routine__c WHERE Date__c >= $start AND Date__c <= $end " +
                       "ORDER BY Date__c DESC"
            val response = service.query(query)
            Result.success(response.records)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

// SalesforceApiService.kt (Retrofit interface)
interface SalesforceApiService {

    @POST("/services/apexrest/DailyRoutineAPI/routines")
    suspend fun createDailyRoutine(@Body request: DailyRoutineRequest): SalesforceResponse

    @POST("/services/data/v59.0/sobjects/Win_Entry__c")
    suspend fun createWinEntry(@Body request: WinEntryRequest): SalesforceResponse

    @POST("/services/data/v59.0/sobjects/Job_Posting__c")
    suspend fun createJobPosting(@Body request: JobPostingRequest): SalesforceResponse

    @GET("/services/data/v59.0/query")
    suspend fun query(@Query("q") soql: String): QueryResponse
}

// OAuthManager.kt
class OAuthManager(private val context: Context) {

    private val prefs = context.getSharedPreferences("oauth", Context.MODE_PRIVATE)
    private val encryptedPrefs = EncryptedSharedPreferences.create(
        "oauth_encrypted",
        MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC),
        context,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    private val clientId = "YOUR_CONNECTED_APP_CLIENT_ID"
    private val clientSecret = "YOUR_CONNECTED_APP_CLIENT_SECRET"
    private val redirectUri = "neurothrive://oauth/callback"
    private val authUrl = "https://login.salesforce.com/services/oauth2/authorize"
    private val tokenUrl = "https://login.salesforce.com/services/oauth2/token"

    suspend fun getAccessToken(): String? {
        val token = encryptedPrefs.getString("access_token", null)
        if (token != null && !isTokenExpired()) {
            return token
        }
        return refreshAccessToken()
    }

    private suspend fun refreshAccessToken(): String? {
        val refreshToken = encryptedPrefs.getString("refresh_token", null) ?: return null

        val response = withContext(Dispatchers.IO) {
            val client = OkHttpClient()
            val request = Request.Builder()
                .url(tokenUrl)
                .post(
                    FormBody.Builder()
                        .add("grant_type", "refresh_token")
                        .add("refresh_token", refreshToken)
                        .add("client_id", clientId)
                        .add("client_secret", clientSecret)
                        .build()
                )
                .build()

            client.newCall(request).execute()
        }

        if (response.isSuccessful) {
            val json = JSONObject(response.body?.string() ?: "")
            val accessToken = json.getString("access_token")

            encryptedPrefs.edit()
                .putString("access_token", accessToken)
                .putLong("token_expires_at", System.currentTimeMillis() + 7200000) // 2 hours
                .apply()

            return accessToken
        }

        return null
    }

    private fun isTokenExpired(): Boolean {
        val expiresAt = encryptedPrefs.getLong("token_expires_at", 0)
        return System.currentTimeMillis() >= expiresAt
    }

    fun initiateOAuthFlow(activity: Activity) {
        val authUri = Uri.parse(authUrl)
            .buildUpon()
            .appendQueryParameter("response_type", "code")
            .appendQueryParameter("client_id", clientId)
            .appendQueryParameter("redirect_uri", redirectUri)
            .appendQueryParameter("scope", "api refresh_token offline_access")
            .build()

        val intent = Intent(Intent.ACTION_VIEW, authUri)
        activity.startActivity(intent)
    }
}
```

---

### 3. Sync Manager with Conflict Resolution

```kotlin
// SyncManager.kt
class SyncManager(
    private val context: Context,
    private val apiClient: SalesforceApiClient,
    private val database: AppDatabase
) {

    suspend fun syncAll(): SyncResult {
        val results = mutableListOf<SyncItemResult>()

        // Sync mood entries
        results.addAll(syncMoodEntries())

        // Sync win entries
        results.addAll(syncWinEntries())

        // Sync job postings
        results.addAll(syncJobPostings())

        // Pull new data from Salesforce
        pullFromSalesforce()

        return SyncResult(
            totalItems = results.size,
            successCount = results.count { it.success },
            failureCount = results.count { !it.success },
            items = results
        )
    }

    private suspend fun syncMoodEntries(): List<SyncItemResult> {
        val unsyncedEntries = database.moodEntryDao().getUnsynced()
        return unsyncedEntries.map { entry ->
            val result = apiClient.createDailyRoutine(
                DailyRoutine(
                    id = entry.id,
                    date = entry.timestamp,
                    moodLevel = entry.moodLevel,
                    energyLevel = entry.energyLevel,
                    painLevel = entry.painLevel
                )
            )

            if (result.isSuccess) {
                database.moodEntryDao().update(
                    entry.copy(
                        syncedToSalesforce = true,
                        salesforceId = result.getOrNull()
                    )
                )
                SyncItemResult(id = entry.id, success = true, type = "MoodEntry")
            } else {
                SyncItemResult(
                    id = entry.id,
                    success = false,
                    type = "MoodEntry",
                    error = result.exceptionOrNull()?.message
                )
            }
        }
    }

    private suspend fun syncWinEntries(): List<SyncItemResult> {
        val unsyncedEntries = database.winEntryDao().getUnsynced()
        return unsyncedEntries.map { entry ->
            val result = apiClient.createWinEntry(entry)

            if (result.isSuccess) {
                database.winEntryDao().update(
                    entry.copy(
                        syncedToSalesforce = true,
                        salesforceId = result.getOrNull()
                    )
                )
                SyncItemResult(id = entry.id, success = true, type = "WinEntry")
            } else {
                SyncItemResult(
                    id = entry.id,
                    success = false,
                    type = "WinEntry",
                    error = result.exceptionOrNull()?.message
                )
            }
        }
    }

    private suspend fun pullFromSalesforce() {
        val lastSyncTime = getLastSyncTimestamp()
        val currentTime = System.currentTimeMillis()

        // Fetch mood entries from Salesforce created/modified after last sync
        val moodResult = apiClient.fetchMoodEntries(lastSyncTime, currentTime)
        if (moodResult.isSuccess) {
            val entries = moodResult.getOrNull() ?: emptyList()
            entries.forEach { salesforceEntry ->
                val localEntry = database.moodEntryDao().getBySalesforceId(salesforceEntry.Id)

                if (localEntry == null) {
                    // New entry from Salesforce - insert locally
                    database.moodEntryDao().insert(
                        MoodEntry(
                            id = UUID.randomUUID().toString(),
                            moodLevel = salesforceEntry.Mood_Level__c,
                            energyLevel = salesforceEntry.Energy_Level__c,
                            painLevel = salesforceEntry.Pain_Level__c,
                            timestamp = parseDate(salesforceEntry.CreatedDate),
                            syncedToSalesforce = true,
                            salesforceId = salesforceEntry.Id
                        )
                    )
                } else {
                    // Conflict resolution: last-write-wins
                    val salesforceModified = parseDate(salesforceEntry.LastModifiedDate)
                    if (salesforceModified > localEntry.timestamp) {
                        database.moodEntryDao().update(
                            localEntry.copy(
                                moodLevel = salesforceEntry.Mood_Level__c,
                                energyLevel = salesforceEntry.Energy_Level__c,
                                painLevel = salesforceEntry.Pain_Level__c,
                                timestamp = salesforceModified
                            )
                        )
                    }
                }
            }
        }

        setLastSyncTimestamp(currentTime)
    }
}

// SyncWorker.kt (WorkManager for background sync)
class SyncWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val database = AppDatabase.getInstance(applicationContext)
        val apiClient = SalesforceApiClient(applicationContext)
        val syncManager = SyncManager(applicationContext, apiClient, database)

        return try {
            val result = syncManager.syncAll()
            if (result.failureCount == 0) {
                Result.success()
            } else {
                Result.retry()
            }
        } catch (e: Exception) {
            Log.e("SyncWorker", "Sync failed", e)
            Result.retry()
        }
    }

    companion object {
        fun schedulePeriodicSync(context: Context) {
            val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(
                15, TimeUnit.MINUTES
            )
                .setConstraints(
                    Constraints.Builder()
                        .setRequiredNetworkType(NetworkType.CONNECTED)
                        .build()
                )
                .build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                "salesforce_sync",
                ExistingPeriodicWorkPolicy.KEEP,
                syncRequest
            )
        }
    }
}
```

---

### 4. Voice Command Processing

```kotlin
// VoiceCommandProcessor.kt
class VoiceCommandProcessor(
    private val context: Context,
    private val database: AppDatabase,
    private val syncQueue: SyncQueue,
    private val claudeClient: ClaudeApiClient
) {

    private val ttsManager = TTSManager(context)

    suspend fun process(command: String): CommandResult {
        val intent = IntentClassifier.classify(command)

        return when (intent) {
            CommandIntent.LOG_MOOD -> handleMoodLog(command)
            CommandIntent.LOG_WIN -> handleWinLog(command)
            CommandIntent.CHECK_JOBS -> handleJobCheck()
            CommandIntent.WEEKLY_ANALYSIS -> handleWeeklyAnalysis()
            CommandIntent.INTERVIEW_PREP -> handleInterviewPrep(command)
            CommandIntent.MEAL_PLAN_CHECK -> handleMealPlanCheck()
            CommandIntent.QUICK_NOTE -> handleQuickNote(command)
            CommandIntent.UNKNOWN -> handleWithClaude(command)
        }
    }

    private suspend fun handleMoodLog(command: String): CommandResult {
        // Extract mood/energy from natural language
        val nlp = NLPProcessor()
        val mood = nlp.extractMoodLevel(command) ?: 5
        val energy = nlp.extractEnergyLevel(command) ?: 5
        val pain = nlp.extractPainLevel(command) ?: 0

        // Save to local database
        val entry = MoodEntry(
            moodLevel = mood,
            energyLevel = energy,
            painLevel = pain,
            notes = command
        )
        database.moodEntryDao().insert(entry)

        // Queue for Salesforce sync
        syncQueue.add(SyncOperation.CREATE_MOOD_ENTRY, entry.id)

        // Generate response
        val response = buildMoodResponse(mood, energy, pain)

        // Speak response
        ttsManager.speak(response)

        return CommandResult(
            success = true,
            message = response,
            data = entry
        )
    }

    private fun buildMoodResponse(mood: Int, energy: Int, pain: Int): String {
        return when {
            mood >= 8 && energy >= 7 -> "That's wonderful! Your mood is ${mood} and energy is ${energy}. You're thriving today! 💙"
            mood >= 6 && energy >= 5 -> "Good to hear you're at ${mood} for mood and ${energy} for energy. Keep going! ✨"
            mood >= 4 -> "I hear you're at ${mood}. Some days are harder. Your feelings are valid. 💙"
            else -> "I'm here with you at ${mood}. You're not alone. Take it one moment at a time. 💙"
        }
    }

    private suspend fun handleWinLog(command: String): CommandResult {
        // Extract win description
        val description = command
            .replace(Regex("(?i)log (a )?win:?"), "")
            .replace(Regex("(?i)I (just )?"), "")
            .trim()

        // Save to database
        val win = WinEntry(
            description = description,
            category = categorizeWin(description)
        )
        database.winEntryDao().insert(win)

        // Queue for sync
        syncQueue.add(SyncOperation.CREATE_WIN_ENTRY, win.id)

        val response = "Awesome! I've logged: \"$description\". That's your superpower showing! 🎉"
        ttsManager.speak(response)

        return CommandResult(
            success = true,
            message = response,
            data = win
        )
    }

    private suspend fun handleJobCheck(): CommandResult {
        // Query Salesforce for new jobs with high fit scores
        val jobs = database.jobPostingDao().getHighFitJobs(minScore = 8.0)

        val response = if (jobs.isEmpty()) {
            "No new high-priority jobs right now. Keep manifesting! ✨"
        } else {
            val topJob = jobs.first()
            "You have ${jobs.size} new matches! Top one: ${topJob.jobTitle} at ${topJob.companyName} " +
            "with a fit score of ${topJob.fitScore}/10. Want details?"
        }

        ttsManager.speak(response)

        return CommandResult(
            success = true,
            message = response,
            data = jobs
        )
    }

    private suspend fun handleWeeklyAnalysis(): CommandResult {
        val startOfWeek = getStartOfWeek()
        val moodEntries = database.moodEntryDao().getEntriesBetween(startOfWeek, System.currentTimeMillis())

        if (moodEntries.isEmpty()) {
            return CommandResult(
                success = false,
                message = "No mood data logged this week yet."
            )
        }

        val avgMood = moodEntries.map { it.moodLevel }.average()
        val avgEnergy = moodEntries.map { it.energyLevel }.average()
        val wins = database.winEntryDao().getWinsSince(startOfWeek).size

        // Use Claude to generate insightful analysis
        val prompt = """
            Analyze this week's wellness data for a neurodivergent professional:
            - Average mood: ${avgMood.format(1)}/10
            - Average energy: ${avgEnergy.format(1)}/10
            - Wins logged: $wins
            - Daily entries: ${moodEntries.size}/7

            Provide:
            1. Encouraging observation about their week
            2. One specific strength or pattern you notice
            3. One gentle suggestion for the coming week

            Keep it warm, affirming, and neurodivergent-friendly (ADHD/Bipolar/Autistic perspective).
        """.trimIndent()

        val analysis = claudeClient.generateText(prompt)

        ttsManager.speak(analysis)

        return CommandResult(
            success = true,
            message = analysis,
            data = mapOf(
                "avgMood" to avgMood,
                "avgEnergy" to avgEnergy,
                "wins" to wins
            )
        )
    }

    private suspend fun handleInterviewPrep(command: String): CommandResult {
        // Extract company name
        val company = command
            .replace(Regex("(?i)prepare for interview (at|with) "), "")
            .trim()

        // Fetch company research from Salesforce
        val research = database.jobPostingDao().getJobsByCompany(company).firstOrNull()

        if (research == null) {
            return CommandResult(
                success = false,
                message = "I don't have research on $company yet. Would you like me to research them?"
            )
        }

        // Use Claude to generate interview prep
        val prompt = """
            Prepare interview guidance for:
            Company: ${research.companyName}
            Role: ${research.jobTitle}
            ND Friendliness: ${research.ndFriendlinessScore}/10
            Green Flags: ${research.greenFlags}
            Red Flags: ${research.redFlags}

            Provide:
            1. Top 3 questions to expect
            2. Key talking points highlighting neurodivergent strengths
            3. One question to ask them about ND accommodations

            Be empowering and confidence-building.
        """.trimIndent()

        val guidance = claudeClient.generateText(prompt)

        ttsManager.speak("Here's your interview prep for $company")

        return CommandResult(
            success = true,
            message = guidance,
            data = research
        )
    }

    private suspend fun handleWithClaude(command: String): CommandResult {
        // For unknown intents, send to Claude with full context
        val context = buildUserContext()
        val prompt = """
            User context:
            $context

            User said: "$command"

            Respond as their personal assistant. Be warm, affirming, and helpful.
        """.trimIndent()

        val response = claudeClient.generateText(prompt)
        ttsManager.speak(response)

        return CommandResult(
            success = true,
            message = response
        )
    }

    private suspend fun buildUserContext(): String {
        val today = System.currentTimeMillis()
        val startOfDay = getStartOfDay(today)

        val todayMood = database.moodEntryDao().getEntriesBetween(startOfDay, today).lastOrNull()
        val recentWins = database.winEntryDao().getWinsSince(startOfDay)
        val recentJobs = database.jobPostingDao().getRecentJobs(limit = 5)

        return """
            Today's mood: ${todayMood?.moodLevel}/10
            Today's energy: ${todayMood?.energyLevel}/10
            Today's wins: ${recentWins.size}
            Recent job applications: ${recentJobs.size}
        """.trimIndent()
    }
}

// IntentClassifier.kt
object IntentClassifier {

    fun classify(command: String): CommandIntent {
        val lower = command.lowercase()

        return when {
            lower.matches(Regex(".*mood (is |level )?\\d+.*")) -> CommandIntent.LOG_MOOD
            lower.contains("feeling") && lower.matches(Regex(".*\\d+.*")) -> CommandIntent.LOG_MOOD
            lower.contains("log win") || lower.contains("achieved") -> CommandIntent.LOG_WIN
            lower.contains("new job") || lower.contains("job match") -> CommandIntent.CHECK_JOBS
            lower.contains("how am i") || lower.contains("this week") -> CommandIntent.WEEKLY_ANALYSIS
            lower.contains("prepare for interview") || lower.contains("interview at") -> CommandIntent.INTERVIEW_PREP
            lower.contains("meal plan") || lower.contains("what's for") -> CommandIntent.MEAL_PLAN_CHECK
            lower.startsWith("note:") || lower.startsWith("remember") -> CommandIntent.QUICK_NOTE
            else -> CommandIntent.UNKNOWN
        }
    }
}

enum class CommandIntent {
    LOG_MOOD,
    LOG_WIN,
    CHECK_JOBS,
    WEEKLY_ANALYSIS,
    INTERVIEW_PREP,
    MEAL_PLAN_CHECK,
    QUICK_NOTE,
    UNKNOWN
}
```

---

## 🔐 SECURITY & PRIVACY REQUIREMENTS

### Data Encryption
```kotlin
// SecurityUtils.kt
object SecurityUtils {

    private val keyAlias = "neurothrive_master_key"

    fun encrypt(data: String): String {
        val keyStore = KeyStore.getInstance("AndroidKeyStore")
        keyStore.load(null)

        if (!keyStore.containsAlias(keyAlias)) {
            generateKey()
        }

        val secretKey = keyStore.getKey(keyAlias, null) as SecretKey
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, secretKey)

        val iv = cipher.iv
        val encrypted = cipher.doFinal(data.toByteArray())

        // Combine IV + encrypted data
        return Base64.encodeToString(iv + encrypted, Base64.DEFAULT)
    }

    fun decrypt(encryptedData: String): String {
        val keyStore = KeyStore.getInstance("AndroidKeyStore")
        keyStore.load(null)

        val secretKey = keyStore.getKey(keyAlias, null) as SecretKey
        val decoded = Base64.decode(encryptedData, Base64.DEFAULT)

        // Split IV and encrypted data
        val iv = decoded.sliceArray(0..11)
        val encrypted = decoded.sliceArray(12 until decoded.size)

        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.DECRYPT_MODE, secretKey, GCMParameterSpec(128, iv))

        return String(cipher.doFinal(encrypted))
    }

    private fun generateKey() {
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            "AndroidKeyStore"
        )

        val keyGenParameterSpec = KeyGenParameterSpec.Builder(
            keyAlias,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .build()

        keyGenerator.init(keyGenParameterSpec)
        keyGenerator.generateKey()
    }
}
```

---

## 📦 DEPENDENCIES (build.gradle.kts)

```kotlin
dependencies {
    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.20")

    // AndroidX Core
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.2")
    implementation("androidx.activity:activity-compose:1.8.1")

    // Jetpack Compose
    implementation(platform("androidx.compose:compose-bom:2023.10.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")

    // Room Database
    val roomVersion = "2.6.0"
    implementation("androidx.room:room-runtime:$roomVersion")
    implementation("androidx.room:room-ktx:$roomVersion")
    kapt("androidx.room:room-compiler:$roomVersion")

    // Retrofit (Salesforce API)
    val retrofitVersion = "2.9.0"
    implementation("com.squareup.retrofit2:retrofit:$retrofitVersion")
    implementation("com.squareup.retrofit2:converter-gson:$retrofitVersion")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")

    // Gson (JSON parsing)
    implementation("com.google.code.gson:gson:2.10.1")

    // WorkManager (Background sync)
    implementation("androidx.work:work-runtime-ktx:2.9.0")

    // Security (Encryption)
    implementation("androidx.security:security-crypto:1.1.0-alpha06")

    // Hilt (Dependency Injection)
    val hiltVersion = "2.48"
    implementation("com.google.dagger:hilt-android:$hiltVersion")
    kapt("com.google.dagger:hilt-compiler:$hiltVersion")
    implementation("androidx.hilt:hilt-navigation-compose:1.1.0")
    implementation("androidx.hilt:hilt-work:1.1.0")

    // Charts (MPAndroidChart)
    implementation("com.github.PhilJay:MPAndroidChart:v3.1.0")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

    // Logging
    implementation("com.jakewharton.timber:timber:5.0.1")

    // Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("androidx.room:room-testing:$roomVersion")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation(platform("androidx.compose:compose-bom:2023.10.01"))
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}
```

---

## ✅ SUCCESS CRITERIA

### Session 1 Success:
- [ ] Android project builds without errors
- [ ] SQLite database creates all tables
- [ ] All DAOs functional with CRUD operations
- [ ] Unit tests pass (100% coverage on DAOs)
- [ ] Data encryption verified

### Session 2 Success:
- [ ] OAuth login flow completes successfully
- [ ] Access token retrieval works
- [ ] Refresh token rotation works
- [ ] API client creates records in Salesforce
- [ ] Sync queue handles offline operations
- [ ] Integration tests pass

### Session 3 Success:
- [ ] Voice commands classified correctly
- [ ] Mood log saves to database
- [ ] Win log queues for sync
- [ ] Claude API integration returns responses
- [ ] TTS speaks responses
- [ ] Context preserved between commands

### Session 4 Success:
- [ ] Dashboard displays all 4 summary cards
- [ ] Mood trend chart renders 7-day data
- [ ] Quick actions trigger correct screens
- [ ] Dark theme support works
- [ ] Accessibility labels present
- [ ] UI tests pass

---

## 🚀 DEPLOYMENT COMMANDS

### Session 1: Database Layer
```bash
# Navigate to Android project
cd android

# Build project
./gradlew build

# Run unit tests
./gradlew test

# Run Room schema validation
./gradlew kaptDebugKotlin

# Commit to GitHub
git add .
git commit -m "feat: implement SQLite database with encryption"
git push origin main
```

### Session 2: Salesforce Integration
```bash
# Build with API integration
./gradlew build

# Run integration tests (requires Salesforce sandbox)
./gradlew connectedAndroidTest

# Commit
git add .
git commit -m "feat: implement Salesforce OAuth and REST API client"
git push origin main
```

### Session 3: Voice Commands
```bash
# Build voice module
./gradlew :app:assembleDebug

# Install on test device
adb install -r app/build/outputs/apk/debug/app-debug.apk

# Test voice commands
adb shell am start -n com.neurothrive.assistant/.MainActivity

# Commit
git add .
git commit -m "feat: implement voice command processing with Claude AI"
git push origin main
```

### Session 4: Dashboard UI
```bash
# Build release APK
./gradlew assembleRelease

# Generate screenshots
./gradlew executeScreenshotTests

# Commit
git add .
git commit -m "feat: build Material Design 3 dashboard with summary cards"
git push origin main
```

---

## 📋 VALIDATION CHECKLIST

### Code Quality
- [ ] All Kotlin files follow Android conventions
- [ ] No hardcoded strings (use strings.xml)
- [ ] All API keys stored in BuildConfig (not committed)
- [ ] Proper error handling (try-catch, Result types)
- [ ] Logging with Timber (no Log.d/Log.e)
- [ ] Comments on complex logic
- [ ] Ktlint formatting applied

### Security
- [ ] API keys NOT in version control
- [ ] OAuth tokens encrypted with EncryptedSharedPreferences
- [ ] Database encryption enabled
- [ ] HTTPS only for API calls
- [ ] Certificate pinning for Salesforce API
- [ ] ProGuard rules configured for release

### Performance
- [ ] Database queries on background thread
- [ ] API calls use Retrofit with coroutines
- [ ] Images lazy-loaded
- [ ] List recycling (LazyColumn)
- [ ] No memory leaks (check with LeakCanary)

### Accessibility
- [ ] All interactive elements have contentDescription
- [ ] Text contrast meets WCAG AA
- [ ] Font sizes respect user preferences
- [ ] TalkBack tested and working

### Testing
- [ ] Unit tests: 80%+ coverage
- [ ] Integration tests for API client
- [ ] UI tests for critical flows
- [ ] Manual testing on 3+ devices
- [ ] Accessibility testing with TalkBack

---

## 🔧 TROUBLESHOOTING GUIDE

### Issue: OAuth fails with "invalid_client"
**Solution:**
1. Verify Connected App Client ID/Secret
2. Check callback URL matches: `neurothrive://oauth/callback`
3. Ensure app is set as "Permitted Users: All users may self-authorize"

### Issue: Database migration error
**Solution:**
```kotlin
// In AppDatabase.kt, add fallback strategy for testing:
.fallbackToDestructiveMigration()

// For production, implement proper migration:
val MIGRATION_1_2 = object : Migration(1, 2) {
    override fun migrate(database: SupportSQLiteDatabase) {
        database.execSQL("ALTER TABLE mood_entries ADD COLUMN notes TEXT")
    }
}
```

### Issue: Sync fails silently
**Solution:**
1. Check WorkManager logs: `adb logcat | grep SyncWorker`
2. Verify network constraints are met
3. Check Salesforce API limits (not exceeded)
4. Ensure access token not expired

### Issue: Voice commands not recognized
**Solution:**
1. Check Intent classification regex patterns
2. Test with exact phrases from documentation
3. Verify microphone permissions granted
4. Check Android Assistant integration settings

---

## 📚 ADDITIONAL RESOURCES

### Documentation to Create
1. **USER_GUIDE.md** - End-user setup instructions
2. **API_INTEGRATION.md** - Salesforce API endpoints reference
3. **VOICE_COMMANDS.md** - List of all supported voice commands
4. **PRIVACY_POLICY.md** - Data handling and privacy practices
5. **CONTRIBUTING.md** - How to contribute to the project

### Architecture Diagrams Needed
1. **System Architecture** - High-level component diagram
2. **Data Flow** - How data moves between Android → Salesforce
3. **Sync Process** - Flowchart of sync logic with conflict resolution
4. **Voice Command Flow** - Intent classification → Execution → Response

---

## 🎯 FINAL DELIVERABLES

### Session 1
- Android project with database layer
- Unit tests passing
- Commit: `feat: implement SQLite database with encryption`

### Session 2
- OAuth 2.0 authentication working
- API client connecting to Salesforce
- Sync manager functional
- Commit: `feat: implement Salesforce OAuth and REST API client`

### Session 3
- Voice commands processing correctly
- Claude AI integration complete
- TTS responses working
- Commit: `feat: implement voice command processing with Claude AI`

### Session 4
- Dashboard UI complete
- All summary cards displaying data
- Mood trend chart rendering
- Commit: `feat: build Material Design 3 dashboard with summary cards`

### Final Commit
```bash
git add .
git commit -m "release: Claude Personal Assistant v1.0 - Android app complete

Features:
- SQLite database with AES-256 encryption
- Salesforce OAuth 2.0 integration
- REST API client with sync queue
- Voice command processing
- Claude AI integration for insights
- Material Design 3 dashboard
- Offline-first architecture
- Neurodivergent-friendly UX

Closes #1, #2, #3, #4"

git tag v1.0.0
git push origin main --tags
```

---

## 🎉 SUCCESS METRICS

**Code Completion**: 60% → 90% (+30%)
**Lines of Code**: ~1,900 → ~5,000 (+3,100)
**Features Complete**: 5 → 20 (+15)
**Time Investment**: 40 hours → 52 hours (+12)

**Production Ready**: ✅
**App Store Ready**: ✅
**Salesforce Integrated**: ✅
**Privacy Compliant**: ✅

---

**Package Created**: November 16, 2025
**Estimated Completion**: November 20-23, 2025
**Status**: Ready for Claude Code execution

🚀 **Let's finish building your neurodivergent-affirming personal assistant!** 💙✨
