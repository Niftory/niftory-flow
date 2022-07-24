pub contract NFTRegistry {

  pub struct RegistryItem {
    pub let collectionPublicPath: PublicPath
    init(collectionPublicPath: PublicPath) {
      self.collectionPublicPath = collectionPublicPath
    }
  }

  pub resource interface RegistryPublic {
    pub fun all(): {String: RegistryItem}
    pub fun infoFor(nft: String): RegistryItem
  }

  pub resource interface RegistryPrivate {
    pub fun infoFor(nft: String): RegistryItem

    pub fun auth(): auth &{String: RegistryItem}
    pub fun register(brand: String, entry: RegistryItem)
    pub fun deregister(brand: String)
  }

  pub resource Registry: RegistryPublic, RegistryPrivate {
    pub let registry: {String: RegistryItem}

    pub fun all(): {String: RegistryItem} {
      return self.registry
    }

    pub fun infoFor(nft: String): RegistryItem {
      pre {
        self.registry.containsKey(nft) : 
          "NFT ".concat(nft).concat(" is not registered")
      }
      return self.registry[nft]!
    }

    pub fun auth(): auth &{String: RegistryItem} {
      return &self.registry as auth &{String: RegistryItem}
    }

    pub fun register(brand: String, entry: RegistryItem) {
      self.registry[brand] = entry
    }

    pub fun deregister(nft: String) {
      pre {
        self.registry.containsKey(nft) : 
          "NFT ".concat(nft).concat(" is not registered")
      }
      self.registry.remove(key: nft)
    }

    init() {
      self.registry = {}
    }
  }

  pub fun newRegistry(): @Registry {
    return <-create Registry()
  }
}