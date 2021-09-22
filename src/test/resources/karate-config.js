function fn() {
    //
    // Configure mutual auth TLS
    //
    karate.configure("ssl", {
        trustAll: true, // Don't try to validate the remote cert
        keyStore: `file:<TODO:fill-me-in>`,
        keyStorePassword: "<TODO:fill-me-in>",
        keyStoreType: "jks",
        trustStore: `file:<TODO:fill-me-in>`,
        trustStorePassword: "<TODO:fill-me-in>",
        trustStoreType: "jks"
    });

    karate.configure("headers", {
        // Note: this header is not used for authentication, as the identity of the verification container takes precedence
        X_SPINNAKER_USER: "<TODO:pick an email>"
    });

    //
    // Variables for use in test
    //
    const config = {
        gateEndpoint: "<TODO:integration test env gate endpoint>>"
    }

    return config
}
