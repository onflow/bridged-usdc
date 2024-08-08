// This script mints token on USDCFlow contract and deposits
// the minted amount to the receiver's Vault

import "FungibleToken"
import "USDCFlow"
import "FlowEVMBridgeHandlerInterfaces"

transaction(recipient: Address, amount: UFix64) {

    /// Reference to the Example Token Minter Resource object
    let tokenMinter: auth(FlowEVMBridgeHandlerInterfaces.Mint) &USDCFlow.Minter

    /// Reference to the Fungible Token Receiver of the recipient
    let tokenReceiver: &{FungibleToken.Receiver}

    prepare(signer: auth(BorrowValue) &Account) {

        // Borrow a reference to the admin object
        self.tokenMinter = signer.storage.borrow<auth(FlowEVMBridgeHandlerInterfaces.Mint) &USDCFlow.Minter>(from: /storage/usdcFlowMinter)
            ?? panic("Signer is not the minter")
    
        self.tokenReceiver = getAccount(recipient).capabilities.borrow<&USDCFlow.Vault>(USDCFlow.ReceiverPublicPath)
            ?? panic("Could not borrow receiver reference to the Vault")
    }

    execute {

        // Create mint tokens
        let mintedVault <- self.tokenMinter.mint(amount: amount)

        // Deposit them to the receiever
        self.tokenReceiver.deposit(from: <-mintedVault)
    }
}