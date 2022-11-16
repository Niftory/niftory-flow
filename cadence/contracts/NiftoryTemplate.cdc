/*
NiftoryTemplate

This is the contract for NiftoryTemplate NFTs!

This was implemented using Niftory interfaces. For full details on how this
contract functions, please see the Niftory and NFTRegistry contracts.

*/

import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

import MutableMetadata from "./MutableMetadata.cdc"
import MutableMetadataTemplate from "./MutableMetadataTemplate.cdc"
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

  // Suggested paths where nft manager could be stored
  pub let NFT_MANAGER_PRIVATE_PATH: PrivatePath
  pub let NFT_MANAGER_PUBLIC_PATH: PublicPath
  pub let NFT_MANAGER_STORAGE_PATH: StoragePath

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

  ///////////////////////////////////////////////////////////////////////////

  // Contract metadata was modified
  pub event ContractMetadataUpdated()

  // Metadata Views Manager was locked
  pub event MetadataViewsManagerLocked()

  // Metadata Views Resolver was added
  pub event MetadataViewsResolverAdded(type: Type)

  // Metadata Views Resolver was removed
  pub event MetadataViewsResolverRemoved(type: Type)

  // Set Manager Name or Description updated
  pub event SetManagerMetadataUpdated()

  // Set added to Set Manager
  pub event SetAddedToSetManager(setID: Int)

  ///////////////////////////////////////////////////////////////////////////

  // Set `setId` was locked (no new templates can be added)
  pub event SetLocked(setId: Int)

  // The metadata for Set `setId` was locked and cannot be modified
  pub event SetMetadataLocked(setId: Int)

  // Set `setId` was modified
  pub event SetMetadataModified(setId: Int)

  // A new Template `templateId` was added to Set `setId`
  pub event TemplateAddedToSet(setId: Int, templateId: Int)

  ///////////////////////////////////////////////////////////////////////////

  // Template `templateId` was locked in Set `setId`, which disables minting
  pub event TemplateLocked(setId: Int, templateId: Int)

  // Template `templateId` of Set `setId` had it's maxMint set to `maxMint`
  pub event TemplateMaxMintSet(setId: Int, templateId: Int, maxMint: UInt64)

  // Template `templateId` of Set `setId` has minted NFT with serial `serial`
  pub event NFTMinted(setId: Int, templateId: Int, serial: UInt64)

  // Template `templateId` of Set `setId` has minted multiple NFTs of serials
  // from 'fromSerial' to (and including) 'toSerial'
  pub event NFTMintedBulk(
    setId: Int,
    templateId: Int,
    fromSerial: UInt64,
    toSerial: UInt64
  )

  ///////////////////////////////////////////////////////////////////////////

  // The metadata for NFT/Template `templateId` of Set `setId` was locked
  pub event NFTMetadataLocked(setId: Int, templateId: Int)

  // The metadata for NFT/Template `templateId` of Set `setId` was modified
  pub event NFTMetadataModified(setId: Int, templateId: Int)

  ///////////////////////////////////////////////////////////////////////////

  // NFT `serial` from Template `templateId` of Set `setId` was burned
  pub event NFTBurned(setId: Int, templateId: Int, serial: UInt64)

  // ========================================================================
  // NFT
  // ========================================================================

  pub resource NFT:
    NonFungibleToken.INFT,
    MetadataViews.Resolver,
    NiftoryNonFungibleToken.NFTPublic
  {
    pub let id: UInt64
    pub let setId: Int
    pub let templateId: Int
    pub let serial: UInt64

    pub fun contract(): &{NiftoryNonFungibleToken.ManagerPublic} {
      return NiftoryTemplate.contract()
    }

    pub fun set(): &MutableMetadataSet.Set{MutableMetadataSet.Public} {
      return self
        .contract()
        .getSetManagerPublic()
        .getSet(self.setId)
    }

    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.Public} {
      return self
        .set()
        .getTemplate(self.templateId)
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

    init(setId: Int, templateId: Int, serial: UInt64) {
      self.id = NiftoryTemplate.totalSupply
      NiftoryTemplate.totalSupply =
        NiftoryTemplate.totalSupply + 1
      self.setId = setId
      self.templateId = templateId
      self.serial = serial
    }

    destroy() {
      emit NFTBurned(
        setId: self.setId,
        templateId: self.templateId,
        serial: self.serial
      )
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

    pub fun borrow(id: UInt64): &NFT{NiftoryNonFungibleToken.NFTPublic} {
      pre {
        self.ownedNFTs[id] != nil : "NFT does not exist in collection."
      }
      let nftRef = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
      let fullNft = nftRef as! &NFT
      return fullNft
    }

    pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
      pre {
        self.ownedNFTs[id] != nil : "NFT does not exist in collection."
      }
      let nftRef = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
      let fullNft = nftRef as! &NFT
      return fullNft
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
    // Capability for MutableMetadataSetManager
    access(self) var _setManagerCap: Capability<&
        MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public,
          MutableMetadataSetManager.Private
      }>

    // Capability for MetadataViewsManager
    access(self) var _metadataViewsManagerCap: Capability<&
        MetadataViewsManager.Manager{MetadataViewsManager.Public,
          MetadataViewsManager.Private
      }>

    // ========================================================================
    // Public
    // ========================================================================

    pub fun metadata(): AnyStruct? {
      return NiftoryTemplate.metadata
    }

    pub fun getSetManagerPublic():
      &MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public}
    {
      return self._setManagerCap.borrow()!
    }

    pub fun getMetadataViewsManagerPublic():
      &MetadataViewsManager.Manager{MetadataViewsManager.Public}
    {
      return self._metadataViewsManagerCap.borrow()!
    }

    pub fun getNFTCollectionData(): MetadataViews.NFTCollectionData {
      return MetadataViews.NFTCollectionData(
        storagePath: NiftoryTemplate.COLLECTION_STORAGE_PATH,
        publicPath: NiftoryTemplate.COLLECTION_PUBLIC_PATH,
        providerPath: NiftoryTemplate.COLLECTION_PRIVATE_PATH,
        publicCollection: Type<&{
          NonFungibleToken.CollectionPublic,
          NiftoryNonFungibleToken.CollectionPublic
        }>(),
        publicLinkedType: Type<&{
          NonFungibleToken.Receiver,
          NonFungibleToken.CollectionPublic,
          MetadataViews.ResolverCollection,
          NiftoryNonFungibleToken.CollectionPublic
        }>(),
        providerLinkedType: Type<&{
          NonFungibleToken.Provider,
          NonFungibleToken.Receiver,
          NonFungibleToken.CollectionPublic,
          MetadataViews.ResolverCollection,
          NiftoryNonFungibleToken.CollectionPublic
        }>(),
        createEmptyCollectionFunction:
          fun (): @NonFungibleToken.Collection {
            return <-NiftoryTemplate.createEmptyCollection()
          }
      )
    }

    // ========================================================================
    // Helper accessors
    // ========================================================================

    access(self) fun _getMetadataViewsManagerPrivate():
      &MetadataViewsManager.Manager{MetadataViewsManager.Private}
    {
      return self._metadataViewsManagerCap.borrow()!
    }

    access(self) fun _getSetManagerPrivate():
      &MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public,
        MutableMetadataSetManager.Private
      }
    {
      return self._setManagerCap.borrow()!
    }

    access(self) fun _getSetMutable(_ setId: Int):
      &MutableMetadataSet.Set{MutableMetadataSet.Private,
        MutableMetadataSet.Public
      }
    {
      return self._getSetManagerPrivate().getSetMutable(setId)
    }

    access(self) fun _getTemplateMutable(_ setId: Int, _ templateId: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.Public,
        MutableMetadataTemplate.Private
      }
    {
      return self._getSetMutable(setId).getTemplateMutable(templateId)
    }

    access(self) fun _getNFTMetadata(_ setId: Int, _ templateId: Int):
      &MutableMetadata.Metadata{MutableMetadata.Public,
        MutableMetadata.Private
      }
    {
      return self._getTemplateMutable(setId, templateId).metadataMutable()
    }

    // ========================================================================
    // Contract metadata
    // ========================================================================

    pub fun modifyContractMetadata(): auth &AnyStruct {
      emit ContractMetadataUpdated()
      return &NiftoryTemplate.metadata as auth &AnyStruct
    }

    pub fun replaceContractMetadata(_ metadata: AnyStruct?) {
      emit ContractMetadataUpdated()
      NiftoryTemplate.metadata = metadata
    }

    // ========================================================================
    // Metadata Views Manager
    // ========================================================================

    pub fun lockMetadataViewsManager() {
      self._getMetadataViewsManagerPrivate().lock()
      emit MetadataViewsManagerLocked()
    }

    pub fun setMetadataViewsResolver(
      _ resolver: AnyStruct{MetadataViewsManager.Resolver}
    ) {
      self._getMetadataViewsManagerPrivate().addResolver(resolver)
      emit MetadataViewsResolverAdded(type: resolver.type)
    }

    pub fun removeMetadataViewsResolver(_ type: Type) {
      self._getMetadataViewsManagerPrivate().removeResolver(type)
      emit MetadataViewsResolverRemoved(type: type)
    }

    // ========================================================================
    // Set Manager
    // ========================================================================

    pub fun setMetadataManagerName(_ name: String) {
      self._getSetManagerPrivate().setName(name)
      emit SetManagerMetadataUpdated()
    }

    pub fun setMetadataManagerDescription(_ description: String) {
      self._getSetManagerPrivate().setDescription(description)
      emit SetManagerMetadataUpdated()
    }

    pub fun addSet(_ set: @MutableMetadataSet.Set) {
      let setManager = self._getSetManagerPrivate()
      let setId = setManager.numSets()
      setManager.addSet(<-set)
      emit SetAddedToSetManager(setID: setId)
    }

    // ========================================================================
    // Set
    // ========================================================================

    pub fun lockSet(setId: Int) {
      self._getSetMutable(setId).lock()
      emit SetLocked(setId: setId)
    }

    pub fun lockSetMetadata(setId: Int) {
      self._getSetMutable(setId).metadataMutable().lock()
      emit SetMetadataLocked(setId: setId)
    }

    pub fun modifySetMetadata(setId: Int): auth &AnyStruct {
      emit SetMetadataModified(setId: setId)
      return self._getSetMutable(setId).metadataMutable().getMutable()
    }

    pub fun replaceSetMetadata(setId: Int, new: AnyStruct) {
      self._getSetMutable(setId).metadataMutable().replace(new)
      emit SetMetadataModified(setId: setId)
    }

    pub fun addTemplate(
      setId: Int,
      template: @MutableMetadataTemplate.Template
    ) {
      let set = self._getSetMutable(setId)
      let templateId = set.numTemplates()
      self._getSetMutable(setId).addTemplate(<-template)
      emit TemplateAddedToSet(setId: setId, templateId: templateId)
    }

    // ========================================================================
    // Minting
    // ========================================================================

    pub fun lockTemplate(setId: Int, templateId: Int) {
      emit TemplateLocked(setId: setId, templateId: templateId)
      self._getTemplateMutable(setId, templateId).lock()
    }

    pub fun setTemplateMaxMint(setId: Int, templateId: Int, max: UInt64) {
      emit TemplateMaxMintSet(
        setId: setId,
        templateId: templateId,
        maxMint: max
      )
      self._getTemplateMutable(setId, templateId).setMaxMint(max)
    }

    pub fun mint(setId: Int, templateId: Int): @NonFungibleToken.NFT {
      let template = self._getTemplateMutable(setId, templateId)
      template.registerMint()
      let serial = template.minted()
      let nft <-create NFT(
        setId: setId,
        templateId: templateId,
        serial: serial
      )
      emit NFTMinted(setId: setId, templateId: templateId, serial: serial)
      return <-nft
    }

    pub fun mintBulk(
      setId: Int,
      templateId: Int,
      numToMint: UInt64,
    ): @[NonFungibleToken.NFT] {
      pre {
        numToMint > 0: "Must mint at least one NFT"
      }
      let template = self._getTemplateMutable(setId, templateId)
      let nfts: @[NFT] <- []
      var leftToMint = numToMint
      while leftToMint > 0 {
        template.registerMint()
        let serial = template.minted()
        let nft <-create NFT(
          setId: setId,
          templateId: templateId,
          serial: serial
        )
        nfts.append(<-nft)
        leftToMint = leftToMint - 1
      }
      let fromSerial = (&nfts[0] as! &NFT).serial
      let toSerial = (&nfts[numToMint - 1] as! &NFT).serial
      emit NFTMintedBulk(
        setId: setId,
        templateId: templateId,
        fromSerial: fromSerial,
        toSerial: toSerial
      )
      return <-nfts
    }

    // ========================================================================
    // NFT metadata
    // ========================================================================

    pub fun lockNFTMetadata(setId: Int, templateId: Int) {
      self._getNFTMetadata(setId, templateId).lock()
      emit NFTMetadataLocked(setId: setId, templateId: templateId)
    }

    pub fun modifyNFTMetadata(setId: Int, templateId: Int): auth &AnyStruct {
      emit NFTMetadataModified(setId: setId, templateId: templateId)
      return self._getNFTMetadata(setId, templateId).getMutable()
    }

    pub fun replaceNFTMetadata(setId: Int, templateId: Int, new: AnyStruct) {
      self._getNFTMetadata(setId, templateId).replace(new)
      emit NFTMetadataModified(setId: setId, templateId: templateId)
    }

    // ========================================================================
    // init/destroy
    // ========================================================================

    init(
      setManagerCap: Capability<&
        MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public,
          MutableMetadataSetManager.Private
      }>,
      metadataViewsManagerCap: Capability<&
        MetadataViewsManager.Manager{MetadataViewsManager.Public,
          MetadataViewsManager.Private
      }>
    ) {
      self._setManagerCap = setManagerCap
      self._metadataViewsManagerCap = metadataViewsManagerCap
    }
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  pub fun contract(): &{NiftoryNonFungibleToken.ManagerPublic} {
      let manager = NiftoryTemplate
        .account
        .getCapability<&{NiftoryNonFungibleToken.ManagerPublic}>(
          NiftoryTemplate.NFT_MANAGER_PUBLIC_PATH
        )
      return manager.borrow()!
  }

  // ========================================================================
  // Init
  // ========================================================================

  init(
    record: NiftoryNFTRegistry.Record,
    setManagerCap: Capability<&
      MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public,
        MutableMetadataSetManager.Private
    }>,
    metadataViewsManagerCap: Capability<&
      MetadataViewsManager.Manager{MetadataViewsManager.Public,
        MetadataViewsManager.Private
    }>
  ) {

    // Collection paths iniitialization
    self.COLLECTION_PUBLIC_PATH = record.collectionPaths.public
    self.COLLECTION_PRIVATE_PATH = record.collectionPaths.private
    self.COLLECTION_STORAGE_PATH = record.collectionPaths.storage

    // NFT Manager paths initialization
    self.NFT_MANAGER_PUBLIC_PATH = record.nftManager.paths.public
    self.NFT_MANAGER_PRIVATE_PATH = record.nftManager.paths.private
    self.NFT_MANAGER_STORAGE_PATH = record.nftManager.paths.storage

    // No metadata to start with
    self.metadata = {} as {String: String}

    // Initialize the total supply to 0.
    self.totalSupply = 0

    // NFT Manager storage
    self
      .account
      .save<@Manager>(
        <-create Manager(
          setManagerCap: setManagerCap,
          metadataViewsManagerCap: metadataViewsManagerCap
        ),
        to: self.NFT_MANAGER_STORAGE_PATH
      )

    // NFT Manager public
    self
      .account
      .link<&{NiftoryNonFungibleToken.ManagerPublic}>(
        self.NFT_MANAGER_PUBLIC_PATH,
        target: self.NFT_MANAGER_STORAGE_PATH
      )

    // NFT Manager private
    self
      .account
      .link<&
        Manager{NiftoryNonFungibleToken.ManagerPublic,
        NiftoryNonFungibleToken.ManagerPrivate
      }>(
        self.NFT_MANAGER_PRIVATE_PATH,
        target: self.NFT_MANAGER_STORAGE_PATH
      )

    emit ContractInitialized()
  }
}
