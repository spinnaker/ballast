function manifestResourceCount(manifest) {
    const mp = x => x.resources.length;
    const rd = (a, v) => a + v;
    return manifest
        .environments
        .map(mp)
        .reduce(rd);
}
