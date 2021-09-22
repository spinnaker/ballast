@parallel=false
Feature: Smoke test

  Background:
    * url gateEndpoint

    #
    # Variables
    #

    # manifests
    * def initial_manifest = "payloads/ballast-manifest.1.yml"
    * def transitional_manifest = "payloads/ballast-manifest.2.yml"
    * def final_manifest = "payloads/ballast-manifest.3.yml"

    # clusters
    * def envA = "ec2:cluster:test:ballast-envA"
    * def envB = "ec2:cluster:test:ballast-envB"

    #
    # custom karate functions
    #
    * def resource = read("js/getResourceById.js")
    * def sleep = function(s) { java.lang.Thread.sleep(s*1000) }
    * def manifestResourceCount = read("js/manifestResourceCount.js")

    #
    # Setup behavior
    #
    * callonce read("classpath:helpers/before.feature")

    #
    # Teardown behavior
    #
    * configure afterFeature = function(){ karate.call("classpath:helpers/after.feature"); }


  Scenario: submit initial delivery config and verify managed resource count matches the delivery config
    # Submit the config
    Given path "/managed/delivery-configs"
    And header Content-Type = "application/x-yaml"
    And header Accept = "application/json"
    And def submittedManifestYaml = karate.readAsString(initial_manifest)
    * print "payload"
    * print submittedManifestYaml
    And request submittedManifestYaml
    When method POST
    Then status 200
    And sleep(20)

    # verify the resource count matches the manifest
    Given path "/managed/application/ballast"
    And param includeDetails = "true"
    When method GET
    Then status 200
    # Parse the manifest yaml into karate's native JSON format
    And yaml submittedManifest = submittedManifestYaml
    And match $.resources == "#[manifestResourceCount(submittedManifest)]"

  Scenario: verify that two cluster resources are happy
    Given path "/managed/application/ballast"
    And param includeDetails = "true"
    # up-to 60 passes w/15s sleep == must become happy within 15min
    * configure retry = { count: 60, interval: 15000 }
    And retry until resource(response, envA).status=="HAPPY" && resource(response, envB).status=="HAPPY"
    When method GET
    Then status 200
    And def statuses = $..resources[?(@.kind=="ec2/cluster@v1.1")].status
    And match statuses == "#[2]"
    And match each statuses == "HAPPY"

  Scenario: Verify there are no environment constraints
    Given path "/managed/application/ballast"
    And param includeDetails = "true"
    When method GET
    Then status 200
    And match $.currentEnvironmentConstraints == "#[0]"

  Scenario: update the config by adding a depends-on constraint
    Given path "/managed/delivery-configs"
    And header Content-Type = "application/x-yaml"
    And header Accept = "application/json"
    And def submittedManifestYaml = karate.readAsString(transitional_manifest)
    And request submittedManifestYaml
    When method POST
    Then status 200
    And sleep(10)

  Scenario: update the config again: change artifact, add depends-on and manual judgment constraints
    Given path "/managed/delivery-configs"
    And header Content-Type = "application/x-yaml"
    And header Accept = "application/json"
    And def submittedManifestYaml = karate.readAsString(final_manifest)
    And request submittedManifestYaml
    When method POST
    Then status 200
    And sleep(20)

    # check that the count of resources being manged matches the delivery config
    Given path "/managed/application/ballast"
    And param includeDetails = "true"
    When method GET
    Then status 200
    And def submittedManifestYaml = karate.readAsString(initial_manifest)
    And yaml submittedManifestJson = submittedManifestYaml
    And match $.resources == "#[manifestResourceCount(submittedManifestJson)]"

  Scenario: Manual judgment constraint is in a pending state
    Given path "/managed/application/ballast"
    And param includeDetails = "true"
    * configure retry = { count: 30, interval: 30000 }
    And retry until resource(response, envA).status=="HAPPY" && response.currentEnvironmentConstraints.length>0
    When method GET
    Then status 200

    # At least one constraint, and it's in PENDING state
    And match $.currentEnvironmentConstraints == "#[_ > 0]"
    And match $.currentEnvironmentConstraints[0].status == "PENDING"

  Scenario: Approve manual judgment
    Given path "/managed/application/ballast"
    And param includeDetails = "true"
    When method GET
    Then status 200
    And def artifactVersion = $.currentEnvironmentConstraints[0].artifactVersion
    And def artifactReference = $.currentEnvironmentConstraints[0].artifactReference

    Given path "/managed/application/ballast/environment/envB/constraint"
    And request {"artifactVersion":"#(artifactVersion)", "artifactReference":"#(artifactReference)", "status":"PASS", "type":"manual-judgement"}

    When method POST
    Then sleep(10)

    Given path "/managed/application/ballast"
    And param includeDetails = "true"
    When method GET
    Then status 200
    And match $.currentEnvironmentConstraints[0].status == "PASS"

    # Wait for envB to be happy
    Given path "/managed/application/ballast"
    And param includeDetails = "true"
    * configure retry = { count: 60, interval: 15000 }
    And retry until resource(response, envB).status=="HAPPY"
    When method GET
    Then status 200
