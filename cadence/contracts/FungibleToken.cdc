pub contract interface FungibleToken {
  pub var totalSupply: UFix64
  pub event TokensInitialized(initialSupply: UFix64)
  pub event TokensWithdrawn(amount: UFix64, from: Address?)
  pub event TokensDeposited(amount: UFix64, to: Address?)
  pub resource interface Provider {
    pub fun withdraw(amount: UFix64): @Vault {
      post {
        result.balance == amount:
          "Withdrawal amount must be the same as the balance of the withdrawn Vault"
      }
    }
  }
  pub resource interface Receiver {
    pub fun deposit(from: @Vault)
  }
  pub resource interface Balance {
    pub var balance: UFix64
    init(balance: UFix64) {
      post {
        self.balance == balance:
          "Balance must be initialized to the initial balance"
      }
    }
  }
  pub resource Vault: Provider, Receiver, Balance {
    pub var balance: UFix64
    init(balance: UFix64)
    pub fun withdraw(amount: UFix64): @Vault {
      pre {
        self.balance >= amount:
          "Amount withdrawn must be less than or equal than the balance of the Vault"
      }
      post {
        self.balance == before(self.balance) - amount:
          "New Vault balance must be the difference of the previous balance and the withdrawn Vault"
      }
    }
    pub fun deposit(from: @Vault) {
      pre {
        from.isInstance(self.getType()): 
          "Cannot deposit an incompatible token type"
      }
      post {
        self.balance == before(self.balance) + before(from.balance):
          "New Vault balance must be the sum of the previous balance and the deposited Vault"
      }
    }
  }
  pub fun createEmptyVault(): @Vault {
    post {
      result.balance == 0.0: "The newly created Vault must have zero balance"
    }
  }
}
 