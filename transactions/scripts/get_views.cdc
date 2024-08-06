// This script checks the supported views from USDCFlow
// are the expected ones. This is merely used in testing.

import "MetadataViews"
import "USDCFlow"
import "FungibleTokenMetadataViews"

pub fun main(address: Address): [Type] {
    let account = getAccount(address)

    let vaultRef = account.getCapability(USDCFlow.VaultPublicPath)
        .borrow<&USDCFlow.Vault{MetadataViews.Resolver}>()
        ?? panic("Could not borrow MetadataViews reference to the Vault")

    return vaultRef.getViews()
}
