/*
MutableMetadata

This contract serves as a container for metadata that can be modified after it
has been created. Any underyling struct can be used as the metadata, and any
observer should be able to inpsect the metadata. A common strategy would be to
use a {String: String} map as the metadata.

Administrators with access to this resource's private capabilities will be
allowed to modify the metadata as they wish until they decide to lock it. After
it has been locked, observers can rest asssured knowing the metadata for a
particular item (most likely an NFT) can no longer be modified.

*/

pub contract MutableMetadata {

  // =========================================================================
  // Metadata
  // =========================================================================

  pub resource interface Public {

    // Is this metadata locked for modification?
    pub fun locked(): Bool

    // Get a copy of the underlying metadata
    pub fun get(): AnyStruct
  }

  pub resource interface Private {

    // Lock this metadata, preventing further modification.
    pub fun lock()

    // Retrieve a modifiable version of the underlying metadata, only if the
    // metadata has not been locked.
    pub fun getMutable(): auth &AnyStruct

    // Replace the metadata entirely with a new underlying metadata AnyStruct,
    // only if the metadata has not been locked.
    pub fun replace(_ new: AnyStruct)
  }

  pub resource Metadata: Public, Private {

    // ========================================================================
    // Attributes
    // ========================================================================

    // Is this metadata locked for modification?
    access(self) var _locked: Bool

    // The actual underlying metadata
    access(self) var _metadata: AnyStruct

    // ========================================================================
    // Public
    // ========================================================================

    pub fun locked(): Bool {
      return self._locked
    }

    pub fun get(): AnyStruct {
      // It's important that a copy is returned and not a reference.
      return self._metadata
    }

    // ========================================================================
    // Private
    // ========================================================================

    pub fun lock() {
      self._locked = true
    }

    pub fun getMutable(): auth &AnyStruct {
      pre {
        !self._locked : "Metadata is locked"
      }
      return &self._metadata as auth &AnyStruct
    }

    pub fun replace(_ new: AnyStruct) {
      pre {
        !self._locked : "Metadata is locked"
      }
      self._metadata = new
    }

    // ========================================================================
    // init/destroy
    // ========================================================================

    init(metadata: AnyStruct) {
      self._locked = false
      self._metadata = metadata
    }
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  // Create a new Metadata resource with the given generic AnyStruct metadata
  pub fun create(metadata: AnyStruct): @Metadata {
    return <-create Metadata(metadata: metadata)
  }
}