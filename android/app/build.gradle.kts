// Apply necessary plugins
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // **** ADDED: Apply the Google services plugin ****
    // Note: Sometimes placed here, sometimes at the bottom. Bottom is usually safer.
    // If build fails, try moving the line below to the very end of the file.
    // id("com.google.gms.google-services")
}

// Function to load properties like Flutter SDK paths
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

// Define Flutter SDK versions or retrieve them
def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    // throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
    // Fallback or default logic if needed, but ideally local.properties defines it.
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

// Define Android SDK versions
def androidCompileSdkVersion = 34 // Use a recent SDK version
def androidTargetSdkVersion = 34 // Match compileSdk
def androidMinSdkVersion = 21    // Common minimum for Firebase


android {
    namespace = "com.example.flutter_application_2" // Make sure this matches your actual package name
    compileSdk = androidCompileSdkVersion
    // ndkVersion = flutter.ndkVersion // Retrieve ndkVersion if needed, often set by Flutter plugin

    compileOptions {
        // Use Java 1.8 compatibility - Standard for most Android/Flutter projects
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        // Use JVM target 1.8
        jvmTarget = '1.8'
    }

    // Define source sets if needed (usually handled by Flutter)
    // sourceSets {
    //     main.java.srcDirs += 'src/main/kotlin'
    // }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_application_2" // **Ensure this is YOUR app's ID**

        minSdk = androidMinSdkVersion
        targetSdk = androidTargetSdkVersion
        versionCode = flutterVersionCode.toInteger()
        versionName = flutterVersionName

        // **** ADDED: Enable multidex for Firebase ****
        multiDexEnabled true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug") // Keep existing signing config

            // Optional: Proguard/R8 settings for release builds
            // minifyEnabled true // Enable code shrinking & obfuscation
            // shrinkResources true // Remove unused resources
            // proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        // debug {
            // Debug specific settings if needed
        // }
    }

    // Optional: Packaging options if needed
    // packagingOptions {
    //     exclude 'META-INF/AL2.0'
    //     exclude 'META-INF/LGPL2.1'
    // }
}

flutter {
    source = "../.."
}

dependencies {
    // **** ADDED: Import the Firebase BoM ****
    // Find the latest version at https://firebase.google.com/docs/android/setup#available-libraries
    implementation platform('com.google.firebase:firebase-bom:32.7.4') // Use a recent BoM version

    // **** ADDED: Declare dependencies for Firebase products without versions ****
    // Add the dependencies for the Firebase products you want to use
    implementation 'com.google.firebase:firebase-analytics-ktx' // Recommended for analytics
    implementation 'com.google.firebase:firebase-auth-ktx'      // For Firebase Authentication
    implementation 'com.google.firebase:firebase-firestore-ktx' // For Cloud Firestore
    // implementation 'com.google.firebase:firebase-storage-ktx' // Uncomment if using Cloud Storage
    // Add other Firebase dependencies here (e.g., Crashlytics, Database, etc.)

    // **** ADDED: Multidex dependency ****
    implementation 'androidx.multidex:multidex:2.0.1'

    // Standard Kotlin dependency (version often inferred from project level or plugin)
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8" // Use the version defined in ext or inferred

    // Add other app dependencies here if you have any
    // implementation "androidx.core:core-ktx:..."
    // implementation "androidx.appcompat:appcompat:..."

}

// **** ADDED: Apply the Google services plugin AT THE END ****
// This plugin reads the google-services.json file
apply plugin: 'com.google.gms.google-services'