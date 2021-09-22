Feature: precondition checks that run once, before any test

  Background:
    * url gateEndpoint
    * print("***********************************************************")
    * print("Checking preconditions")
    * print("***********************************************************")

  Scenario: Verify ballast is unmanaged (i.e., no other ballast test is already running)
  # Verify that the ballast app isn't managing any resources
  # If it is, it means another ballast test is running
    Given path "/managed/application/ballast"
    And param includeDetails = "true"
    When method GET
    Then status 200
    And match $.resources == "#[0]"

# validateExistingManagedApp
  Scenario: Verify keeldemo is managed (sanity check that managed delivery is working)
    Given path "/managed/application/keeldemo"
    And param includeDetails = "true"
    When method GET
    Then status 200
    And match $.hasManagedResources == true

