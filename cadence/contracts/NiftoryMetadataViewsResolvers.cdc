/*
NiftoryMetadataViewsResolvers

Below are implementations of resolvers that will be common amongst Niftory
NFTs. However, NFTs do not have to be limited to these by any means. 
Please see details about the actual Metadata themselves from the
MetadataViews contract

Each resolver is accompanied by a function to create that resolver
(because constructors of resources are not accessible outside of the
contract defining the resource)
*/

import MetadataViews from "./MetadataViews.cdc"

import MetadataViewsManager from "./MetadataViewsManager.cdc"

import NiftoryNonFungibleToken from "./NiftoryNonFungibleToken.cdc"

pub contract NiftoryMetadataViewsResolvers {

  // ========================================================================
  // Royalties
  // ========================================================================

  pub struct RoyaltiesResolver: MetadataViewsManager.Resolver {

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

  // ========================================================================
  // NFTCollectionData
  // ========================================================================

  pub struct NFTCollectionDataResolver: MetadataViewsManager.Resolver {

    pub let type: Type
    
    // All Niftory NFTs should have an NFTPublic interface, which points to
    // its contracts NFTCollectionData info
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let nft = nftRef as! &{NiftoryNonFungibleToken.NFTPublic}
      return nft.contract().getNFTCollectionData()
    }

    init() {
      self.type = Type<MetadataViews.NFTCollectionData>()
    }
  } 

  // ========================================================================
  // Display
  // ========================================================================

  pub struct IpfsDisplayResolver: MetadataViewsManager.Resolver {

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
      let nft = nftRef as! &{NiftoryNonFungibleToken.NFTPublic}
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
}
 