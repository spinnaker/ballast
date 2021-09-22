package ballast

import com.intuit.karate.Runner
import net.masterthought.cucumber.Configuration
import net.masterthought.cucumber.ReportBuilder
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.io.File

/**
 * Test runner that generates a nice looking report using cucumber-reports.
 *
 * This is the runner that gets invoked when running ballast on Titus.
 */
class FancyReportTestRunner {
    @Test
    fun testParallel() {
        val results = Runner.path("classpath:ballast")
            .outputCucumberJson(true)
            .parallel(1);
        generateReport(results.reportDir)

        // Assert all tests pass to ensure ballast returns an error on any test failure
        assertTrue(results.failCount == 0, results.errorMessages);
    }

    private fun generateReport(karateOutputPath: String) {
        val jsonPaths = FileUtils
                .listFiles(File(karateOutputPath), arrayOf("json"), true)
                .toList()
                .map { it.absolutePath }

        val config = Configuration(File("target"), "ballast")

        ReportBuilder(jsonPaths, config).generateReports()
    }


}