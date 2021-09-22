package ballast

import com.intuit.karate.junit5.Karate

/**
 * This runner just deletes the ballast delivery config.
 *
 * A precondition of the ballast tests is that the "ballast" app is unmanaged (has no delivery config).
 * Executing this runner will ensure the precondition is satisfied.
 *
 * This class can come in handy during development if your tests bomb out and don't clean up properly.
 */
class CleanupRunner {
    @Karate.Test
    fun cleanup(): Karate {
        return Karate
                .run("classpath:helpers/after.feature")
    }
}