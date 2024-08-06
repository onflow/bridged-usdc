import "FungibleToken"
import "MetadataViews"
import "FungibleTokenMetadataViews"
import "FiatToken"

pub contract USDCFlow: FungibleToken {

    /// Total supply of USDCFlows in existence
    pub var totalSupply: UFix64

    /// Storage and Public Paths
    pub let VaultStoragePath: StoragePath
    pub let VaultPublicPath: PublicPath
    pub let ReceiverPublicPath: PublicPath

    /// The event that is emitted when the contract is created
    pub event TokensInitialized(initialSupply: UFix64)

    /// The event that is emitted when tokens are withdrawn from a Vault
    pub event TokensWithdrawn(amount: UFix64, from: Address?)

    /// The event that is emitted when tokens are deposited to a Vault
    pub event TokensDeposited(amount: UFix64, to: Address?)

    /// The event that is emitted when new tokens are minted
    pub event TokensMinted(amount: UFix64, depositedUUID: UInt64, mintedUUID: UInt64)

    pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance, MetadataViews.Resolver {

        /// The total balance of this vault
        pub var balance: UFix64

        /// Initialize the balance at resource creation time
        init(balance: UFix64) {
            self.balance = balance
        }

        /// withdraw
        /// @param amount: The amount of tokens to be withdrawn from the vault
        /// @return The Vault resource containing the withdrawn funds
        ///
        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <-create Vault(balance: amount)
        }

        /// deposit
        /// @param from: The Vault resource containing the funds that will be deposited
        ///
        pub fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as! @USDCFlow.Vault
            self.balance = self.balance + vault.balance
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            vault.balance = 0.0
            destroy vault
        }

        destroy() {
            if self.balance > 0.0 {
                USDCFlow.totalSupply = USDCFlow.totalSupply - self.balance
            }
        }

        /// Gets an array of all the Metadata Views implemented by USDCFlow
        ///
        /// @return An array of Types defining the implemented views. This value will be used by
        ///         developers to know which parameter to pass to the resolveView() method.
        ///
        pub fun getViews(): [Type] {
            return [
                Type<FungibleTokenMetadataViews.FTView>(),
                Type<FungibleTokenMetadataViews.FTDisplay>(),
                Type<FungibleTokenMetadataViews.FTVaultData>(),
                Type<FungibleTokenMetadataViews.TotalSupply>()
            ]
        }

        /// Resolves Metadata Views out of the USDCFlow
        ///
        /// @param view: The Type of the desired view.
        /// @return A structure representing the requested view.
        ///
        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<FungibleTokenMetadataViews.FTView>():
                    return FungibleTokenMetadataViews.FTView(
                        ftDisplay: self.resolveView(Type<FungibleTokenMetadataViews.FTDisplay>()) as! FungibleTokenMetadataViews.FTDisplay?,
                        ftVaultData: self.resolveView(Type<FungibleTokenMetadataViews.FTVaultData>()) as! FungibleTokenMetadataViews.FTVaultData?
                    )
                case Type<FungibleTokenMetadataViews.FTDisplay>():
                    let media = MetadataViews.Media(
                            file: MetadataViews.HTTPFile(
                            url: "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg"
                        ),
                        mediaType: "image/svg+xml"
                    )
                    let medias = MetadataViews.Medias([media])
                    return FungibleTokenMetadataViews.FTDisplay(
                        name: "USDC (Flow)",
                        symbol: "USDCf",
                        description: "This fungible token representation of USDC is bridged from Flow EVM.",
                        externalURL: MetadataViews.ExternalURL("https://www.circle.com/en/usdc"),
                        logos: medias,
                        socials: {
                            "x": MetadataViews.ExternalURL("https://x.com/circle")
                        }
                    )
                case Type<FungibleTokenMetadataViews.FTVaultData>():
                    return FungibleTokenMetadataViews.FTVaultData(
                        storagePath: USDCFlow.VaultStoragePath,
                        receiverPath: USDCFlow.ReceiverPublicPath,
                        metadataPath: USDCFlow.VaultPublicPath,
                        providerPath: /private/usdcFlowVault,
                        receiverLinkedType: Type<&USDCFlow.Vault{FungibleToken.Receiver}>(),
                        metadataLinkedType: Type<&USDCFlow.Vault{FungibleToken.Balance, MetadataViews.Resolver}>(),
                        providerLinkedType: Type<&USDCFlow.Vault{FungibleToken.Provider}>(),
                        createEmptyVaultFunction: (fun (): @USDCFlow.Vault {
                            return <-USDCFlow.createEmptyVault()
                        })
                    )
                case Type<FungibleTokenMetadataViews.TotalSupply>():
                    return FungibleTokenMetadataViews.TotalSupply(totalSupply: USDCFlow.totalSupply)
            }
            return nil
        }
    }

    /// createEmptyVault
    ///
    /// @return The new Vault resource with a balance of zero
    ///
    pub fun createEmptyVault(): @Vault {
        return <-create Vault(balance: 0.0)
    }

    /// wrapFiatToken
    ///
    /// Provides a way for users to exchange a FiatToken Vault
    /// for a USDCFlow Vault with the same balance
    pub fun wrapFiatToken(_ from: @FungibleToken.Vault): @Vault {
        post {
            result.balance == before(from.balance):
                "The USDCFlow Vault that was returned does not have the same balance as the Vault that was deposited!"
        }

        let vault <- from as! @FiatToken.Vault

        // Get a reference to the contract account's stored Vault
        let fiatTokenVaultRef = self.account.borrow<&FiatToken.Vault>(from: FiatToken.VaultStoragePath)
            ?? panic("Could not borrow reference to the owner's FiatToken Vault!")

        let wrappedFiatTokenVault <- create Vault(balance: vault.balance)

        emit TokensMinted(amount: wrappedFiatTokenVault.balance, depositedUUID: vault.uuid, mintedUUID: wrappedFiatTokenVault.uuid)

        fiatTokenVaultRef.deposit(from: <-vault)

        self.totalSupply = self.totalSupply + wrappedFiatTokenVault.balance

        return <-wrappedFiatTokenVault
    }

    init() {
        self.totalSupply = 0.0
        self.VaultStoragePath = /storage/usdcFlowVault
        self.VaultPublicPath = /public/usdcFlowMetadata
        self.ReceiverPublicPath = /public/usdcFlowReceiver

        // Create the Vault with the total supply of tokens and save it in storage.
        let vault <- create Vault(balance: self.totalSupply)
        self.account.save(<-vault, to: self.VaultStoragePath)

        // Create a public capability to the stored Vault that exposes
        // the `deposit` method through the `Receiver` interface.
        self.account.link<&{FungibleToken.Receiver}>(
            self.ReceiverPublicPath,
            target: self.VaultStoragePath
        )

        // Create a public capability to the stored Vault that only exposes
        // the `balance` field and the `resolveView` method through the `Balance` interface
        self.account.link<&USDCFlow.Vault{FungibleToken.Balance}>(
            self.VaultPublicPath,
            target: self.VaultStoragePath
        )
    }
}
