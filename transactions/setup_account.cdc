// This transaction is a template for a transaction to allow
// anyone to add a Vault resource to their account so that
// they can use the WrappedFiatToken

import FungibleToken from "FungibleToken"
import WrappedFiatToken from "WrappedFiatToken"
import MetadataViews from "MetadataViews"

transaction () {

    prepare(signer: AuthAccount) {

        // Return early if the account already stores a WrappedFiatToken Vault
        if signer.borrow<&WrappedFiatToken.Vault>(from: WrappedFiatToken.VaultStoragePath) != nil {
            return
        }

        // Create a new WrappedFiatToken Vault and put it in storage
        signer.save(
            <-WrappedFiatToken.createEmptyVault(),
            to: WrappedFiatToken.VaultStoragePath
        )

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        signer.link<&WrappedFiatToken.Vault{FungibleToken.Receiver}>(
            WrappedFiatToken.ReceiverPublicPath,
            target: WrappedFiatToken.VaultStoragePath
        )

        // Create a public capability to the Vault that exposes the Balance and Resolver interfaces
        signer.link<&WrappedFiatToken.Vault{FungibleToken.Balance, MetadataViews.Resolver}>(
            WrappedFiatToken.VaultPublicPath,
            target: WrappedFiatToken.VaultStoragePath
        )
    }
}
