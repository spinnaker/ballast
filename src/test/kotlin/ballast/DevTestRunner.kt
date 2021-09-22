package ballast

import com.intuit.karate.junit5.Karate

/**
 * Test runner for local development
 *
 * Useful for running tests inside of IntelliJ.
 *
 */

class DevTestRunner {
    @Karate.Test
    fun ballast(): Karate {
        return Karate
                .run()
                .relativeTo(javaClass)
    }
}