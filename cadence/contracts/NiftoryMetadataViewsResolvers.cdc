/*
NiftoryMetadataViewsResolvers

Below are implementations of resolvers that will be common amongst Niftory NFTs.
However, NFTs do not have to be limited to these by any means. Please see
details about the actual Metadata themselves from the MetadataViews contract

In order to create a custom resolver, follow one of the examples below. The NFT
contract will pass an AnyStruct when calling resolveView. The custom resolver
will receive this AnyStruct and can cast it to whatever the NFT contract
provided the AnyStruct as.

*/

import MetadataViews from "./MetadataViews.cdc"

import MetadataViewsManager from "./MetadataViewsManager.cdc"

import NiftoryNonFungibleToken from "./NiftoryNonFungibleToken.cdc"

pub contract NiftoryMetadataViewsResolvers {

  // ========================================================================
  // Constants
  // ========================================================================

  // All URIs are expected to have one of these prefixes.
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

    // name
    pub let nameField: String
    pub let defaultName: String

    // description
    pub let descriptionField: String
    pub let defaultDescription: String

    // image
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
      let metadata = NiftoryMetadataViewsResolvers._extractMetadata(
        nftRef: nftRef
      )

      // name
      let name = metadata[self.nameField] ?? self.defaultName

      // description
      let description = metadata[self.descriptionField]
        ?? self.defaultDescription

      // image
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

  // IPFS URLs used for displays will be converted to URLs using IPFS gateways
  pub struct DisplayResolverWithIpfsGateway: MetadataViewsManager.Resolver {

    // Display
    pub let type: Type

    // name
    pub let nameFields: [String]
    pub let defaultName: String

    // description
    pub let descriptionFields: [String]
    pub let defaultDescription: String

    // image
    pub let imageFields: [String]
    pub let defaultImagePrefix: String
    pub let defaultImage: String

    // ipfs gateway
    pub let ipfsGateway: String

    // Niftory NFTs are assumed to have metadata implemented as a
    // {String: String} map. In order to create a Display, we need to know
    // the Display's name, description, and URI pointing to the Display media
    // image. In this case, the resolver will try to fill those fields in
    // based on the provided field keys, or use a default value if that key
    // does not exist in the NFT metadata.
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let metadata = NiftoryMetadataViewsResolvers._extractMetadata(
        nftRef: nftRef
      )

      // name
      let name = NiftoryMetadataViewsResolvers._firstValueOrElse(
        metadata: &metadata as &{String: String},
        fields: self.nameFields,
        default: self.defaultName
      )

      // description
      let description = NiftoryMetadataViewsResolvers._firstValueOrElse(
        metadata: &metadata as &{String: String},
        fields: self.descriptionFields,
        default: self.defaultDescription
      )

      // image
      let uri = NiftoryMetadataViewsResolvers._firstValueOrElse(
        metadata: &metadata as &{String: String},
        fields: self.imageFields,
        default: self.defaultImage
      )
      let url = NiftoryMetadataViewsResolvers._useIpfsGateway(
        ipfsGateway: self.ipfsGateway,
        uri: NiftoryMetadataViewsResolvers._prefixUri(
          allowedPrefixes:
            NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
          default: self.defaultImagePrefix,
          uri: uri
        )
      )

      return MetadataViews.Display(
        name: name,
        description: description,
        thumbnail: MetadataViews.HTTPFile(url: url)
      )
    }

    init(
      nameFields: [String],
      defaultName: String,
      descriptionFields: [String],
      defaultDescription: String,
      imageFields: [String],
      defaultImagePrefix: String,
      defaultImage: String,
      ipfsGateway: String
    ) {
      self.type = Type<MetadataViews.Display>()
      self.nameFields = nameFields
      self.defaultName = defaultName
      self.descriptionFields = descriptionFields
      self.defaultDescription = defaultDescription
      self.imageFields = imageFields
      self.defaultImagePrefix = defaultImagePrefix
      self.defaultImage = defaultImage
      self.ipfsGateway = ipfsGateway
    }
  }

  // ========================================================================
  // NFTCollectionDisplay
  // ========================================================================

  pub struct NFTCollectionDisplayResolver: MetadataViewsManager.Resolver {

    // NFTCollectionDisplay
    pub let type: Type

    // name
    pub let nameField: String
    pub let defaultName: String

    // description
    pub let descriptionField: String
    pub let defaultDescription: String

    // external URL
    pub let externalUrlField: String
    pub let defaultExternalURLPrefix: String
    pub let defaultExternalURL: String

    // square image
    pub let squareImageField: String
    pub let defaultSquareImagePrefix: String
    pub let defaultSquareImage: String
    pub let squareImageMediaTypeField: String
    pub let defaultSquareImageMediaType: String

    // banner image
    pub let bannerImageField: String
    pub let defaultBannerImagePrefix: String
    pub let defaultBannerImage: String
    pub let bannerImageMediaTypeField: String
    pub let defaultBannerImageMediaType: String

    // socials
    pub let socialsFields: [String]

    // Niftory NFTs are assumed to have metadata implemented as a
    // {String: String} map. In order to create a Display, we need to know
    // the Display's title, description, and URI pointing to the Display media
    // image. In this case, the resolver will try to fill those fields in
    // based on the provided field keys, or use a default value if that key
    // does not exist in the NFT metadata.
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let metadata = NiftoryMetadataViewsResolvers._extractMetadata(
        nftRef: nftRef
      )

      // name
      let name = metadata[self.nameField] ?? self.defaultName

      // description
      let description = metadata[self.descriptionField]
        ?? self.defaultDescription

      // external URL
      let externalURL = MetadataViews.ExternalURL(url:
        NiftoryMetadataViewsResolvers._prefixUri(
          allowedPrefixes:
            NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
          default: self.defaultExternalURLPrefix,
          uri: metadata[self.externalUrlField] ?? self.defaultExternalURL
        )
      )

      // square image
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

      // banner image
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

      // socials
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

  // IPFS URLs used for displays will be converted to URLs using IPFS gateways
  pub struct NFTCollectionDisplayResolverWithIpfsGateway:
    MetadataViewsManager.Resolver
  {

    // NFTCollectionDisplay
    pub let type: Type

    // name
    pub let nameFields: [String]
    pub let defaultName: String

    // description
    pub let descriptionFields: [String]
    pub let defaultDescription: String

    // external URL
    pub let externalUrlFields: [String]
    pub let defaultExternalURLPrefix: String
    pub let defaultExternalURL: String

    // square image
    pub let squareImageFields: [String]
    pub let defaultSquareImagePrefix: String
    pub let defaultSquareImage: String
    pub let squareImageMediaTypeField: String
    pub let defaultSquareImageMediaType: String

    // banner image
    pub let bannerImageFields: [String]
    pub let defaultBannerImagePrefix: String
    pub let defaultBannerImage: String
    pub let bannerImageMediaTypeField: String
    pub let defaultBannerImageMediaType: String

    // socials
    pub let socialsFields: [String]

    // ipfs gateway
    pub let ipfsGateway: String

    // Niftory NFTs are assumed to have metadata implemented as a
    // {String: String} map. In order to create a Display, we need to know
    // the Display's title, description, and URI pointing to the Display media
    // image. In this case, the resolver will try to fill those fields in
    // based on the provided field keys, or use a default value if that key
    // does not exist in the NFT metadata.
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let metadata = NiftoryMetadataViewsResolvers._extractMetadata(
        nftRef: nftRef
      )

      // name
      let name = NiftoryMetadataViewsResolvers._firstValueOrElse(
        metadata: &metadata as &{String: String},
        fields: self.nameFields,
        default: self.defaultName
      )

      // description
      let description = NiftoryMetadataViewsResolvers._firstValueOrElse(
        metadata: &metadata as &{String: String},
        fields: self.descriptionFields,
        default: self.defaultDescription
      )

      // external URL
      let externalUri = NiftoryMetadataViewsResolvers._firstValueOrElse(
        metadata: &metadata as &{String: String},
        fields: self.externalUrlFields,
        default: self.defaultExternalURL
      )
      let externalURL = MetadataViews.ExternalURL(url:
        NiftoryMetadataViewsResolvers._prefixUri(
          allowedPrefixes:
            NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
          default: self.defaultExternalURLPrefix,
          uri: externalUri
        )
      )

      // square image
      let squareImageUri = NiftoryMetadataViewsResolvers._firstValueOrElse(
        metadata: &metadata as &{String: String},
        fields: self.squareImageFields,
        default: self.defaultSquareImage
      )
      let squareImageURL = NiftoryMetadataViewsResolvers._useIpfsGateway(
        ipfsGateway: self.ipfsGateway,
        uri: NiftoryMetadataViewsResolvers._prefixUri(
          allowedPrefixes:
            NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
          default: self.defaultSquareImagePrefix,
          uri: squareImageUri
        )
      )
      let squareImageMediaType = metadata[self.squareImageMediaTypeField]
        ?? self.defaultSquareImageMediaType
      let squareImage = MetadataViews.Media(
        file: MetadataViews.HTTPFile(
          url: squareImageURL
        ),
        mediaType: squareImageMediaType
      )

      // banner image
      let bannerImageUri = NiftoryMetadataViewsResolvers._firstValueOrElse(
        metadata: &metadata as &{String: String},
        fields: self.bannerImageFields,
        default: self.defaultBannerImage
      )
      let bannerImageURL = NiftoryMetadataViewsResolvers._useIpfsGateway(
        ipfsGateway: self.ipfsGateway,
        uri: NiftoryMetadataViewsResolvers._prefixUri(
          allowedPrefixes:
            NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
          default: self.defaultBannerImagePrefix,
          uri: bannerImageUri
        )
      )
      let bannerImageMediaType = metadata[self.bannerImageMediaTypeField]
        ?? self.defaultBannerImageMediaType
      let bannerImage = MetadataViews.Media(
        file: MetadataViews.HTTPFile(
          url: bannerImageURL
        ),
        mediaType: bannerImageMediaType
      )

      // socials
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

    init(
      nameFields: [String],
      defaultName: String,
      descriptionFields: [String],
      defaultDescription: String,
      externalUrlFields: [String],
      defaultExternalURLPrefix: String,
      defaultExternalURL: String,
      squareImageFields: [String],
      defaultSquareImagePrefix: String,
      defaultSquareImage: String,
      squareImageMediaTypeField: String,
      defaultSquareImageMediaType: String,
      bannerImageFields: [String],
      defaultBannerImagePrefix: String,
      defaultBannerImage: String,
      bannerImageMediaTypeField: String,
      defaultBannerImageMediaType: String,
      socialsFields: [String],
      ipfsGateway: String
    ) {
      self.type = Type<MetadataViews.NFTCollectionDisplay>()
      self.nameFields = nameFields
      self.defaultName = defaultName
      self.descriptionFields = descriptionFields
      self.defaultDescription = defaultDescription
      self.externalUrlFields = externalUrlFields
      self.defaultExternalURLPrefix = defaultExternalURLPrefix
      self.defaultExternalURL = defaultExternalURL
      self.squareImageFields = squareImageFields
      self.defaultSquareImagePrefix = defaultSquareImagePrefix
      self.defaultSquareImage = defaultSquareImage
      self.squareImageMediaTypeField = squareImageMediaTypeField
      self.defaultSquareImageMediaType = defaultSquareImageMediaType
      self.bannerImageFields = bannerImageFields
      self.defaultBannerImagePrefix = defaultBannerImagePrefix
      self.defaultBannerImage = defaultBannerImage
      self.bannerImageMediaTypeField = bannerImageMediaTypeField
      self.defaultBannerImageMediaType = defaultBannerImageMediaType
      self.socialsFields = socialsFields
      self.ipfsGateway = ipfsGateway
    }
  }

  // ========================================================================
  // ExternalURL
  // ========================================================================

  pub struct ExternalURLResolver: MetadataViewsManager.Resolver {

    // ExternalURL
    pub let type: Type

    // url
    pub let field: String
    pub let defaultPrefix: String
    pub let defaultURL: String

    // Niftory NFTs are assumed to have metadata implemented as a
    // {String: String} map. In order to create an ExternalURL, we need to know
    // the Display's name, description, and URI pointing to the Display media
    // image. In this case, the resolver will try to fill those fields in
    // based on the provided field keys, or use a default value if that key
    // does not exist in the NFT metadata.
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let metadata = NiftoryMetadataViewsResolvers._extractMetadata(
        nftRef: nftRef
      )

      // url
      let url = NiftoryMetadataViewsResolvers._prefixUri(
        allowedPrefixes:
          NiftoryMetadataViewsResolvers.DEFAULT_ALLOWED_URI_PREFIXES(),
        default: self.defaultPrefix,
        uri: metadata[self.field] ?? self.defaultURL
      )

      return MetadataViews.ExternalURL(url: url)
    }

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

    // trait accessors
    pub let accessors: [SimpleTraitAccessor]

    // A very simple Traits implementation that assumes the NFT metadata is
    // implemented as a {String: String} map. Along with a trait key, it's
    // possible to provide a rarity key.
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let metadata = NiftoryMetadataViewsResolvers._extractMetadata(
        nftRef: nftRef
      )

      return NiftoryMetadataViewsResolvers._parseTraits(
        metadata: metadata,
        accessors: self.accessors
      )
    }

    init(
      accessors: [SimpleTraitAccessor],
    ) {
      self.type = Type<MetadataViews.Traits>()
      self.accessors = accessors
    }
  }

  // ========================================================================
  // Serial
  // ========================================================================

  pub struct SerialResolver: MetadataViewsManager.Resolver {

    // Serial
    pub let type: Type

    // Niftory NFTs are assumed to have metadata implemented as a
    // {String: String} map. In order to create a Serial, we need to know
    // the Display's name, description, and URI pointing to the Display media
    // image. In this case, the resolver will try to fill those fields in
    // based on the provided field keys, or use a default value if that key
    // does not exist in the NFT metadata.
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let nft = nftRef as! &{NiftoryNonFungibleToken.NFTPublic}

      // serial
      let serial = nft.serial

      return MetadataViews.Serial(serial: serial)
    }

    init() {
      self.type = Type<MetadataViews.Serial>()
    }
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  access(self) fun _extractMetadata(nftRef: AnyStruct): {String: String} {
    let nft = nftRef as! &{NiftoryNonFungibleToken.NFTPublic}
    var metadata: {String: String} = {}

    let contractMetadata = nft.contract().metadata() as! {String: String}?
    if contractMetadata != nil {
      metadata = contractMetadata!
    }

    let setMetadata = nft.set().metadata().get() as! {String: String}
    for key in setMetadata.keys {
      metadata[key] = setMetadata[key]!
    }

    let nftMetadata = nft.metadata().get() as! {String: String}
    for key in nftMetadata.keys {
      metadata[key] = nftMetadata[key]!
    }

    return metadata
  }

  // Check if a string begins with a substring
  access(self) fun _startsWith(string: String, substring: String): Bool {
    return substring.length <= string.length
      && string.slice(from: 0, upTo: substring.length) == substring
  }

  // Prefix a uri with a default prefix if it does not start with any of the
  // allowed prefixes
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

  // Use the provided IPFS gateway if the uri starts with the IPFS prefix
  access(self) fun _useIpfsGateway(
    ipfsGateway: String,
    uri: String
  ): String {
    if self._startsWith(string: uri, substring: "ipfs://") {
      return ipfsGateway.concat(uri.slice(from: 7, upTo: uri.length))
    }
    return uri
  }

  // socialsFields can contain metadata keys for URL based socials. This
  // returns a dictionary of {String: MetadataViews.ExternalURL} where the
  // key is the social field name and the value is the ExternalURL struct
  // constructed from the corresponding metadata value
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

  // The full spec of a Trait can be viewed in MetadataViews. In this case,
  // a "trait" is assumed to be a simple string field that describes the NFT.
  // The "rarity" is optional and also another string field. Given these fields
  // and a {String: String} metadata dictionary, this function will form proper
  // Trait structs based on the values from the corresponding fields in the
  // metadata
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
          name: traitField,
          value: trait,
          displayType: nil,
          rarity: rarity,
        ))
      }
    }
    return MetadataViews.Traits(traits: traits)
  }

  // Return the first value from metadata that exists given a list of possible
  // fields and a default if none is found
  access(self) fun _firstValueOrElse(
    metadata: &{String: String},
    fields: [String],
    default: String,
  ): String {
    for field in fields {
      if let value = metadata[field] {
        if value != "" {
          return value
        }
      }
    }
    return default
  }
}
