// 1. 코틀린 버전 명시 및 AGP, 구글 서비스 클래스패스 추가
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // AGP(Android Gradle Plugin) 버전을 8.11.1 이상으로 업데이트 (경고 해결)
        classpath("com.android.tools.build:gradle:8.11.1")
        
        // Kotlin 버전을 2.2.20 이상으로 업데이트 (경고 해결)
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.20")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 2. 기존 빌드 경로 설정 (그대로 유지)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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