# 🚀 CLAUDE ASSISTANT - QUICK START GUIDE
## Fast-Track Execution Reference for Claude Code

**Execution Time**: 12-16 hours (4 sessions × 3-4 hours)
**Target**: 60% → 90% completion
**Repository**: https://github.com/abbyluggery/Claude-Personal-Assistant

---

## ⚡ RAPID EXECUTION COMMANDS

### SESSION 1: Database Layer (3-4 hours)

**Create Android project:**
```bash
cd /path/to/repo
mkdir -p android/app/src/main/java/com/neurothrive/assistant/{data,ui,api,voice}
mkdir -p android/app/src/main/res/values

# Copy build.gradle.kts dependencies from CLAUDE_ASSISTANT_COMPLETION_PACKAGE.md

# Create AppDatabase.kt
cat > android/app/src/main/java/com/neurothrive/assistant/data/AppDatabase.kt << 'EOF'
// [Full database code from package]
EOF

# Create all entity classes
# MoodEntry.kt, WinEntry.kt, JobPosting.kt, DailyRoutine.kt

# Create all DAO interfaces
# MoodEntryDao.kt, WinEntryDao.kt, JobPostingDao.kt, DailyRoutineDao.kt

# Build and test
./gradlew build
./gradlew test

# Commit
git add .
git commit -m "feat: implement SQLite database with AES-256 encryption"
git push origin main
```

**Success Criteria:**
- ✅ Build passes
- ✅ All tests green
- ✅ Database creates 4 tables

---

### SESSION 2: Salesforce Integration (3-4 hours)

**Create Salesforce Connected App:**
1. Login to Salesforce org: abbyluggery179@agentforce.com
2. Setup → App Manager → New Connected App
3. Name: "Claude Personal Assistant"
4. Callback URL: `neurothrive://oauth/callback`
5. OAuth Scopes: `api`, `refresh_token`, `offline_access`
6. Save and copy Consumer Key + Consumer Secret

**Implement OAuth & API Client:**
```bash
# Create OAuthManager.kt
cat > android/app/src/main/java/com/neurothrive/assistant/api/auth/OAuthManager.kt << 'EOF'
// [Full OAuth code from package]
EOF

# Create SalesforceApiClient.kt
cat > android/app/src/main/java/com/neurothrive/assistant/api/SalesforceApiClient.kt << 'EOF'
// [Full API client code from package]
EOF

# Create SyncManager.kt
cat > android/app/src/main/java/com/neurothrive/assistant/api/sync/SyncManager.kt << 'EOF'
// [Full sync manager code from package]
EOF

# Update BuildConfig with Connected App credentials
echo 'buildConfigField("String", "SALESFORCE_CLIENT_ID", "\"YOUR_CONSUMER_KEY\"")' >> app/build.gradle.kts
echo 'buildConfigField("String", "SALESFORCE_CLIENT_SECRET", "\"YOUR_CONSUMER_SECRET\"")' >> app/build.gradle.kts

# Test integration
./gradlew connectedAndroidTest

# Commit
git add .
git commit -m "feat: implement Salesforce OAuth and REST API client"
git push origin main
```

**Success Criteria:**
- ✅ OAuth flow completes
- ✅ Access token retrieved
- ✅ API calls succeed

---

### SESSION 3: Voice Commands (3-4 hours)

**Implement voice processing:**
```bash
# Create VoiceCommandProcessor.kt
cat > android/app/src/main/java/com/neurothrive/assistant/voice/VoiceCommandProcessor.kt << 'EOF'
// [Full voice processor code from package]
EOF

# Create IntentClassifier.kt
cat > android/app/src/main/java/com/neurothrive/assistant/voice/IntentClassifier.kt << 'EOF'
// [Full intent classifier code from package]
EOF

# Create ClaudeApiClient.kt
cat > android/app/src/main/java/com/neurothrive/assistant/api/ClaudeApiClient.kt << 'EOF'
// [Full Claude client code from package]
EOF

# Add Claude API key to BuildConfig
echo 'buildConfigField("String", "CLAUDE_API_KEY", "\"YOUR_CLAUDE_API_KEY\"")' >> app/build.gradle.kts

# Test voice commands
./gradlew :app:assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk

# Commit
git add .
git commit -m "feat: implement voice command processing with Claude AI"
git push origin main
```

