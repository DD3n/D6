buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Update to a compatible Android Gradle Plugin version for Gradle 7.6
        classpath("com.android.tools.build:gradle:7.4.0")
        // Google Services plugin version required for Firebase
        classpath("com.google.gms:google-services:4.3.15")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Set a custom build directory (adjust as needed)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

