transaction() {
    prepare(a: AuthAccount) {}
    execute {
        log("hello")
        // panic("hello")
    }
}