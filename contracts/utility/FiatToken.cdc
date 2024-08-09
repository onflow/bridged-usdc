import "FungibleToken"

/// Basic FiatToken contract only used for testing USDCFlow

pub contract FiatToken: FungibleToken {

    /// -------- FiatToken Paths --------

    pub let VaultStoragePath: StoragePath
    pub let VaultBalancePubPath: PublicPath
    pub let VaultReceiverPubPath: PublicPath
    pub let VaultUUIDPubPath: PublicPath
    pub let MinterStoragePath: StoragePath

    pub var totalSupply: UFix64

    /// The event that is emitted when the contract is created
    pub event TokensInitialized(initialSupply: UFix64)

    /// The event that is emitted when tokens are withdrawn from a Vault
    pub event TokensWithdrawn(amount: UFix64, from: Address?)

    /// The event that is emitted when tokens are deposited into a Vault
    pub event TokensDeposited(amount: UFix64, to: Address?)

    /// ------- FiatToken Resources -------

    pub resource interface ResourceId {
        pub fun UUID(): UInt64
    }

    pub resource Vault: ResourceId, FungibleToken.Provider,
        FungibleToken.Receiver,
        FungibleToken.Balance {
        
        pub var balance: UFix64

        pub fun UUID(): UInt64 {
            return self.uuid
        }

        /// getSupportedVaultTypes optionally returns a list of vault types that this receiver accepts
        pub fun getSupportedVaultTypes(): {Type: Bool} {
            let supportedTypes: {Type: Bool} = {}
            supportedTypes[self.getType()] = true
            return supportedTypes
        }

        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            return <-create Vault(balance: amount)
        }

        pub fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as! @FiatToken.Vault
            self.balance = self.balance + vault.balance
            vault.balance = 0.0
            destroy vault
        }

        init(balance: UFix64) {
            self.balance = balance
        }

        destroy() {
            pre {
                self.balance == 0.0: "Cannot destroy USDC Vault with non-zero balance"
            }
        }
    }

    pub resource Minter {

        pub fun mint(amount: UFix64): @FiatToken.Vault {
            let newTotalSupply = FiatToken.totalSupply + amount
            FiatToken.totalSupply = newTotalSupply

            return <-create Vault(balance: amount)
        }
    }

    pub fun createEmptyVault(): @Vault {
        return <-create Vault(balance: 0.0)
    }

    init(
        VaultStoragePath: StoragePath,
        VaultBalancePubPath: PublicPath,
        VaultReceiverPubPath: PublicPath,
        VaultUUIDPubPath: PublicPath,
        MinterStoragePath: StoragePath,
        initTotalSupply: UFix64,
    ) {

        self.totalSupply = initTotalSupply

        self.VaultStoragePath = VaultStoragePath
        self.VaultBalancePubPath = VaultBalancePubPath
        self.VaultReceiverPubPath = VaultReceiverPubPath
        self.VaultUUIDPubPath = VaultUUIDPubPath

        self.MinterStoragePath = MinterStoragePath
 
        // Create a Vault with the initial totalSupply
        let vault <- create Vault(balance: self.totalSupply)
        self.account.save(<-vault, to: self.VaultStoragePath)
        self.account.link<&FiatToken.Vault{FungibleToken.Balance}>(self.VaultBalancePubPath, target: self.VaultStoragePath)
 
        let minter <- create Minter()
        self.account.save(<-minter, to: self.MinterStoragePath)
    }
}
