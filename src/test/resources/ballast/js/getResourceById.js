function getResourceById(response, id) {
    const resources = response.resources;
    return resources
        .find(x => x.id === id);
}