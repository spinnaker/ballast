# Ballast

Ballast keeps Keel on-course and stable as it sails from staging to prod.

# Implementation details

## Karate-based tests

The tests are implemented using the [Karate](https://github.com/intuit/karate) framework. The tests live 
in [src/test/resources/ballast/smoke.feature](src/test/resources/ballast/smoke.feature).

Karate exposes arbitrary scripting functionality using JavaScript. You can find
the custom JavaScript functions in [src/test/resources/ballast/js](src/test/resources/ballast/js).


## Test runners

There are three test runners, all of them in [src/test/kotlin/ballast](src/test/kotlin/ballast).

* DevTestRunner - for local development (running inside of IntelliJ)
* FancyReportTestRunner - for running inside of Titus
* CleanupRunner - cleans up ballast app state (for local troubleshooting)

### DevTestRunner

[DevTestRunner](src/test/kotlin/ballast/DevTestRunner.kt) is a JUnit5-based test runner. IntelliJ will display the test results using its typical
testing view.

### FancyReportTestRunner

If you use
[FancyReportTestRunner](src/test/kotlin/ballast/FancyReportTestRunner.kt), then
Ballast will generate a report using [cucumber-reports](https://github.com/damianszczepanik/cucumber-reporting) in the
`target/cucumber-html-reports` directory.

This is the test runner that gets invoked inside of the Docker container.


### CleanupRunner

The tests assume that the "ballast" app is unmanaged to start, and after
each test run, the tests are supposed to delete the delivery config by
invoking [after.feature](src/test/resources/helpers/after.feature)

However, if somehow your tests don't delete the delivery config,
you can run [CleanupRunner](src/test/kotlin/ballast/CleanupRunner.kt) and it will delete the ballast delivery config.


# How to

## Set up endpoints and authentication

Edit [karate-config.js](src/test/resources/karate-config.js) and replace the placeholders for the endpoint and certificates with the ones that make sense for your environment.

## Run ballast tests from your laptop

1. Import the project into IntelliJ
1. Run the `src/test/kotlin/ballast/DevTestRunner` from IntelliJ


## Build and test

### Building a new `latest` image

Build and publish from your laptop:

```
docker build -t spinnaker/ballast:latest .
docker push spinnaker/ballast:latest
```

Note: it's your responsibility to ensure that you've committed your changes to the repo.

### Promoting `latest` image to `stable`

TBD.

## Current Coverage

Ballast currently tests a limited, core set of functions:

- Submitting a delivery-config and validating new resources under management
- Validating resource ec2-cluster actuation and convergence on a `HAPPY` state
- Changing the desired artifact and again validating ec2-cluster actuation and convergance on a `HAPPY` state
- Validating delivery-config and enviroment changes
- Validating environment ordering via the `depends-on` constraint
- Validating stateful constraints via the `manual-judgement` constraint
- Validating `manual-judgement` approval
- Validating post-approval promotion
- Deleting delivery-configs and validating no longer having resources under management

EC2 resources deployed during testing are in the `ballast` application.
