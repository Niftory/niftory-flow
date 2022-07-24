import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

import MutableMetadata from "./MutableMetadata.cdc"
import MutableSet from "./MutableSet.cdc"
import MutableSetManager from "./MutableSetManager.cdc"
pub contract interface Niftory {

  pub var totalSupply: UInt64

  pub let CollectionPrivatePath: PrivatePath
  pub let CollectionPublicPath: PublicPath
  pub let CollectionPath: StoragePath

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  pub fun SetManagerPublic():
    Capability<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>

  pub resource interface NFTPublic {
    pub let id: UInt64
    pub let serial: UInt64
    pub let metadataAccessor: MutableSetManager.MetadataAccessor
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun set(): &MutableSet.Set{MutableSet.SetPublic}
    pub fun getViews(): [Type]
    pub fun resolveView(_ view: Type): AnyStruct?
  }

  pub resource NFT: NFTPublic {
    pub let id: UInt64
    pub let serial: UInt64
    pub let metadataAccessor: MutableSetManager.MetadataAccessor
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun set(): &MutableSet.Set{MutableSet.SetPublic}
    pub fun getViews(): [Type]
    pub fun resolveView(_ view: Type): AnyStruct?
  }

  pub resource interface MinterPrivate {
    pub fun mint(
      metadataAccessor: MutableSetManager.MetadataAccessor,
    ): @NonFungibleToken.NFT
  }

  pub resource Minter: MinterPrivate {
    pub fun mint(
      metadataAccessor: MutableSetManager.MetadataAccessor,
    ): @NonFungibleToken.NFT
  }

  pub resource interface CollectionPublic {
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun depositBulk(tokens: @[NonFungibleToken.NFT])
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver}
    pub fun borrow(id: UInt64): &{NFTPublic}
  }

  pub resource interface CollectionPrivate {
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun depositBulk(tokens: @[NonFungibleToken.NFT])
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver}
    pub fun borrow(id: UInt64): &{NFTPublic}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT
    pub fun withdrawBulk(withdrawIDs: [UInt64]): @[NonFungibleToken.NFT]
  }

  pub resource Collection: CollectionPublic, CollectionPrivate {
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun depositBulk(tokens: @[NonFungibleToken.NFT])
    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT
    pub fun withdrawBulk(withdrawIDs: [UInt64]): @[NonFungibleToken.NFT]
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver}
    pub fun borrow(id: UInt64): &{Niftory.NFTPublic}
  }

  pub fun createEmptyCollection(): @NonFungibleToken.Collection
}