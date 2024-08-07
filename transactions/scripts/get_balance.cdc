// This script reads the balance field
// of an account's USDCFlow Balance

import FungibleToken from "FungibleToken"
import USDCFlow from "USDCFlow"

pub fun main(address: Address): UFix64 {
    let account = getAccount(address)
    let vaultRef = account.getCapability(USDCFlow.VaultPublicPath)
        .borrow<&USDCFlow.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance reference to the Vault")

    return vaultRef.balance
}
