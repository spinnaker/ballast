plugins {
    id("java")
    kotlin("jvm") version "1.3.72"
}

dependencies {
    val karateVersion = "1.1.0"
    testCompile("com.intuit.karate:karate-junit5:${karateVersion}")
    testCompile("com.intuit.karate:karate-core:${karateVersion}")
    testCompile("net.masterthought:cucumber-reporting:5.3.1")
    implementation(kotlin("stdlib-jdk8"))
}

repositories {
    mavenCentral()
}

tasks {
    test {
        useJUnitPlatform()
        systemProperty("karate.options", System.getProperty("karate.options"))
        systemProperty("karate.env", System.getProperty("karate.env"))
        outputs.upToDateWhen { false }
    }
}
