// This script reads the balance field
// of an account's USDCFlow Balance

import FungibleToken from "FungibleToken"
import USDCFlow from "USDCFlow"

access(all) fun main(address: Address): UFix64 {
    let account = getAccount(address)
    let vaultRef = account.capabilities.get<&USDCFlow.Vault>(USDCFlow.VaultPublicPath)
        .borrow()
        ?? panic("Could not borrow Balance reference to the Vault")

    return vaultRef.balance
}
