/*
Niftory
niftory.com

Niftory is a platform to design, manage, and launch NFT experiments and
experiences. This contract defines what those NFTs look like.

In order to provide NFT brand admins maximum customizability, Niftory NFTs
offer the following features
- Mutatable metadata for NFTs via Niftory's MutableMetadata suite of contracts. 
  Admins can continue to modify NFTs even after they are minted, or they can
  decide to lock the metadata for a particular NFT or set of NFTs to provide
  immutability guarantees
- Conformance to NFT metadata standards with customizable resolvers. The Flow 
  team and community have provided standards for NFTs to implement so third
  party applications can access metadata for any NFT, regardless of how it was
  implemented. Niftory NFTs use MetadataViewsmMnager so admins can customize
  how NFTs are viewed by these applications, up until they decide to lock it.
- Common interfaces for minting and information. This enables separately managed
  code to refer to Niftory NFTs agnostically from the actual Niftory NFT
  implementation (e.g. No need to import an NFT contract directly, you just
  need to know what path and which address the minting/info/etc. capabilities 
  are located)
- Common interface for collections, which allows bulk withdrawal/deposits
*/

import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

import MutableMetadata from "./MutableMetadata.cdc"
import MutableSet from "./MutableSet.cdc"
import MutableSetManager from "./MutableSetManager.cdc"

import MetadataViewsManager from "./MetadataViewsManager.cdc"

