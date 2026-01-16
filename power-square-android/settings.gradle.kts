pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        google()
        mavenCentral()
        gradlePluginPortal()
        maven { url = uri("https://jitpack.io") }
        maven { url = uri("https://storage.googleapis.com/r8-releases/raw") }
        maven { url = uri("https://developer.huawei.com/repo/") }
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        jcenter()
        maven { url = uri("https://jitpack.io") }
        maven { url = uri("https://storage.googleapis.com/r8-releases/raw") }
        maven { url = uri("https://developer.huawei.com/repo/") }
//        maven { url "http://maven.aliyun.com/repository/public" }
        maven { url= uri("https://maven.aliyun.com/repository/public")}
    }
}

rootProject.name = "ops"
include(":app")
include(":library")
include(":common")
