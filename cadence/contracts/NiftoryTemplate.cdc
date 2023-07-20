/*
NiftoryTemplate

This is the contract for NiftoryTemplate NFTs!

This was implemented using Niftory interfaces. For full details on how this
contract functions, please see the Niftory and NFTRegistry contracts.

*/

import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"
import ViewResolver from "./ViewResolver.cdc"

import MutableMetadata from "./MutableMetadata.cdc"
import MutableMetadataTemplate from "./MutableMetadataTemplate.cdc"
import MutableMetadataSet from "./MutableMetadataSet.cdc"
import MutableMetadataSetManager from "./MutableMetadataSetManager.cdc"
import MetadataViewsManager from "./MetadataViewsManager.cdc"

import NiftoryNonFungibleToken from "./NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "./NiftoryNFTRegistry.cdc"

import NiftoryMetadataViewsResolvers from "./NiftoryMetadataViewsResolvers.cdc"
import NiftoryNonFungibleTokenProxy from "./NiftoryNonFungibleTokenProxy.cdc"

pub contract NiftoryTemplate: NonFungibleToken, ViewResolver {

  // ========================================================================
  // Constants
  // ========================================================================

  // Suggested paths where collection could be stored
  pub let COLLECTION_PRIVATE_PATH: PrivatePath
  pub let COLLECTION_PUBLIC_PATH: PublicPath
  pub let COLLECTION_STORAGE_PATH: StoragePath

  // Accessor token to be used with NiftoryNFTRegistry to retrieve
  // meta-information about this NFT project
  pub let REGISTRY_ADDRESS: Address
  pub let REGISTRY_BRAND: String

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
  pub event NFTMinted(id: UInt64, setId: Int, templateId: Int, serial: UInt64)

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
    // ========================================================================
    // Public
    // ========================================================================

    pub fun metadata(): AnyStruct? {
      return NiftoryTemplate.metadata
    }

    pub fun getSetManagerPublic():
      &MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public}
    {
      return NiftoryNFTRegistry
        .getSetManagerPublic(
          NiftoryTemplate.REGISTRY_ADDRESS,
          NiftoryTemplate.REGISTRY_BRAND
        )
    }

    pub fun getMetadataViewsManagerPublic():
      &MetadataViewsManager.Manager{MetadataViewsManager.Public}
    {
      return NiftoryNFTRegistry
        .getMetadataViewsManagerPublic(
          NiftoryTemplate.REGISTRY_ADDRESS,
          NiftoryTemplate.REGISTRY_BRAND
        )
    }

    pub fun getNFTCollectionData(): MetadataViews.NFTCollectionData {
      return NiftoryNFTRegistry
        .buildNFTCollectionData(
          NiftoryTemplate.REGISTRY_ADDRESS,
          NiftoryTemplate.REGISTRY_BRAND,
          (fun (): @NonFungibleToken.Collection {
            return <-NiftoryTemplate.createEmptyCollection()
          })
        )
    }

    // ========================================================================
    // Contract metadata
    // ========================================================================

    pub fun modifyContractMetadata(): auth &AnyStruct {
      emit ContractMetadataUpdated()
      let maybeMetadata = NiftoryTemplate.metadata
      if maybeMetadata == nil {
        let blankMetadata: {String: String} = {}
        NiftoryTemplate.metadata = blankMetadata
      }
      return (&NiftoryTemplate.metadata as auth &AnyStruct?)!
    }

    pub fun replaceContractMetadata(_ metadata: AnyStruct?) {
      emit ContractMetadataUpdated()
      NiftoryTemplate.metadata = metadata
    }

    // ========================================================================
    // Metadata Views Manager
    // ========================================================================

    access(self) fun _getMetadataViewsManagerPrivate():
      &MetadataViewsManager.Manager{MetadataViewsManager.Private}
    {
      let record =
        NiftoryNFTRegistry.getRegistryRecord(
          NiftoryTemplate.REGISTRY_ADDRESS,
          NiftoryTemplate.REGISTRY_BRAND
        )
      let manager =
        NiftoryTemplate.account
          .getCapability<&MetadataViewsManager.Manager{MetadataViewsManager.Private}>(
            record.metadataViewsManager.paths.private
          ).borrow()!
      return manager
    }

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

    access(self) fun _getSetManagerPrivate():
      &MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public, MutableMetadataSetManager.Private}
    {
      let record =
        NiftoryNFTRegistry.getRegistryRecord(
          NiftoryTemplate.REGISTRY_ADDRESS,
          NiftoryTemplate.REGISTRY_BRAND
        )
      let setManager =
        NiftoryTemplate.account
          .getCapability<&MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public, MutableMetadataSetManager.Private}>(
            record.setManager.paths.private
          ).borrow()!
      return setManager
    }

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

    access(self) fun _getSetMutable(_ setId: Int):
      &MutableMetadataSet.Set{MutableMetadataSet.Private,
        MutableMetadataSet.Public} {
      return self._getSetManagerPrivate().getSetMutable(setId)
    }

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
      set.addTemplate(<-template)
      emit TemplateAddedToSet(setId: setId, templateId: templateId)
    }

    // ========================================================================
    // Minting
    // ========================================================================

    access(self) fun _getTemplateMutable(_ setId: Int, _ templateId: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.Public,
        MutableMetadataTemplate.Private} {
      return self._getSetMutable(setId).getTemplateMutable(templateId)
    }

    pub fun lockTemplate(setId: Int, templateId: Int) {
      self._getTemplateMutable(setId, templateId).lock()
      emit TemplateLocked(setId: setId, templateId: templateId)
    }

    pub fun setTemplateMaxMint(setId: Int, templateId: Int, max: UInt64) {
      self._getTemplateMutable(setId, templateId).setMaxMint(max)
      emit TemplateMaxMintSet(
        setId: setId,
        templateId: templateId,
        maxMint: max
      )
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
      emit NFTMinted(
        id: nft.id,
        setId: setId,
        templateId: templateId,
        serial: serial
      )
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
      let nfts: @[NonFungibleToken.NFT] <- []
      var leftToMint = numToMint
      while leftToMint > 0 {
        template.registerMint()
        let serial = template.minted()
        let nft <-create NFT(
          setId: setId,
          templateId: templateId,
          serial: serial
        )
        emit NFTMinted(
          id: nft.id,
          setId: setId,
          templateId: templateId,
          serial: serial
        )
        nfts.append(<-nft)
        leftToMint = leftToMint - 1
      }
      return <-nfts
    }

    // ========================================================================
    // NFT metadata
    // ========================================================================

    access(self) fun _getNFTMetadata(_ setId: Int, _ templateId: Int):
      &MutableMetadata.Metadata{MutableMetadata.Public,
        MutableMetadata.Private
      } {
        return self._getTemplateMutable(setId, templateId).metadataMutable()
    }

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
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  pub fun contract(): &{NiftoryNonFungibleToken.ManagerPublic} {
    return NiftoryNFTRegistry
      .getNFTManagerPublic(
        NiftoryTemplate.REGISTRY_ADDRESS,
        NiftoryTemplate.REGISTRY_BRAND
      )
  }

  pub fun getViews(): [Type] {
    let possibleViews = [
      Type<MetadataViews.NFTCollectionDisplay>(),
      Type<MetadataViews.ExternalURL>()
    ]
    let views: [Type] = [Type<MetadataViews.NFTCollectionData>()]

    let viewManager = self.contract().getMetadataViewsManagerPublic()
    for view in possibleViews {
      if viewManager.inspectView(view: view) != nil {
        views.append(view)
      }
    }
    return views
  }

  pub fun resolveView(_ view: Type): AnyStruct? {
    let viewManager = self.contract().getMetadataViewsManagerPublic()
    switch view {

      case Type<MetadataViews.NFTCollectionData>():
        return self.contract().getNFTCollectionData()

      case Type<MetadataViews.NFTCollectionDisplay>():
        let maybeView = viewManager.inspectView(
          view: Type<MetadataViews.NFTCollectionDisplay>()
        )
        if maybeView == nil {
          return nil
        }
        let view = maybeView!

        if view.isInstance(
          Type<NiftoryMetadataViewsResolvers.NFTCollectionDisplayResolver>()
        ) {
          let resolver = view as! NiftoryMetadataViewsResolvers.NFTCollectionDisplayResolver

          // External URL
          let externalURL = MetadataViews.ExternalURL(url:
            NiftoryMetadataViewsResolvers._prefixUri(
              allowedPrefixes:
                NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
              default: resolver.defaultExternalURLPrefix,
              uri: resolver.defaultExternalURL
            )
          )

          // Square image
          let squareImageURL = NiftoryMetadataViewsResolvers._prefixUri(
            allowedPrefixes:
              NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
            default: resolver.defaultSquareImagePrefix,
            uri: resolver.defaultSquareImage
          )
          let squareImageMediaType = resolver.defaultSquareImageMediaType
          let squareImage = MetadataViews.Media(
            file: MetadataViews.HTTPFile(url: squareImageURL),
            mediaType: squareImageMediaType
          )

          // Banner image
          let bannerImageURL = NiftoryMetadataViewsResolvers._prefixUri(
            allowedPrefixes:
              NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
            default: resolver.defaultBannerImagePrefix,
            uri: resolver.defaultBannerImage
          )
          let bannerImageMediaType = resolver.defaultBannerImageMediaType
          let bannerImage = MetadataViews.Media(
            file: MetadataViews.HTTPFile(
              url: bannerImageURL
            ),
            mediaType: bannerImageMediaType
          )

          return MetadataViews.NFTCollectionDisplay(
            name: resolver.defaultName,
            description: resolver.defaultDescription,
            externalURL: externalURL,
            squareImage: squareImage,
            bannerImage: bannerImage,
            socials: {}

          )
        }

        if view.isInstance(
          Type<NiftoryMetadataViewsResolvers.NFTCollectionDisplayResolverWithIpfsGateway>()
        ) {
          let resolver = view as! NiftoryMetadataViewsResolvers.NFTCollectionDisplayResolverWithIpfsGateway

          // External URL
          let externalURL = MetadataViews.ExternalURL(url:
            NiftoryMetadataViewsResolvers._prefixUri(
              allowedPrefixes:
                NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
              default: resolver.defaultExternalURLPrefix,
              uri: resolver.defaultExternalURL
            )
          )

          // Square image
          let squareImageURL = NiftoryMetadataViewsResolvers._useIpfsGateway(
            ipfsGateway: resolver.ipfsGateway,
            uri: NiftoryMetadataViewsResolvers._prefixUri(
              allowedPrefixes:
                NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
              default: resolver.defaultSquareImagePrefix,
              uri: resolver.defaultSquareImage
            )
        )
          let squareImageMediaType = resolver.defaultSquareImageMediaType
          let squareImage = MetadataViews.Media(
            file: MetadataViews.HTTPFile(url: squareImageURL),
            mediaType: squareImageMediaType
          )

          // Banner image
          let bannerImageURL = NiftoryMetadataViewsResolvers._useIpfsGateway(
            ipfsGateway: resolver.ipfsGateway,
            uri: NiftoryMetadataViewsResolvers._prefixUri(
              allowedPrefixes:
                NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
              default: resolver.defaultBannerImagePrefix,
              uri: resolver.defaultBannerImage
            )
          )
          let bannerImageMediaType = resolver.defaultBannerImageMediaType
          let bannerImage = MetadataViews.Media(
            file: MetadataViews.HTTPFile(
              url: bannerImageURL
            ),
            mediaType: bannerImageMediaType
          )

          return MetadataViews.NFTCollectionDisplay(
            name: resolver.defaultName,
            description: resolver.defaultDescription,
            externalURL: externalURL,
            squareImage: squareImage,
            bannerImage: bannerImage,
            socials: {}
          )
        }

        return nil

      case Type<MetadataViews.ExternalURL>():
        let maybeView = viewManager.inspectView(
          view: Type<MetadataViews.ExternalURL>()
        )
        if maybeView == nil {
          return nil
        }
        let view = maybeView!

        if view.isInstance(
          Type<NiftoryMetadataViewsResolvers.ExternalURLResolver>()
        ) {
          let resolver = view as! NiftoryMetadataViewsResolvers.ExternalURLResolver
          return MetadataViews.ExternalURL(url:
            NiftoryMetadataViewsResolvers._prefixUri(
              allowedPrefixes:
                NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
              default: resolver.defaultPrefix,
              uri: resolver.defaultURL
            )
          )
        }

        return nil
      }
      return nil

  }

  // ========================================================================
  // Init
  // ========================================================================

  init(
    nftManagerProxy: &{
      NiftoryNonFungibleTokenProxy.Public,
      NiftoryNonFungibleTokenProxy.Private
    }
  ) {

    let record = NiftoryNFTRegistry.generateRecord(
      account: self.account.address,
      project: "0xCONTRACT_PATH_NAME"
    )

    self.REGISTRY_ADDRESS = 0x1234
    self.REGISTRY_BRAND = "0xCONTRACT_PATH_NAME"

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
    let nftManager <- create Manager()

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

    let contractName = "NiftoryTemplate"

    // Royalties
    let royaltiesResolver = NiftoryMetadataViewsResolvers.RoyaltiesResolver(
        royalties: MetadataViews.Royalties([])
    )
    nftManager.setMetadataViewsResolver(royaltiesResolver)

    // Collection Data
    let collectionDataResolver
        = NiftoryMetadataViewsResolvers.NFTCollectionDataResolver()
    nftManager.setMetadataViewsResolver(collectionDataResolver)

    // Display
    let displayResolver = NiftoryMetadataViewsResolvers.DisplayResolver(
        "title",
        contractName.concat("NFT"),
        "description",
        contractName.concat(" NFT"),
        "mediaUrl",
        "ipfs://",
        "ipfs://bafybeig6la3me5x3veull7jzxmwle4sfuaguou2is3o3z44ayhe7ihlqpa/NiftoryBanner.png"
    )
    nftManager.setMetadataViewsResolver(displayResolver)

    // Collection Display
    let collectionResolver = NiftoryMetadataViewsResolvers.NFTCollectionDisplayResolver(
        "title",
        contractName,
        "description",
        contractName.concat(" Collection"),
        "domainUrl",
        "https://",
        "https://niftory.com",
        "squareImage",
        "ipfs://",
        "ipfs://bafybeihc76uodw2at2xi2l5jydpvscj5ophfpqgblbrmsfpeffhcmgdtl4/squareImage.png",
        "squareImageMediaType",
        "image/png",
        "bannerImage",
        "ipfs://",
        "ipfs://bafybeig6la3me5x3veull7jzxmwle4sfuaguou2is3o3z44ayhe7ihlqpa/NiftoryBanner.png",
        "bannerImageMediaType",
        "image/png",
        []
    )
    nftManager.setMetadataViewsResolver(collectionResolver)

    // ExternalURL
    let externalURLResolver = NiftoryMetadataViewsResolvers.ExternalURLResolver(
        "domainUrl",
        "https://",
        "https://niftory.com"
    )
    nftManager.setMetadataViewsResolver(externalURLResolver)

    // Save NFT Manager
    self
      .account
      .save<@Manager>(
        <-nftManager,
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

      nftManagerProxy.add(
        registryAddress: self.REGISTRY_ADDRESS,
        brand: self.REGISTRY_BRAND,
        cap: self.account
              .getCapability<&{
                NiftoryNonFungibleToken.ManagerPrivate,
                NiftoryNonFungibleToken.ManagerPublic
              }>(
                record.nftManager.paths.private
              )
      )
  }
}