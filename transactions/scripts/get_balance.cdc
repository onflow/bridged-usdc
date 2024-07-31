// This script reads the balance field
// of an account's WrappedFiatToken Balance

import FungibleToken from "FungibleToken"
import WrappedFiatToken from "WrappedFiatToken"

pub fun main(address: Address): UFix64 {
    let account = getAccount(address)
    let vaultRef = account.getCapability(WrappedFiatToken.VaultPublicPath)
        .borrow<&WrappedFiatToken.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance reference to the Vault")

    return vaultRef.balance
}
