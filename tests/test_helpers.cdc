import Test

/* --- Executors --- */

access(all)
fun _executeScript(_ path: String, _ args: [AnyStruct]): Test.ScriptResult {
    return Test.executeScript(Test.readFile(path), args)
}

access(all)
fun _executeTransaction(_ path: String, _ args: [AnyStruct], _ signer: Test.Account): Test.TransactionResult {
    let txn = Test.Transaction(
        code: Test.readFile(path),
        authorizers: [signer.address],
        signers: [signer],
        arguments: args
    )
    return Test.executeTransaction(txn)
}

/* --- Error Logging --- */

access(all)
fun getErrorMessage(_ res: {Test.Result}): String {
    if res.error != nil {
        return res.error?.message ?? "[ERROR] Unknown error occurred"
    }
    return ""
}