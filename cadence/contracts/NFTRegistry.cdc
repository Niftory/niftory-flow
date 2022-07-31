pub contract NFTRegistry {

  pub let StandardRegistryPath: StoragePath
  pub let StandardRegistryPublicPath: PublicPath
  pub let StandardRegistryPrivatePath: PrivatePath

  pub struct RegistryItem {
    pub let CollectionPublicPath: PublicPath
    pub let CollectionPrivatePath: PrivatePath
    pub let CollectionPath: StoragePath

    pub let NftManagerPublicPath: PublicPath
    pub let NftManagerPrivatePath: PrivatePath
    pub let NftManagerPath: StoragePath

    pub let SetManagerPublicPath: PublicPath
    pub let SetManagerPrivatePath: PrivatePath
    pub let SetManagerPath: StoragePath

    pub let MetadataViewsPublicPath: PublicPath
    pub let MetadataViewsPrivatePath: PrivatePath
    pub let MetadataViewsPath: StoragePath

    init(
      CollectionPublicPath: PublicPath,
      CollectionPrivatePath: PrivatePath,
      CollectionPath: StoragePath,
      NftManagerPublicPath: PublicPath,
      NftManagerPrivatePath: PrivatePath,
      NftManagerPath: StoragePath,
      SetManagerPublicPath: PublicPath,
      SetManagerPrivatePath: PrivatePath,
      SetManagerPath: StoragePath,
      MetadataViewsPublicPath: PublicPath,
      MetadataViewsPrivatePath: PrivatePath,
      MetadataViewsPath: StoragePath
    ) {
      self.CollectionPublicPath = CollectionPublicPath
      self.CollectionPrivatePath = CollectionPrivatePath
      self.CollectionPath = CollectionPath

      self.NftManagerPublicPath = NftManagerPublicPath
      self.NftManagerPrivatePath = NftManagerPrivatePath
      self.NftManagerPath = NftManagerPath

      self.SetManagerPublicPath = SetManagerPublicPath
      self.SetManagerPrivatePath = SetManagerPrivatePath
      self.SetManagerPath = SetManagerPath

      self.MetadataViewsPublicPath = MetadataViewsPublicPath
      self.MetadataViewsPrivatePath = MetadataViewsPrivatePath
      self.MetadataViewsPath = MetadataViewsPath
    }
  }

  pub resource interface RegistryPublic {
    pub fun all(): {String: RegistryItem}
    pub fun infoFor(brand: String): RegistryItem
  }

  pub resource interface RegistryPrivate {
    pub fun infoFor(brand: String): RegistryItem

    pub fun auth(): auth &{String: RegistryItem}
    pub fun register(brand: String, entry: RegistryItem)
    pub fun deregister(brand: String)
  }

  pub resource Registry: RegistryPublic, RegistryPrivate {
    pub let registry: {String: RegistryItem}

    pub fun all(): {String: RegistryItem} {
      return self.registry
    }

    pub fun infoFor(brand: String): RegistryItem {
      pre {
        self.registry.containsKey(brand) : 
          "NFT ".concat(brand).concat(" is not registered")
      }
      return self.registry[brand]!
    }

    pub fun auth(): auth &{String: RegistryItem} {
      return &self.registry as auth &{String: RegistryItem}
    }

    pub fun register(brand: String, entry: RegistryItem) {
      self.registry[brand] = entry
    }

    pub fun deregister(brand: String) {
      pre {
        self.registry.containsKey(brand) : 
          "NFT ".concat(brand).concat(" is not registered")
      }
      self.registry.remove(key: brand)
    }

    init() {
      self.registry = {}
    }
  }

  pub fun newRegistry(): @Registry {
    return <-create Registry()
  }

  init() {
    self.StandardRegistryPath = /storage/niftorynftregistry
    self.StandardRegistryPublicPath = /public/niftorynftregistry
    self.StandardRegistryPrivatePath = /private/niftorynftregistry
  }
}