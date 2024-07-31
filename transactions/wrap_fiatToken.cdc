import FungibleToken from "FungibleToken"
import FiatToken from "FiatToken"
import WrappedFiatToken from "WrappedFiatToken"
import "MetadataViews"

/// Any account that owns FiatToken could use this transaction
/// to convert their FiatToken.Vault to a WrappedFiatToken.Vault

transaction(amount: UFix64) {

    prepare(signer: AuthAccount) {

        // Get a reference to the signer's stored FiatToken vault
        let vaultRef = signer.borrow<&{FungibleToken.Provider}>(from: FiatToken.VaultStoragePath)
			?? panic("Could not borrow reference to the owner's Vault!")

        // Convert the FiatToken to WrappedFiatToken
        let wrappedTokens <- WrappedFiatToken.wrapFiatToken(<-vaultRef.withdraw(amount: amount))
    
        if let wrappedVaultRef = signer.borrow<&{FungibleToken.Receiver}>(from: WrappedFiatToken.VaultStoragePath) {
            wrappedVaultRef.deposit(from: <-wrappedTokens)
        } else {
            // The signer has not set up a WrappedFiatToken Vault yet
            // so store it in their storage
            signer.save(
                <-wrappedTokens,
                to: WrappedFiatToken.VaultStoragePath
            )

            // Set up the correct capabilities
            signer.link<&WrappedFiatToken.Vault{FungibleToken.Receiver}>(
                WrappedFiatToken.ReceiverPublicPath,
                target: WrappedFiatToken.VaultStoragePath
            )
            signer.link<&WrappedFiatToken.Vault{FungibleToken.Balance, MetadataViews.Resolver}>(
                WrappedFiatToken.VaultPublicPath,
                target: WrappedFiatToken.VaultStoragePath
            )
        }
    }
}