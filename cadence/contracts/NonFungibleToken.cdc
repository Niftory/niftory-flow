pub contract interface NonFungibleToken {
  pub var totalSupply: UInt64
  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)
  pub resource interface INFT {
    pub let id: UInt64
  }
  pub resource NFT: INFT {
    pub let id: UInt64
  }
  pub resource interface Provider {
    pub fun withdraw(withdrawID: UInt64): @NFT {
      post {
        result.id == withdrawID: "The ID of the withdrawn token must be the same as the requested ID"
      }
    }
  }
  pub resource interface Receiver {
    pub fun deposit(token: @NFT)
  }
  pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NFT
  }
  pub resource Collection: Provider, Receiver, CollectionPublic {
    pub var ownedNFTs: @{UInt64: NFT}
    pub fun withdraw(withdrawID: UInt64): @NFT
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NFT {
      pre {
        self.ownedNFTs[id] != nil: "NFT does not exist in the collection!"
      }
    }
  }
  pub fun createEmptyCollection(): @Collection {
    post {
      result.getIDs().length == 0: "The created collection must be empty!"
    }
  }
}