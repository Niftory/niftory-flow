/*
NFTRegistry

Niftory NFTs should ideally be functionally the same. This would allow 
other applications to refer to any Niftory NFT without having to know about
the properties of any individual NFT project. For example, a developer should
not be required to import code from a specific NFT project just to get the
path of where a collection should be found in a users account.

To make this possible, this NFTRegistry associates a single String identifier
to struct of metadata required for the type of agnostic access described above.
This includes
- Paths of NonFungibleToken.Collection
- Paths of the NFT project's Manager
- Paths of the MutableSetManager
- Paths of the MetadataViewManager
*/

pub contract NFTRegistry {

  // ========================================================================
  // Attributes
  // ========================================================================

  // Paths where this Registry and associated interfaces will be located
  pub let StandardRegistryPath: StoragePath
  pub let StandardRegistryPublicPath: PublicPath
  pub let StandardRegistryPrivatePath: PrivatePath

  // ========================================================================
  // RegistryItem
  // ========================================================================

  pub struct RegistryItem {

    // Paths of NonFungibleToken.Collection
    pub let CollectionPublicPath: PublicPath
    pub let CollectionPrivatePath: PrivatePath
    pub let CollectionPath: StoragePath

    // Paths of the NFT project's Manager
    pub let NftManagerPublicPath: PublicPath
    pub let NftManagerPrivatePath: PrivatePath
    pub let NftManagerPath: StoragePath

    // Paths of the MutableSetManager
    pub let SetManagerPublicPath: PublicPath
    pub let SetManagerPrivatePath: PrivatePath
    pub let SetManagerPath: StoragePath

    // Paths of the MetadataViewManager
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

  // ========================================================================
  // Registry capabilities
  // ========================================================================

  // Public functionality for Registry
  pub resource interface RegistryPublic {
    pub fun all(): {String: RegistryItem}
    pub fun infoFor(brand: String): RegistryItem
  }

  // Private functionality for Registry
  pub resource interface RegistryPrivate {
    pub fun all(): {String: RegistryItem}
    pub fun infoFor(brand: String): RegistryItem

    pub fun auth(): auth &{String: RegistryItem}
    pub fun register(brand: String, entry: RegistryItem)
    pub fun deregister(brand: String)
  }

  // ========================================================================
  // Registry
  // ========================================================================

  pub resource Registry: RegistryPublic, RegistryPrivate {

    // ========================================================================
    // Attributes
    // ========================================================================

    // The registry is stored as a simple String -> RegistryItem map, so the
    // admin here must be careful to keep track of the keys present
    access(self) let _registry: {String: RegistryItem}

    // ========================================================================
    // Public functions
    // ========================================================================

    // Return all entries from the registry
    pub fun all(): {String: RegistryItem} {
      return self._registry
    }

    // Return information for a particular brand in the registry
    pub fun infoFor(brand: String): RegistryItem {
      pre {
        self._registry.containsKey(brand) : 
          "NFT ".concat(brand).concat(" is not registered")
      }
      return self._registry[brand]!
    }

    // ========================================================================
    // Private functions
    // ========================================================================

    // Get a modifiable ref of the underlying registry
    pub fun auth(): auth &{String: RegistryItem} {
      return &self._registry as auth &{String: RegistryItem}
    }

    // Register a new brand
    pub fun register(brand: String, entry: RegistryItem) {
      self._registry[brand] = entry
    }

    // Deregister an existing brand
    pub fun deregister(brand: String) {
      pre {
        self._registry.containsKey(brand) : 
          "NFT ".concat(brand).concat(" is not registered")
      }
      self._registry.remove(key: brand)
    }

    init() {
      self._registry = {}
    }
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  // Create a new Registry
  pub fun newRegistry(): @Registry {
    return <-create Registry()
  }

  init() {
    self.StandardRegistryPath = /storage/niftorynftregistry
    self.StandardRegistryPublicPath = /public/niftorynftregistry
    self.StandardRegistryPrivatePath = /private/niftorynftregistry
  }
}