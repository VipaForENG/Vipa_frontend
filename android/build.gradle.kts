// 1. 코틀린 버전 명시를 위한 블록 추가
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // 이 부분이 있어야 Daemon 에러를 방지할 수 있습니다.
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
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