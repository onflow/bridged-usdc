// This transaction is a template for a transaction to allow
// anyone to add a Vault resource to their account so that
// they can use the USDCFlow

import FungibleToken from "FungibleToken"
import USDCFlow from "USDCFlow"
import MetadataViews from "MetadataViews"

transaction () {

    prepare(signer: AuthAccount) {

        // Return early if the account already stores a USDCFlow Vault
        if signer.borrow<&USDCFlow.Vault>(from: USDCFlow.VaultStoragePath) != nil {
            return
        }

        // Create a new USDCFlow Vault and put it in storage
        signer.save(
            <-USDCFlow.createEmptyVault(),
            to: USDCFlow.VaultStoragePath
        )

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        signer.link<&USDCFlow.Vault{FungibleToken.Receiver}>(
            USDCFlow.ReceiverPublicPath,
            target: USDCFlow.VaultStoragePath
        )

        // Create a public capability to the Vault that exposes the Balance and Resolver interfaces
        signer.link<&USDCFlow.Vault{FungibleToken.Balance, MetadataViews.Resolver}>(
            USDCFlow.VaultPublicPath,
            target: USDCFlow.VaultStoragePath
        )
    }
}
