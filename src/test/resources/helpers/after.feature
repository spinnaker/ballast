Feature: delete the config after scenario has completed

  Background:
    * url gateEndpoint

  Scenario: delete config
  # delete the config
    Given path "/managed/delivery-configs/ballast-manifest"
    When method DELETE
    Then assert responseStatus == 200 || responseStatus == 404

  # Verify resource managed has gone down to zero
    Given path "/managed/application/ballast"
    And param includeDetails = "true"
    When method GET
    Then status 200
    And match $.resources == "#[0]"

  Scenario: destroy clusters
    Given path "/tasks"
    And header Content-Type = "application/context+json"
    And header Accept = "application/json"
    And request read("classpath:ballast/payloads/shrink-clusters.json")
    When method POST
    Then status 200

    Given path response.ref
    And header Accept = "application/json"
    And configure retry = { count: 60, interval: 5000 }
    And retry until responseStatus == 200 && response.status == "SUCCEEDED"
    When method GET
