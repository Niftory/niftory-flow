/*
NiftoryTemplate

This is the contract for NiftoryTemplate NFTs! 

This was implemented using Niftory interfaces. For full details on how this
contract functions, please see the Niftory and NFTRegistry contracts.
*/
import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

import MutableMetadata from "./MutableMetadata.cdc"
import MutableMetadataSet from "./MutableMetadataSet.cdc"
import MutableMetadataSetManager from "./MutableMetadataSetManager.cdc"
import MetadataViewsManager from "./MetadataViewsManager.cdc"

import NiftoryNonFungibleToken from "./NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "./NiftoryNFTRegistry.cdc"

pub contract NiftoryTemplate: NonFungibleToken {

  // ========================================================================
  // Constants 
  // ========================================================================

  // Suggested paths where collection could be stored
  pub let COLLECTION_PRIVATE_PATH: PrivatePath
  pub let COLLECTION_PUBLIC_PATH: PublicPath
  pub let COLLECTION_STORAGE_PATH: StoragePath

  // Accessor token to be used with NiftoryNFTRegistry to retrieve
  // meta-information about this NFT project
  pub let REGISTRY_ACCESSOR: NiftoryNFTRegistry.Accessor

  // ========================================================================
  // Attributes
  // ========================================================================

  // Arbitrary metadata for this NFT contract
  pub var metadata: AnyStruct?

  // Number of NFTs created
  pub var totalSupply: UInt64

  // ========================================================================
  // Contract Events
  // ========================================================================

  // This contract was initialized
  pub event ContractInitialized()

  // A withdrawal of NFT `id` has occurred from the `from` Address
  pub event Withdraw(id: UInt64, from: Address?)

  // A deposit of an NFT `id` has occurred to the `to` Address
  pub event Deposit(id: UInt64, to: Address?)

  // An NFT was minted

  // An NFT was burned

  // ========================================================================
  // NFT
  // ========================================================================

  pub resource NFT:
    NonFungibleToken.INFT,
    MetadataViews.Resolver,
    NiftoryNonFungibleToken.NFTPublic
  {
    pub let id: UInt64
    pub let metadataAccessor: MutableMetadataSetManager.Accessor
    pub let serial: UInt64

    pub fun contract(): &{NiftoryNonFungibleToken.ManagerPublic} {
      return NiftoryTemplate.contract()
    }

    pub fun set(): &MutableMetadataSet.Set{MutableMetadataSet.Public} {
      return self
        .contract()
        .getSetManagerPublic()
        .getSet(self.metadataAccessor.setId)
    }
  
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.Public} {
      return self
        .set()
        .getTemplate(self.metadataAccessor.templateId)
        .metadata()
    }

    pub fun getViews(): [Type] {
      return self
        .contract()
        .getMetadataViewsManagerPublic()
        .getViews()
    }

    pub fun resolveView(_ view: Type): AnyStruct? {
      let nftRef = &self as &{NiftoryNonFungibleToken.NFTPublic}
      return self
        .contract()
        .getMetadataViewsManagerPublic()
        .resolveView(view: view, nftRef: nftRef)
    }

    init(metadataAccessor: MutableMetadataSetManager.Accessor, serial: UInt64) {
      self.id = NiftoryTemplate.totalSupply
      NiftoryTemplate.totalSupply =
        NiftoryTemplate.totalSupply + 1
      self.metadataAccessor = metadataAccessor
      self.serial = serial
    }
  }

  // ========================================================================
  // Collection
  // ========================================================================

  pub resource Collection:
    NonFungibleToken.Provider,
    NonFungibleToken.Receiver,
    NonFungibleToken.CollectionPublic,
    MetadataViews.ResolverCollection,
    NiftoryNonFungibleToken.CollectionPublic,
    NiftoryNonFungibleToken.CollectionPrivate
  {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun contract(): &{NiftoryNonFungibleToken.ManagerPublic} {
      return NiftoryTemplate.contract()
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      pre {
        self.ownedNFTs[id] != nil : "NFT "
          .concat(id.toString())
          .concat(" does not exist in collection.")
      }
      return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
    }
  
    pub fun borrowViewResolver(
      id: UInt64
    ): &AnyResource{MetadataViews.Resolver} {
      pre {
        self.ownedNFTs[id] != nil : "NFT does not exist in collection."
      }
      let nftRef = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
      let fullNft = nftRef as! &NFT
      return fullNft as &AnyResource{MetadataViews.Resolver}
    }

    pub fun borrow(id: UInt64): &NFT{NiftoryNonFungibleToken.NFTPublic} {
      pre {
        self.ownedNFTs[id] != nil : "NFT does not exist in collection."
      }
      let nftRef = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
      let fullNft = nftRef as! &NFT
      return fullNft as &NFT{NiftoryNonFungibleToken.NFTPublic}
    }
  
    pub fun deposit(token: @NonFungibleToken.NFT) {
      let token <- token as! @NiftoryTemplate.NFT
      let id: UInt64 = token.id
      let oldToken <- self.ownedNFTs[id] <- token
      emit Deposit(id: id, to: self.owner?.address)
      destroy oldToken
    }

    pub fun depositBulk(tokens: @[NonFungibleToken.NFT]) {
      while tokens.length > 0 {
        let token <- tokens.removeLast() as! @NiftoryTemplate.NFT
        self.deposit(token: <-token)
      }
      destroy tokens
    }

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      pre {
        self.ownedNFTs[withdrawID] != nil
          : "NFT "
            .concat(withdrawID.toString())
            .concat(" does not exist in collection.")
      }
      let token <-self.ownedNFTs.remove(key: withdrawID)!
      emit Withdraw(id: token.id, from: self.owner?.address)
      return <-token
    }

    pub fun withdrawBulk(withdrawIDs: [UInt64]): @[NonFungibleToken.NFT] {
      let tokens: @[NonFungibleToken.NFT] <- []
      while withdrawIDs.length > 0 {
        tokens.append(<- self.withdraw(withdrawID: withdrawIDs.removeLast()))
      }
      return <-tokens
    }
    init() {
      self.ownedNFTs <- {}
    }
    
    destroy() {
      destroy self.ownedNFTs
    }
  }

  pub fun createEmptyCollection(): @Collection {
    return <-create Collection()
  }

  // ========================================================================
  // Manager
  // ========================================================================

  pub resource Manager:
    NiftoryNonFungibleToken.ManagerPublic,
    NiftoryNonFungibleToken.ManagerPrivate 
    {

    pub fun metadata(): AnyStruct? {
      return NiftoryTemplate.metadata
    }

    pub fun getSetManagerPublic():
      &MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public}
    {
      return NiftoryNFTRegistry
        .getSetManagerPublic(NiftoryTemplate.REGISTRY_ACCESSOR)
    }

    pub fun getMetadataViewsManagerPublic():
      &MetadataViewsManager.Manager{MetadataViewsManager.Public}
    {
      return NiftoryNFTRegistry
        .getMetadataViewsManagerPublic(NiftoryTemplate.REGISTRY_ACCESSOR)
    }

    pub fun getNFTCollectionData(): MetadataViews.NFTCollectionData {
      return NiftoryNFTRegistry
        .buildNFTCollectionData(
          NiftoryTemplate.REGISTRY_ACCESSOR,
          NiftoryTemplate.createEmptyCollection
        )
    }

    pub fun setMetadata(_ metadata: AnyStruct?) {
      NiftoryTemplate.metadata = metadata
    }
    
    pub fun mint(
      metadataAccessor: MutableMetadataSetManager.Accessor,
    ): @NonFungibleToken.NFT {
      let record = 
        NiftoryNFTRegistry.getRegistryRecord(NiftoryTemplate.REGISTRY_ACCESSOR)
      let setManager = 
        NiftoryTemplate.account
          .getCapability<&{MutableMetadataSetManager.Private}>(
            record.setManager.paths.private
          ).borrow()!
      let template = setManager
        .getSetMutable(metadataAccessor.setId)
        .getTemplateMutable(metadataAccessor.templateId)

      template.registerMint()
      let serial = template.minted()
      let nft <-create NFT(
        metadataAccessor: metadataAccessor,
        serial: serial
      )
      return <-nft
    }

    pub fun mintBulk(
      metadataAccessor: MutableMetadataSetManager.Accessor,
      numToMint: UInt64,
    ): @[NonFungibleToken.NFT] {
      let record = 
        NiftoryNFTRegistry.getRegistryRecord(NiftoryTemplate.REGISTRY_ACCESSOR)
      let setManagerMinter = 
        NiftoryTemplate.account
          .getCapability<&{MutableMetadataSetManager.Private}>(
            record.setManager.paths.private
          ).borrow()!
      let templateMinter = setManagerMinter
        .getSetMutable(metadataAccessor.setId)
        .getTemplateMutable(metadataAccessor.templateId)

      let nfts: @[NonFungibleToken.NFT] <- []
      var leftToMint = numToMint
      while leftToMint > 0 {
        templateMinter.registerMint()
        let serial = templateMinter.minted()
        let nft <-create NFT(metadataAccessor: metadataAccessor, serial: serial)
        nfts.append(<-nft)
        leftToMint = leftToMint - 1
      }
      return <-nfts
    }
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  pub fun contract(): &{NiftoryNonFungibleToken.ManagerPublic} {
    return NiftoryNFTRegistry
      .getNFTManagerPublic(NiftoryTemplate.REGISTRY_ACCESSOR)
      }

  // ========================================================================
  // Init
  // ========================================================================

  init() {

    let record = NiftoryNFTRegistry.generateRecord(
      account: NiftoryTemplate.account.address,
      project: "NiftoryTemplate"
    )

    self.REGISTRY_ACCESSOR = NiftoryNFTRegistry.Accessor(
      account: NiftoryTemplate.account.address,
      project: "NiftoryTemplate"
    )

    self.COLLECTION_PUBLIC_PATH = record.collectionPaths.public
    self.COLLECTION_PRIVATE_PATH = record.collectionPaths.private
    self.COLLECTION_STORAGE_PATH = record.collectionPaths.storage

    // No metadata to start with
    self.metadata = nil

    // Initialize the total supply to 0.
    self.totalSupply = 0

    // The Manager for this NFT
    //
    // NFT Manager storage
    self
      .account
      .save<@Manager>(
        <-create Manager(),
        to: record.nftManager.paths.storage
      )
    
    // NFT Manager public
    self
      .account
      .link<&{NiftoryNonFungibleToken.ManagerPublic}>(
        record.nftManager.paths.public,
        target: record.nftManager.paths.storage
      )
    
    // NFT Manager private
    self
      .account
      .link<&
        Manager{NiftoryNonFungibleToken.ManagerPublic,
        NiftoryNonFungibleToken.ManagerPrivate
      }>(
        record.nftManager.paths.private,
        target: record.nftManager.paths.storage
      )

    // Save a MutableSetManager to this contract's storage, as the source of
    // this NFT contract's metadata.
    //
    // MutableMetadataSetManager storage
    self
      .account
      .save<@MutableMetadataSetManager.Manager>(
        <-MutableMetadataSetManager.create(
          name: "NiftoryTemplate",
          description: "The set manager for NiftoryTemplate."
        ),
        to: record.setManager.paths.storage
      )

    // MutableMetadataSetManager public
    self
      .account
      .link<&MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public}>(
        record.setManager.paths.public,
        target: record.setManager.paths.storage
      )
    
    // MutableMetadataSetManager private
    self
      .account
      .link<&
        MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public,
        MutableMetadataSetManager.Private
      }>(
        record.setManager.paths.private,
        target: record.setManager.paths.storage
      )

    // Save a MetadataViewsManager to this contract's storage, which will
    // allow observers to inspect standardized metadata through any of its
    // configured MetadataViews resolvers.
    //
    // MetadataViewsManager storage
    self
      .account
      .save<@MetadataViewsManager.Manager>(
        <-MetadataViewsManager.create(),
        to: record.metadataViewsManager.paths.storage
      )

    // MetadataViewsManager public
    self
      .account
      .link<&MetadataViewsManager.Manager{MetadataViewsManager.Public}>(
        record.metadataViewsManager.paths.public,
        target: record.metadataViewsManager.paths.storage
      )

    // MetadataViewsManager private
    self
      .account
      .link<&
        MetadataViewsManager.Manager{MetadataViewsManager.Private, 
        MetadataViewsManager.Public
      }>(
        record.metadataViewsManager.paths.private,
        target: record.metadataViewsManager.paths.storage
      )
  }
}
 