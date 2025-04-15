// Top-level build file where you can add configuration options common to all sub-projects/modules.

// **** ADDED for Firebase ****
buildscript {
    // Define versions in ext block for easy management
    ext {
        kotlin_version = '1.8.22' // Example: Use a version compatible with your Flutter/Gradle setup
        // Check Firebase documentation or Android Studio for the latest compatible google-services version
        google_services_version = '4.4.0' // Use a recent stable version
    }
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Add the dependency for the Google services Gradle plugin
        classpath "com.google.gms:google-services:$ext.google_services_version"

        // Add Kotlin plugin dependency if not automatically handled by Flutter/AGP
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$ext.kotlin_version"

        // Note: The Android Gradle plugin classpath is usually added by Flutter's plugin
        // classpath "com.android.tools.build:gradle:..."
    }
}
// **** END ADDED BLOCK ****


allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Keep your existing build directory logic
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}