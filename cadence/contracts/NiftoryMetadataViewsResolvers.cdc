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
  // Constants
  // ========================================================================

  //
  pub fun DEFAULT_ALLOWED_URI_PREFIXES(): [String] {
    return [
      "https://",
      "http://",
      "ipfs://"
    ]
  }

  // ========================================================================
  // Royalties
  // ========================================================================

  pub struct RoyaltiesResolver: MetadataViewsManager.Resolver {

    // Royalties
    pub let type: Type

    // Stored straightforwardly
    pub let royalties: MetadataViews.Royalties

    // Royalties are stored directly as a value in this resource
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      return self.royalties
    }

    // Init
    init(royalties: MetadataViews.Royalties) {
      self.type = Type<MetadataViews.Royalties>()
      self.royalties = royalties
    }
  } 

  // ========================================================================
  // NFTCollectionData
  // ========================================================================

  pub struct NFTCollectionDataResolver: MetadataViewsManager.Resolver {

    // NFTCollectionData
    pub let type: Type
    
    // All Niftory NFTs should have an NFTPublic interface, which points to
    // its contracts NFTCollectionData info
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let nft = nftRef as! &{NiftoryNonFungibleToken.NFTPublic}
      return nft.contract().getNFTCollectionData()
    }

    // Init
    init() {
      self.type = Type<MetadataViews.NFTCollectionData>()
    }
  } 

  // ========================================================================
  // Display
  // ========================================================================

  pub struct DisplayResolver: MetadataViewsManager.Resolver {

    // Display
    pub let type: Type

    // Name 
    pub let nameField: String
    pub let defaultName: String

    // Description
    pub let descriptionField: String
    pub let defaultDescription: String

    // Image
    pub let imageField: String
    pub let defaultImagePrefix: String
    pub let defaultImage: String

    // Niftory NFTs are assumed to have metadata implemented as a
    // {String: String} map. In order to create a Display, we need to know
    // the Display's name, description, and URI pointing to the Display media
    // image. In this case, the resolver will try to fill those fields in
    // based on the provided field keys, or use a default value if that key
    // does not exist in the NFT metadata.
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let nft = nftRef as! &{NiftoryNonFungibleToken.NFTPublic}
      let metadata = nft.metadata().get() as! {String: String}

      let name = metadata[self.nameField] ?? self.defaultName
      let description = metadata[self.descriptionField]
        ?? self.defaultDescription
      let url = NiftoryMetadataViewsResolvers._prefixUri(
        allowedPrefixes: 
          NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
        default: self.defaultImagePrefix,
        uri: metadata[self.imageField] ?? self.defaultImage
      )

      return MetadataViews.Display(
        name: name,
        description: description,
        thumbnail: MetadataViews.HTTPFile(url: url)
      )
    }

    // Init
    init(
      nameField: String,
      defaultName: String,
      descriptionField: String,
      defaultDescription: String,
      imageField: String,
      defaultImagePrefix: String,
      defaultImage: String,
    ) {
      self.type = Type<MetadataViews.Display>()
      self.nameField = nameField
      self.defaultName = defaultName
      self.descriptionField = descriptionField
      self.defaultDescription = defaultDescription
      self.imageField = imageField
      self.defaultImagePrefix = defaultImagePrefix
      self.defaultImage = defaultImage
    }
  }

  // ========================================================================
  // NFTCollectionDisplay
  // ========================================================================

  pub struct NFTCollectionDisplayResolver: MetadataViewsManager.Resolver {

    // NFTCollectionDisplay
    pub let type: Type

    // Name
    pub let nameField: String
    pub let defaultName: String

    // Description
    pub let descriptionField: String
    pub let defaultDescription: String

    // ExternalURL
    pub let externalUrlField: String
    pub let defaultExternalURLPrefix: String
    pub let defaultExternalURL: String

    // Square Image
    pub let squareImageField: String
    pub let defaultSquareImagePrefix: String
    pub let defaultSquareImage: String
    pub let squareImageMediaTypeField: String
    pub let defaultSquareImageMediaType: String

    // Banner Image
    pub let bannerImageField: String
    pub let defaultBannerImagePrefix: String
    pub let defaultBannerImage: String
    pub let bannerImageMediaTypeField: String
    pub let defaultBannerImageMediaType: String

    // Socials
    pub let socialsFields: [String]

    // Niftory NFTs are assumed to have metadata implemented as a
    // {String: String} map. In order to create a Display, we need to know
    // the Display's title, description, and URI pointing to the Display media
    // image. In this case, the resolver will try to fill those fields in
    // based on the provided field keys, or use a default value if that key
    // does not exist in the NFT metadata.
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let nft = nftRef as! &{NiftoryNonFungibleToken.NFTPublic}
      let metadata = nft.contract().metadata() as! {String: String}

      let name = metadata[self.nameField] ?? self.defaultName

      let description = metadata[self.descriptionField]
        ?? self.defaultDescription

      let externalURL = MetadataViews.ExternalURL(url:
        NiftoryMetadataViewsResolvers._prefixUri(
          allowedPrefixes: 
            NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
          default: self.defaultExternalURLPrefix,
          uri: metadata[self.externalUrlField] ?? self.defaultExternalURL
        )
      )

      let squareImageURL = NiftoryMetadataViewsResolvers._prefixUri(
        allowedPrefixes: 
          NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
        default: self.defaultSquareImagePrefix,
        uri: metadata[self.squareImageField] ?? self.defaultSquareImage
      )
      let squareImageMediaType = metadata[self.squareImageMediaTypeField]
        ?? self.defaultSquareImageMediaType
      let squareImage = MetadataViews.Media(
        file: MetadataViews.HTTPFile(
          url: squareImageURL
        ),
        mediaType: squareImageMediaType
      )

      let bannerImageURL = NiftoryMetadataViewsResolvers._prefixUri(
        allowedPrefixes: 
          NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
        default: self.defaultBannerImagePrefix,
        uri: metadata[self.bannerImageField] ?? self.defaultBannerImage
      )
      let bannerImageMediaType = metadata[self.bannerImageMediaTypeField]
        ?? self.defaultBannerImageMediaType
      let bannerImage = MetadataViews.Media(
        file: MetadataViews.HTTPFile(
          url: bannerImageURL
        ),
        mediaType: bannerImageMediaType
      )

      let socials = NiftoryMetadataViewsResolvers._parseUrls(
        metadata: metadata,
        socialsFields: self.socialsFields
      )

      return MetadataViews.NFTCollectionDisplay(
        name: name,
        description: description,
        externalURL: externalURL,
        squareImage: squareImage,
        bannerImage: bannerImage,
        socials: socials
      )
    }

    // Init
    init(
      nameField: String,
      defaultName: String,
      descriptionField: String,
      defaultDescription: String,
      externalUrlField: String,
      defaultExternalURLPrefix: String,
      defaultExternalURL: String,
      squareImageField: String,
      defaultSquareImagePrefix: String,
      defaultSquareImage: String,
      squareImageMediaTypeField: String,
      defaultSquareImageMediaType: String,
      bannerImageField: String,
      defaultBannerImagePrefix: String,
      defaultBannerImage: String,
      bannerImageMediaTypeField: String,
      defaultBannerImageMediaType: String,
      socialsFields: [String],
    ) {
      self.type = Type<MetadataViews.NFTCollectionDisplay>()
      self.nameField = nameField
      self.defaultName = defaultName
      self.descriptionField = descriptionField
      self.defaultDescription = defaultDescription
      self.externalUrlField = externalUrlField
      self.defaultExternalURLPrefix = defaultExternalURLPrefix
      self.defaultExternalURL = defaultExternalURL
      self.squareImageField = squareImageField
      self.defaultSquareImagePrefix = defaultSquareImagePrefix
      self.defaultSquareImage = defaultSquareImage
      self.squareImageMediaTypeField = squareImageMediaTypeField
      self.defaultSquareImageMediaType = defaultSquareImageMediaType
      self.bannerImageField = bannerImageField
      self.defaultBannerImagePrefix = defaultBannerImagePrefix
      self.defaultBannerImage = defaultBannerImage
      self.bannerImageMediaTypeField = bannerImageMediaTypeField
      self.defaultBannerImageMediaType = defaultBannerImageMediaType
      self.socialsFields = socialsFields
    }
  }

  // ========================================================================
  // ExternalURL
  // ========================================================================

  pub struct ExternalURLResolver: MetadataViewsManager.Resolver {

    // ExternalURL
    pub let type: Type

    // URL
    pub let field: String
    pub let defaultPrefix: String
    pub let defaultURL: String

    /*
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let nft = nftRef as! &{NiftoryNonFungibleToken.NFTPublic}
      let metadata = nft.contract().metadata() as! {String: String}?
      var uri = self.defaultURL

      if metadata != nil {
        if metadata!.containsKey(self.field) {
          uri = metadata![self.field]!
        }
      }

      let url = NiftoryMetadataViewsResolvers._prefixUri(
        allowedPrefixes: 
          NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
        default: self.defaultPrefix,
        uri: uri
      )

      return MetadataViews.ExternalURL(url: url)
    }
    */
    //
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let nft = nftRef as! &{NiftoryNonFungibleToken.NFTPublic}
      var metadata: {String: String} = {}
      var dynamicMetadata = nft.contract().metadata() as! {String: String}?
      if dynamicMetadata != nil {
        metadata = dynamicMetadata!
      }

      let url = NiftoryMetadataViewsResolvers._prefixUri(
        allowedPrefixes: 
          NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
        default: self.defaultPrefix,
        uri: metadata[self.field] ?? self.defaultURL
      )

      return MetadataViews.ExternalURL(url: url)
    }

    // Init
    init(
      field: String,
      defaultPrefix: String,
      defaultURL: String,
    ) {
      self.type = Type<MetadataViews.ExternalURL>()
      self.field = field
      self.defaultPrefix = defaultPrefix
      self.defaultURL = defaultURL
    }
  }

  // ========================================================================
  // Traits
  // ========================================================================

  pub struct SimpleTraitAccessor {
    pub let traitField:  String
    pub let rarityField: String?
    init(traitField: String, rarityField: String?) {
      self.traitField = traitField
      self.rarityField = rarityField
    }
  }

  pub struct TraitsResolver: MetadataViewsManager.Resolver {

    // Traits
    pub let type: Type

    // URL
    pub let accessors: [SimpleTraitAccessor]

    //
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let nft = nftRef as! &{NiftoryNonFungibleToken.NFTPublic}
      let metadata = nft.metadata().get() as! {String: String}

      return NiftoryMetadataViewsResolvers._parseTraits(
        metadata: metadata,
        accessors: self.accessors
      )
    }

    // Init
    init(
      accessors: [SimpleTraitAccessor],
    ) {
      self.type = Type<MetadataViews.Traits>()
      self.accessors = accessors
    }
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  //
  access(self) fun _startsWith(string: String, substring: String): Bool {
    return substring.length <= string.length
      && string.slice(from: 0, upTo: substring.length) == substring
  }

  //
  access(self) fun _prefixUri(
    allowedPrefixes: [String],
    default: String,
    uri: String
  ): String {
    for allowedPrefix in allowedPrefixes {
      if self._startsWith(string: uri, substring: allowedPrefix) {
        return uri
      }
    }
    return default.concat(uri)
  }

  //
  access(self) fun _parseUrls(
    metadata: {String: String},
    socialsFields: [String],
  ): {String: MetadataViews.ExternalURL} {
    let socials: {String: MetadataViews.ExternalURL} = {}
    for field in socialsFields {
      if metadata.containsKey(field) {
        socials[field] = MetadataViews.ExternalURL(url: metadata[field]!)
      }
    }
    return socials
  }

  //
  access(self) fun _parseTraits(
    metadata: {String: String},
    accessors: [SimpleTraitAccessor],
  ): MetadataViews.Traits {
    let traits: [MetadataViews.Trait] = []
    for accessor in accessors {
      let traitField = accessor.traitField
      let rarityField = accessor.rarityField
      if metadata.containsKey(traitField) {
        let trait = metadata[traitField]!
        var rarity: MetadataViews.Rarity? = nil
        if rarityField != nil && metadata.containsKey(rarityField!) {
          rarity = MetadataViews.Rarity(
            score: nil,
            max: nil,
            description: metadata[rarityField!]!
          )
        }
        traits.append(MetadataViews.Trait(
          trait: trait,
          rarity: rarity,
          displayType: nil,
          rarity: rarity,
        ))
      }
    }
    return MetadataViews.Traits(traits: traits)
  }
}
 