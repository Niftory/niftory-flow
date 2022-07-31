/*
MutableMetadata
github.com/niftory/niftory-flow

This contract serves as a container for metadata that can be modified after
it has been created. Any underyling struct can be used as the metadata, and
any observer should be able to inpsect the metadata. For example, a common
scenario would be to used a {String: String} map as the metadata.

Administrators with access to this contract's private capabilities will be
allowed to modify the metadata as they wish until they decide to lock it. After
it has been locked, observers can rest asssured knowing the metadata for a
particular item (most likely an NFT) can no longer be modified.

Please contact XXXXXX@niftory.com for additional details.

Created by Niftory (niftory.com)
*/

pub contract MutableMetadata {

  //==========================================================================
  // Metadata Capabilities
  //==========================================================================

  // Public functionality for Metadata (see Metadata for details)
  pub resource interface MetadataPublic {
    pub fun locked(): Bool
    pub fun get(): auth &AnyStruct
  }

  // Private functionality for Metadata (see Metadata for details)
  pub resource interface MetadataPrivate {
    pub fun locked(): Bool
    pub fun get(): auth &AnyStruct

    pub fun lock()
    pub fun replace(new: AnyStruct)
    pub fun auth(): auth &AnyStruct
  }

  // =========================================================================
  // Metadata
  // =========================================================================

  pub resource Metadata: MetadataPublic, MetadataPrivate {

    // ========================================================================
    // Attributes
    // ========================================================================

    // Is this metadata locked for modification?
    access(self) var _locked: Bool

    // The actual underlying metadata
    access(self) var _metadata: AnyStruct 

    // ========================================================================
    // Public functions
    // ========================================================================

    // Is this metadata locked for modification? 
    pub fun locked(): Bool {
      return self._locked
    }

    // Get a copy of the underlying metadata
    pub fun get(): auth &AnyStruct {

      // It's important that this is copied, otherwise the metadata can 
      // be modified by the caller. Without turning it into an auth reference,
      // the caller would not be able to downcast the AnyStruct
      let copied = self._metadata 
      return &copied as auth &AnyStruct
    }

    // ========================================================================
    // Private functions
    // ========================================================================

    // Replace the metadata entirely with a new underlying metadata AnyStruct,
    // only if the metadata has not been locked.
    pub fun replace(new: AnyStruct) {
      pre {
        !self._locked : "Metadata is locked"
      }
      self._metadata = new
    }

    // Retrieve a modifiable version of the underlying metadata, only if the
    // metadata has not been locked.
    pub fun auth(): auth &AnyStruct {
      pre {
        !self._locked : "Metadata is locked"
      }
      return &self._metadata as auth &AnyStruct
    }

    // Lock this metadata, preventing further modification.
    pub fun lock() {
      self._locked = true
    }
    
    init(metadata: AnyStruct) {
      self._locked = false
      self._metadata = metadata
    }
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  // Create a new Metadata resource with the given generic AnyStruct metadata
  pub fun createMetadata(metadata: AnyStruct): @Metadata {
    return <- create Metadata(metadata: metadata)
  }
}