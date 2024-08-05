// This script checks the supported views from WrappedFiatToken
// are the expected ones. This is merely used in testing.

import "MetadataViews"
import "WrappedFiatToken"
import "FungibleTokenMetadataViews"

pub fun main(address: Address): [Type] {
    let account = getAccount(address)

    let vaultRef = account.getCapability(WrappedFiatToken.VaultPublicPath)
        .borrow<&WrappedFiatToken.Vault{MetadataViews.Resolver}>()
        ?? panic("Could not borrow MetadataViews reference to the Vault")

    return vaultRef.getViews()
}
