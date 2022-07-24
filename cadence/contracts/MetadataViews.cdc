import FungibleToken from "./FungibleToken.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

pub contract MetadataViews {

  pub resource interface Resolver {
    pub fun getViews(): [Type]
    pub fun resolveView(_ view: Type): AnyStruct?
  }

  pub resource interface ResolverCollection {
    pub fun borrowViewResolver(id: UInt64): &{Resolver}
    pub fun getIDs(): [UInt64]
  }

  pub struct Display {

    pub let name: String

    pub let description: String

    pub let thumbnail: AnyStruct{File}

    init(
      name: String,
      description: String,
      thumbnail: AnyStruct{File}
    ) {
      self.name = name
      self.description = description
      self.thumbnail = thumbnail
    }
  }

  pub fun getDisplay(_ viewResolver: &{Resolver}) : Display? {
    if let view = viewResolver.resolveView(Type<Display>()) {
      if let v = view as? Display {
        return v
      }
    }
    return nil
  }

  pub struct interface File {
    pub fun uri(): String
  }

  pub struct HTTPFile: File {
    pub let url: String

    init(url: String) {
      self.url = url
    }

    pub fun uri(): String {
      return self.url
    }
  }

  pub struct IPFSFile: File {

    pub let cid: String

    pub let path: String?

    init(cid: String, path: String?) {
      self.cid = cid
      self.path = path
    }

    pub fun uri(): String {
      if let path = self.path {
        return "ipfs://".concat(self.cid).concat("/").concat(path)
      }

      return "ipfs://".concat(self.cid)
    }
  }

  pub struct Editions {

    pub let infoList: [Edition]

    init(_ infoList: [Edition]) {
      self.infoList = infoList
    }
  }

  pub fun getEditions(_ viewResolver: &{Resolver}) : Editions? {
    if let view = viewResolver.resolveView(Type<Editions>()) {
      if let v = view as? Editions {
        return v
      }
    }
    return nil
  }

  pub struct Edition {

    pub let name: String?

    pub let number: UInt64

    pub let max: UInt64?

    init(name: String?, number: UInt64, max: UInt64?) {
      if max != nil {
        assert(number <= max!, message: "The number cannot be greater than the max number!")
      }
      self.name = name
      self.number = number
      self.max = max
    }
  }


  pub struct Serial {
    pub let number: UInt64

    init(_ number: UInt64) {
      self.number = number
    }
  }

  pub fun getSerial(_ viewResolver: &{Resolver}) : Serial? {
    if let view = viewResolver.resolveView(Type<Serial>()) {
      if let v = view as? Serial {
        return v
      }
    }
    return nil
  }

  /*
  *  Royalty Views
  *  Defines the composable royalty standard that gives marketplaces a unified interface
  *  to support NFT royalties.
  *
  *  Marketplaces can query this `Royalties` struct from NFTs 
  *  and are expected to pay royalties based on these specifications.
  *
  */
  pub struct Royalties {

    access(self) let cutInfos: [Royalty]

    pub init(_ cutInfos: [Royalty]) {
      // Validate that sum of all cut multipliers should not be greater than 1.0
      var totalCut = 0.0
      for royalty in cutInfos {
        totalCut = totalCut + royalty.cut
      }
      assert(totalCut <= 1.0, message: "Sum of cutInfos multipliers should not be greater than 1.0")
      // Assign the cutInfos
      self.cutInfos = cutInfos
    }

    pub fun getRoyalties(): [Royalty] {
      return self.cutInfos
    }
  }

  pub fun getRoyalties(_ viewResolver: &{Resolver}) : Royalties? {
    if let view = viewResolver.resolveView(Type<Royalties>()) {
      if let v = view as? Royalties {
        return v
      }
    }
    return nil
  }

  pub struct Royalty {

    pub let receiver: Capability<&AnyResource{FungibleToken.Receiver}>

    pub let cut: UFix64

    pub let description: String

    init(recepient: Capability<&AnyResource{FungibleToken.Receiver}>, cut: UFix64, description: String) {
      pre {
        cut >= 0.0 && cut <= 1.0 : "Cut value should be in valid range i.e [0,1]"
      }
      self.receiver = recepient
      self.cut = cut
      self.description = description
    }
  }

  pub fun getRoyaltyReceiverPublicPath(): PublicPath {
    return /public/GenericFTReceiver
  }

  pub struct Medias {

    pub let items: [Media]

    init(_ items: [Media]) {
      self.items = items
    }
  }

  pub fun getMedias(_ viewResolver: &{Resolver}) : Medias? {
    if let view = viewResolver.resolveView(Type<Medias>()) {
      if let v = view as? Medias {
        return v
      }
    }
    return nil
  }

  pub struct Media {

    pub let file: AnyStruct{File}

    pub let mediaType: String

    init(file: AnyStruct{File}, mediaType: String) {
      self.file=file
      self.mediaType=mediaType
    }
  }

  pub struct License {
    pub let spdxIdentifier: String

    init(_ identifier: String) {
      self.spdxIdentifier = identifier
    }
  }

  pub fun getLicense(_ viewResolver: &{Resolver}) : License? {
    if let view = viewResolver.resolveView(Type<License>()) {
      if let v = view as? License {
        return v
      }
    }
    return nil
  }


  pub struct ExternalURL {
    pub let url: String

    init(_ url: String) {
      self.url=url
    }
  }

  pub fun getExternalURL(_ viewResolver: &{Resolver}) : ExternalURL? {
    if let view = viewResolver.resolveView(Type<ExternalURL>()) {
      if let v = view as? ExternalURL {
        return v
      }
    }
    return nil
  }

  // A view to expose the information needed store and retrieve an NFT
  //
  // This can be used by applications to setup a NFT collection with proper storage and public capabilities.
  pub struct NFTCollectionData {
    pub let storagePath: StoragePath

    pub let publicPath: PublicPath

    pub let providerPath: PrivatePath

    pub let publicCollection: Type

    pub let publicLinkedType: Type

    pub let providerLinkedType: Type

    pub let createEmptyCollection: ((): @NonFungibleToken.Collection)

    init(
      storagePath: StoragePath,
      publicPath: PublicPath,
      providerPath: PrivatePath,
      publicCollection: Type,
      publicLinkedType: Type,
      providerLinkedType: Type,
      createEmptyCollectionFunction: ((): @NonFungibleToken.Collection)
    ) {
      pre {
        publicLinkedType.isSubtype(of: Type<&{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>()): "Public type must include NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, and MetadataViews.ResolverCollection interfaces."
        providerLinkedType.isSubtype(of: Type<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>()): "Provider type must include NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, and MetadataViews.ResolverCollection interface."
      }
      self.storagePath=storagePath
      self.publicPath=publicPath
      self.providerPath = providerPath
      self.publicCollection=publicCollection
      self.publicLinkedType=publicLinkedType
      self.providerLinkedType = providerLinkedType
      self.createEmptyCollection=createEmptyCollectionFunction
    }
  }

  pub fun getNFTCollectionData(_ viewResolver: &{Resolver}) : NFTCollectionData? {
    if let view = viewResolver.resolveView(Type<NFTCollectionData>()) {
      if let v = view as? NFTCollectionData {
        return v
      }
    }
    return nil
  }

  // A view to expose the information needed to showcase this NFT's collection
  //
  // This can be used by applications to give an overview and graphics of the NFT collection
  // this NFT belongs to.
  pub struct NFTCollectionDisplay {
    // Name that should be used when displaying this NFT collection.
    pub let name: String

    // Description that should be used to give an overview of this collection.
    pub let description: String

    // External link to a URL to view more information about this collection.
    pub let externalURL: ExternalURL

    // Square-sized image to represent this collection.
    pub let squareImage: Media

    // Banner-sized image for this collection, recommended to have a size near 1200x630.
    pub let bannerImage: Media

    // Social links to reach this collection's social homepages.
    // Possible keys may be "instagram", "twitter", "discord", etc.
    pub let socials: {String: ExternalURL}

    init(
      name: String,
      description: String,
      externalURL: ExternalURL,
      squareImage: Media,
      bannerImage: Media,
      socials: {String: ExternalURL}
    ) {
      self.name = name
      self.description = description
      self.externalURL = externalURL
      self.squareImage = squareImage
      self.bannerImage = bannerImage
      self.socials = socials
    }
  }

  pub fun getNFTCollectionDisplay(_ viewResolver: &{Resolver}) : NFTCollectionDisplay? {
    if let view = viewResolver.resolveView(Type<NFTCollectionDisplay>()) {
      if let v = view as? NFTCollectionDisplay {
        return v
      }
    }
    return nil
  }

  // A view to represent a single field of metadata on an NFT.
  //
  // This is used to get traits of individual key/value pairs along with some contextualized data about the trait
  pub struct Trait {
    // The name of the trait. Like Background, Eyes, Hair, etc.
    pub let name: String

    // The underlying value of the trait, the rest of the fields of a trait provide context to the value.
    pub let value: AnyStruct

    // displayType is used to show some context about what this name and value represent
    // for instance, you could set value to a unix timestamp, and specify displayType as "Date" to tell
    // platforms to consume this trait as a date and not a number
    pub let displayType: String?

    // Rarity can also be used directly on an attribute.
    //
    // This is optional because not all attributes need to contribute to the NFT's rarity.
    pub let rarity: Rarity?

    init(name: String, value: AnyStruct, displayType: String?, rarity: Rarity?) {
      self.name = name
      self.value = value
      self.displayType = displayType
      self.rarity = rarity
    }
  }

  // A view to return all the traits on an NFT.
  //
  // This is used to return traits as individual key/value pairs along with some contextualized data about each trait.
  pub struct Traits {
    pub let traits: [Trait]

    init(_ traits: [Trait]) {
      self.traits = traits
    }

    pub fun addTrait(_ t: Trait) {
      self.traits.append(t)
    }
  }

  pub fun getTraits(_ viewResolver: &{Resolver}) : Traits? {
    if let view = viewResolver.resolveView(Type<Traits>()) {
      if let v = view as? Traits {
        return v
      }
    }
    return nil
  }

  // A helper function to easily convert a dictionary to traits. For NFT collections that do not need either of the
  // optional values of a Trait, this method should suffice to give them an array of valid traits.
  pub fun dictToTraits(dict: {String: AnyStruct}, excludedNames: [String]?): Traits {
    // Collection owners might not want all the fields in their metadata included.
    // They might want to handle some specially, or they might just not want them included at all.
    if excludedNames != nil {
      for k in excludedNames! {
        dict.remove(key: k)
      }
    }

    let traits: [Trait] = []
    for k in dict.keys {
      let trait = Trait(name: k, value: dict[k]!, displayType: nil, rarity: nil)
      traits.append(trait)
    }

    return Traits(traits)
  }

  //
  pub struct Rarity {
    pub let score: UFix64?

    pub let max: UFix64?

    pub let description: String?

    init(score: UFix64?, max: UFix64?, description: String?) {
      if score == nil && description == nil {
        panic("A Rarity needs to set score, description or both")
      }

      self.score = score
      self.max = max
      self.description = description
    }
  }

  pub fun getRarity(_ viewResolver: &{Resolver}) : Rarity? {
    if let view = viewResolver.resolveView(Type<Rarity>()) {
      if let v = view as? Rarity {
        return v
      }
    }
    return nil
  }

}