**Success Criteria:**
- ✅ Intents classify correctly
- ✅ Commands execute
- ✅ Claude responses generated

---

### SESSION 4: Dashboard UI (2-3 hours)

**Build Material Design 3 dashboard:**
```bash
# Create HomeScreen.kt
cat > android/app/src/main/java/com/neurothrive/assistant/ui/home/HomeScreen.kt << 'EOF'
// [Full HomeScreen composable from package]
EOF

# Create summary cards
# JobSearchCard.kt, WellnessCard.kt, MealPlanningCard.kt, SavingsCard.kt

# Create MoodTrendChart.kt
cat > android/app/src/main/java/com/neurothrive/assistant/ui/components/MoodTrendChart.kt << 'EOF'
// [Full chart code from package]
EOF

# Build release APK
./gradlew assembleRelease

# Commit
git add .
git commit -m "feat: build Material Design 3 dashboard with summary cards"
git push origin main
```

**Success Criteria:**
- ✅ Dashboard renders
- ✅ All cards display data
- ✅ Charts render correctly

---

## 📦 COPY-PASTE FILE TEMPLATES

### build.gradle.kts (App Level)
```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.kapt")
    id("com.google.dagger.hilt.android")
}

android {
    namespace = "com.neurothrive.assistant"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.neurothrive.assistant"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        // BuildConfig fields (REPLACE WITH ACTUAL VALUES)
        buildConfigField("String", "SALESFORCE_CLIENT_ID", "\"YOUR_CONSUMER_KEY\"")
        buildConfigField("String", "SALESFORCE_CLIENT_SECRET", "\"YOUR_CONSUMER_SECRET\"")
        buildConfigField("String", "CLAUDE_API_KEY", "\"YOUR_CLAUDE_API_KEY\"")
        buildConfigField("String", "SALESFORCE_BASE_URL", "\"https://abbyluggery179.my.salesforce.com\"")
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.4"
    }
}

dependencies {
    // [Full dependencies from CLAUDE_ASSISTANT_COMPLETION_PACKAGE.md]
}
```

### AndroidManifest.xml
```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />

    <application
        android:name=".ClaudeAssistantApplication"
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.NeuroThrive"
        tools:targetApi="31">

        <activity
            android:name=".ui.MainActivity"
            android:exported="true"
            android:theme="@style/Theme.NeuroThrive">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>

            <!-- OAuth callback -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="neurothrive"
                    android:host="oauth"
                    android:path="/callback" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

---

## 🧪 TEST COMMANDS

### Unit Tests
```bash
./gradlew test --tests "*.dao.*"
./gradlew test --tests "*Repository*"
./gradlew test --tests "*ViewModel*"
```

### Integration Tests
```bash
./gradlew connectedAndroidTest --tests "*.api.*"
./gradlew connectedAndroidTest --tests "*Sync*"
```

### UI Tests
```bash
./gradlew connectedAndroidTest --tests "*.ui.*"
```

### Manual Testing
```bash
# Install debug APK
./gradlew installDebug

# Clear app data
adb shell pm clear com.neurothrive.assistant

# Check logs
adb logcat | grep "NeuroThrive"

# Check database
adb shell
run-as com.neurothrive.assistant
cd databases
ls -la
```

---

## 🔑 API KEYS CONFIGURATION

### 1. Get Salesforce Connected App Credentials
```bash
# After creating Connected App in Salesforce:
# 1. Copy Consumer Key → SALESFORCE_CLIENT_ID
# 2. Copy Consumer Secret → SALESFORCE_CLIENT_SECRET
# 3. Update app/build.gradle.kts BuildConfig fields
```

### 2. Get Claude API Key
```bash
# 1. Login to https://console.anthropic.com/
# 2. Settings → API Keys → Create Key
# 3. Copy key → CLAUDE_API_KEY in BuildConfig
```

### 3. Create local.properties (DO NOT COMMIT)
```properties
# local.properties (add to .gitignore)
salesforce.client.id=YOUR_CONSUMER_KEY
salesforce.client.secret=YOUR_CONSUMER_SECRET
claude.api.key=YOUR_CLAUDE_API_KEY
```

### 4. Read from local.properties in build.gradle.kts
```kotlin
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

