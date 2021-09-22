#!/bin/bash -x

# Don't set -e here because we want to tar up the results
# regardless of whether the test succeeds or fails

./gradlew test --tests ballast.FancyReportTestRunner --info
RESULT=$?

exit $RESULT
