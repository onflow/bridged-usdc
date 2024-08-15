import FungibleToken from "FungibleToken"
import FiatToken from "FiatToken"
import USDCFlow from "USDCFlow"
import "MetadataViews"

/// Any account that owns FiatToken could use this transaction
/// to convert their FiatToken.Vault to a USDCFlow.Vault

transaction(amount: UFix64) {

    prepare(signer: AuthAccount) {

        // Get a reference to the signer's stored FiatToken vault
        let vaultRef = signer.borrow<&{FungibleToken.Provider}>(from: FiatToken.VaultStoragePath)
			?? panic("Could not borrow reference to the owner's Vault!")

        // Convert the FiatToken to USDCFlow
        let wrappedTokens <- USDCFlow.wrapFiatToken(<-vaultRef.withdraw(amount: amount))
    
        if let wrappedVaultRef = signer.borrow<&{FungibleToken.Receiver}>(from: USDCFlow.VaultStoragePath) {
            wrappedVaultRef.deposit(from: <-wrappedTokens)
        } else {
            // The signer has not set up a USDCFlow Vault yet
            // so store it in their storage
            signer.save(
                <-USDCFlow.createEmptyVault(),
                to: USDCFlow.VaultStoragePath
            )

            // Set up the correct capabilities
            signer.link<&USDCFlow.Vault{FungibleToken.Receiver}>(
                USDCFlow.ReceiverPublicPath,
                target: USDCFlow.VaultStoragePath
            )
            signer.link<&USDCFlow.Vault{FungibleToken.Balance, MetadataViews.Resolver}>(
                USDCFlow.VaultPublicPath,
                target: USDCFlow.VaultStoragePath
            )

            let wrappedVaultRef = signer.borrow<&{FungibleToken.Receiver}>(from: USDCFlow.VaultStoragePath)
                ?? panic("Could not borrow a receiver reference to the USDCFlow.Vault!")

            wrappedVaultRef.deposit(from: <-wrappedTokens)
        }
    }
}