defaultConfig {
    buildConfigField(
        "String",
        "SALESFORCE_CLIENT_ID",
        "\"${localProperties.getProperty("salesforce.client.id", "")}\""
    )
    buildConfigField(
        "String",
        "SALESFORCE_CLIENT_SECRET",
        "\"${localProperties.getProperty("salesforce.client.secret", "")}\""
    )
    buildConfigField(
        "String",
        "CLAUDE_API_KEY",
        "\"${localProperties.getProperty("claude.api.key", "")}\""
    )
}
```

---

## 🐛 COMMON ERRORS & FIXES

### Error: "Duplicate class kotlin.collections.ArrayDeque"
**Fix:**
```kotlin
configurations.all {
    exclude(group = "org.jetbrains.kotlin", module = "kotlin-stdlib-jdk7")
    exclude(group = "org.jetbrains.kotlin", module = "kotlin-stdlib-jdk8")
}
```

### Error: "Room cannot verify data integrity"
**Fix:**
```kotlin
@Database(entities = [...], version = 1, exportSchema = false)
```

### Error: "Cleartext HTTP traffic not permitted"
**Fix:** Use HTTPS only for Salesforce API

### Error: "OAuth callback not received"
**Fix:**
1. Check AndroidManifest.xml has correct intent filter
2. Verify callback URL in Connected App matches: `neurothrive://oauth/callback`

---

## 📊 PROGRESS TRACKING

### Session 1 Checklist
- [ ] Android project created
- [ ] build.gradle.kts configured
- [ ] AppDatabase.kt created
- [ ] All entities created (4)
- [ ] All DAOs created (4)
- [ ] SecurityUtils.kt created
- [ ] Unit tests pass
- [ ] Committed and pushed

### Session 2 Checklist
- [ ] Connected App created in Salesforce
- [ ] OAuthManager.kt created
- [ ] SalesforceApiClient.kt created
- [ ] SyncManager.kt created
- [ ] SyncWorker.kt created
- [ ] API keys configured
- [ ] Integration tests pass
- [ ] Committed and pushed

### Session 3 Checklist
- [ ] VoiceCommandProcessor.kt created
- [ ] IntentClassifier.kt created
- [ ] ClaudeApiClient.kt created
- [ ] TTSManager.kt created
- [ ] Claude API key configured
- [ ] Voice commands tested
- [ ] Committed and pushed

### Session 4 Checklist
- [ ] HomeScreen.kt created
- [ ] 4 summary cards created
- [ ] MoodTrendChart.kt created
- [ ] QuickActionGrid.kt created
- [ ] Theme configured
- [ ] UI tests pass
- [ ] Committed and pushed

---

## 🎯 FINAL VERIFICATION

```bash
# 1. Build release APK
./gradlew assembleRelease

# 2. Run all tests
./gradlew test
./gradlew connectedAndroidTest

# 3. Check code coverage
./gradlew jacocoTestReport

# 4. Generate APK
ls -lh app/build/outputs/apk/release/app-release.apk

# 5. Tag release
git tag v1.0.0
git push origin v1.0.0

# 6. Verify on GitHub
# https://github.com/abbyluggery/Claude-Personal-Assistant/releases
```

---

## 🚀 POST-COMPLETION TASKS

### 1. Update README.md
```markdown
# Claude Personal Assistant

Android app for neurodivergent professionals with Salesforce integration.

## Features
- ✅ Voice command processing
- ✅ Salesforce OAuth 2.0 sync
- ✅ Claude AI insights
- ✅ Material Design 3 UI
- ✅ Offline-first architecture
- ✅ AES-256 encryption

## Setup
1. Clone repository
2. Copy `local.properties.template` to `local.properties`
3. Add API keys (see SETUP.md)
4. Build: `./gradlew build`
5. Install: `./gradlew installDebug`
```

### 2. Create SETUP.md
Document end-user setup process

### 3. Create CHANGELOG.md
Track version history

### 4. Add Screenshots
Capture dashboard, settings, voice commands

### 5. Publish to GitHub Releases
Upload APK with release notes

---

**Quick Start Guide Created**: November 16, 2025
**Estimated Time**: 12-16 hours
**Status**: Ready for execution

🚀 **Copy-paste and execute! Let's finish this!** 💙✨
