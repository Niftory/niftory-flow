/*
NiftoryNonFungibleToken

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
import MutableMetadataSet from "./MutableMetadataSet.cdc"
import MutableMetadataSetManager from "./MutableMetadataSetManager.cdc"

import MetadataViewsManager from "./MetadataViewsManager.cdc"

pub contract NiftoryNonFungibleToken {

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
    pub let metadataAccessor: MutableMetadataSetManager.Accessor

    // Contract public information
    pub fun contract(): &{ManagerPublic}

    // All Niftory NFTs belong to exactly one set. This function should return
    // that set
    pub fun set(): &MutableMetadataSet.Set{MutableMetadataSet.Public}

    // This NFTs metadata as a MutableMetadata object.
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.Public}

    // From MetadataViews
    pub fun getViews(): [Type]

    // From MetadataViews
    pub fun resolveView(_ view: Type): AnyStruct?
  }

  // ========================================================================
  // Collection interfaces
  // ========================================================================

  // Public
  pub resource interface CollectionPublic {

    // Contract public information
    pub fun contract(): &{ManagerPublic}

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

  // Private
  pub resource interface CollectionPrivate {

    // Inherited from NonFungibleToken.Collection
    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT

    // An optimized version of withdraw for doing bulk NFT withdrawals from
    // a collection
    pub fun withdrawBulk(withdrawIDs: [UInt64]): @[NonFungibleToken.NFT]
  }

  // ========================================================================
  // Manager interfaces
  // ========================================================================

  // A Niftory NFT Manager is responsible for providing interfaces into the NFT
  // contract itself. The two basic functions are to either provide information
  // about the contract or do minting (if authorized)

  // Public
  pub resource interface ManagerPublic {

    // Get arbitrary metadata for this NFT contract, if implemented
    pub fun metadata(): AnyStruct?

    // For convenience and transparency, return the MutableSetManager this
    // contract's NFTs are gettting their metadata from
    pub fun getSetManagerPublic():
        &MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public}
    
    // For convenience and transparency, return the MetadataViewsManager this
    // contract's NFTs are gettting their metadata from
    pub fun getMetadataViewsManagerPublic():
        &MetadataViewsManager.Manager{MetadataViewsManager.Public}
    
    // In order to expose collection features in an NFT agnostic way
    // (i.e. without having to import the actual NFT contract explicitly)
    pub fun getNFTCollectionData(): MetadataViews.NFTCollectionData
  }

  // Private
  pub resource interface ManagerPrivate {

    // Set arbitrary metadata for this NFT contract, if implemented
    pub fun setMetadata(_ metadata: AnyStruct?)

    // Mint an NFT with the given MutableSetManager.MetadataAccessor token. 
    // This token lets the NFT know which metadata template is being referred
    // to. If desired, the "template" (MutableMetadataTemplate) provides an
    // easy way to limit the amount of a particular NFT that can be minted.
    // Multiple NFTs minted from the same Template can also use that Template
    // determine the serial number of a given NFT.
    pub fun mint(
      metadataAccessor: MutableMetadataSetManager.Accessor,
    ): @NonFungibleToken.NFT
    
    // Same as mint from above, but an optimized version to do bulk mints.
    pub fun mintBulk(
      metadataAccessor: MutableMetadataSetManager.Accessor,
      numToMint: UInt64,
    ): @[NonFungibleToken.NFT]
  }
}
 