pub contract Niftory {

  // ========================================================================
  // NFTPublic
  // ========================================================================

  // All Niftory NFTs should implement NFTPublic.
  pub resource interface NFTPublic {

    // Unique ID of the NFT
    pub let id: UInt64

    // Serial number of the NFT. If multiple NFTs are meant to represent the
    // exact same 'entity' or set of metadata, then serial number should be used
    // to distinguish them. This will likely always be 1 for PFPs.
    pub let serial: UInt64

    // A 'pointer' to this NFTs metadata. Metadata is stored as part of
    // MutableMetadataManager. Please see that contract for more details.
    pub let metadataAccessor: MutableSetManager.MetadataAccessor

    // This NFTs metadata as a MutableMetadata object.
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}

    // All Niftory NFTs belong to exactly one set. This function should return
    // that set
    pub fun set(): &MutableSet.Set{MutableSet.SetPublic}

    // From MetadataViews
    pub fun getViews(): [Type]

    // From MetadataViews
    pub fun resolveView(_ view: Type): AnyStruct?

    // For convenience and transparency, return the MutableSetManager this NFT
    // is gettting its metadata from
    pub fun SetManagerPublic():
        Capability<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>

    // For convenience and transparency, return some metadata about the NFT
    // project itself. See MetadataViews.NFTCollectionData for details
    pub fun NFTCollectionData(): MetadataViews.NFTCollectionData
  }

  // ========================================================================
  // Manager capabilities
  // ========================================================================

  // A Niftory NFT Manager is responsible for providing interfaces into the NFT
  // contract itself. The two basic functions are to either provide information
  // about the contract or do minting (if authorized)

  // Public functiontionality for Manager
  pub resource interface ManagerPublic {

    // For convenience and transparency, return the MutableSetManager this
    // contract's NFTs are gettting their metadata from
    pub fun SetManagerPublic():
      Capability<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>

    // For convenience and transparency, return some metadata about this
    // project itself. See MetadataViews.NFTCollectionData for details
    pub fun NFTCollectionData(): MetadataViews.NFTCollectionData
    
    // For convenience and transparency, return the MetadataViewsManager this
    // contract's NFTs are gettting their metadata from
    pub fun MetadataViewsManagerPublic():
      Capability<
        &MetadataViewsManager.Manager{MetadataViewsManager.ManagerPublic}
      >
  }

  // Private functiontionality for Manager
  pub resource interface ManagerPrivate {
    pub fun SetManagerPublic():
      Capability<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>
    pub fun NFTCollectionData(): MetadataViews.NFTCollectionData
    pub fun MetadataViewsManagerPublic():
      Capability<
        &MetadataViewsManager.Manager{MetadataViewsManager.ManagerPublic}
      >

    // Mint an NFT with the given MutableSetManager.MetadataAccessor token. 
    // This token lets the NFT know which metadata template is being referred
    // to. If desired, the "template" (MutableMetadataTemplate) provides an
    // easy way to limit the amount of a particular NFT that can be minted.
    // Multiple NFTs minted from the same Template can also use that Template
    // determine the serial number of a given NFT.
    pub fun mint(
      metadataAccessor: MutableSetManager.MetadataAccessor,
    ): @NonFungibleToken.NFT
    
    // Same as mint from above, but an optimized version to do bulk mints.
    pub fun mintBulk(
      metadataAccessor: MutableSetManager.MetadataAccessor,
      numToMint: UInt64,
    ): @[NonFungibleToken.NFT]
  }

  // ========================================================================
  // Collection capabilities
  // ========================================================================

  // Public functiontionality for Collection
  pub resource interface CollectionPublic {

    // Inherited from NonFungibleToken.Collection
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun getIDs(): [UInt64]

    // Inherited from MetadataViews.Resolver
    pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver}

    // An optimized version of deposit for doing bulk NFT deposits into
    // a collection
    pub fun depositBulk(tokens: @[NonFungibleToken.NFT])

    // Similar to borrowNFT, but with additional functionality from NFTPublic
    pub fun borrow(id: UInt64): &{NFTPublic}
  }

  // Private functiontionality for Collection
  pub resource interface CollectionPrivate {
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun depositBulk(tokens: @[NonFungibleToken.NFT])
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver}
    pub fun borrow(id: UInt64): &{NFTPublic}

    // Inherited from NonFungibleToken.Collection
    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT

    // An optimized version of withdraw for doing bulk NFT withdrawals from
    // a collection
    pub fun withdrawBulk(withdrawIDs: [UInt64]): @[NonFungibleToken.NFT]
  }

  // ========================================================================
  // Niftory MetadataViewsManager Resolvers
  // ========================================================================

  // Below are implementations of resolvers that will be common amongst Niftory
  // NFTs. However, NFTs do not have to be limited to these by any means. 
  // Please see details about the actual Metadata themselves from the
  // MetadataViews contract
  //
  // Each resolver is accompanied by a function to create that resolver
  // (because constructors of resources are not accessible outside of the
  // contract defining the resource)

  // ========================================================================
  // Royalties
  // ========================================================================

  pub resource RoyaltiesResolver: MetadataViewsManager.Resolver {

    pub let type: Type
    pub let royalties: MetadataViews.Royalties

    // Royalties are stored directly as a value in this resource
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      return self.royalties
    }
    init(royalties: MetadataViews.Royalties) {
      self.type = Type<MetadataViews.Royalties>()
      self.royalties = royalties
    }
  } 

  pub fun createRoyaltiesResolver(
    royalties: MetadataViews.Royalties
  ): @RoyaltiesResolver {
      return <-create RoyaltiesResolver(royalties: royalties)
  }

  // ========================================================================
  // NFTCollectionData
  // ========================================================================

  pub resource NFTCollectionDataResolver: MetadataViewsManager.Resolver {

    pub let type: Type
    
    // All Niftory NFTs should have an NFTPublic interface, which points to
    // its contracts NFTCollectionData info
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let nft = nftRef as! &{NFTPublic}
      return nft.NFTCollectionData()
    }

    init() {
      self.type = Type<MetadataViews.NFTCollectionData>()
    }
  } 

  pub fun createNFTCollectionDataResolver(): @NFTCollectionDataResolver {
      return <-create NFTCollectionDataResolver()
  }

  // ========================================================================
  // Display
  // ========================================================================

  pub resource IpfsDisplayResolver: MetadataViewsManager.Resolver {

    pub let type: Type

    // Field key values assumed to be in the NFT metadata
    pub let titleField: String
    pub let descriptionField: String
    pub let ipfsImageField: String

    // Default values for Display if above key values are not found
    pub let defaultTitle: String
    pub let defaultDescription: String
    pub let defaultIpfsImage: String

    // Niftory NFTs are assumed to have metadata implemented as a
    // {String: String} map. In order to create a Display, we need to know
    // the Display's title, description, and URI pointing to the Display media
    // image. In this case, the resolver will try to fill those fields in
    // based on the provided field keys, or use a default value if that key
    // does not exist in the NFT metadata.
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let nft = nftRef as! &{NFTPublic}
      let metadata = nft.metadata().get() as! &{String: String}
      let name = metadata[self.titleField] ?? self.defaultTitle
      let description = metadata[self.descriptionField]
        ?? self.defaultDescription
      let url = metadata[self.ipfsImageField] ?? self.defaultIpfsImage
      return MetadataViews.Display(
        name: name,
        description: description,
        thumbnail: MetadataViews.HTTPFile(url: url)
      )
    }

    init(
      titleField: String,
      descriptionField: String,
      ipfsImageField: String,
      defaultTitle: String,
      defaultDescription: String,
      defaultIpfsImage: String,
    ) {
      self.type = Type<MetadataViews.Display>()
      self.titleField = titleField
      self.descriptionField = descriptionField
      self.ipfsImageField = ipfsImageField
      self.defaultTitle = defaultTitle
      self.defaultDescription = defaultDescription
      self.defaultIpfsImage = defaultIpfsImage
    }
  }

  pub fun createIpfsDisplayResolver(
    titleField: String,
    descriptionField: String,
    ipfsImageField: String,
    defaultTitle: String,
    defaultDescription: String,
    defaultIpfsImage: String,
  ): @IpfsDisplayResolver {
      return <-create IpfsDisplayResolver(
        titleField: titleField,
        descriptionField: descriptionField,
        ipfsImageField: ipfsImageField,
        defaultTitle: defaultTitle,
        defaultDescription: defaultDescription,
        defaultIpfsImage: defaultIpfsImage,
      )
  }
}