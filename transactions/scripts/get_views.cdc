// This script checks the supported views from USDCFlow
// are the expected ones. This is merely used in testing.

import "MetadataViews"
import "USDCFlow"
import "FungibleTokenMetadataViews"

access(all) fun main(address: Address): [Type] {
    let account = getAccount(address)

    let vaultRef = account.capabilities.get<&USDCFlow.Vault>(USDCFlow.VaultPublicPath)
        .borrow()
        ?? panic("Could not borrow MetadataViews reference to the Vault")

    return vaultRef.getViews()
}
