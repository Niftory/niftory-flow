/*
MutableMetadataTemplate
github.com/niftory/niftory-flow

We want to be able to 
- associate multiple objects (resources or structs) with the same metadata. For 
example, we might have a pack of serialized NFTs which all represent the same 
metadata, but each with a different serial number. 
- provide a mechanism for to assure collectors that more resources of
the same metadata cannot be produced, guaranteeing scarcity
- provide a public mechanism to allow "minting" of a declared resource without
allowing other authorized functionality.

MutableMetadataTemplate provides these abilities. Creators may associate 
a MutableMetadata.Metadata (please see that contract for more details) with a 
Template in order to specify an optional "maxMint" field to associate with
a Template. Once maxMint for a Template has been reached, then no more
resources with the same metadata may be created.

This was primarily created to control mints for NonFungibleTokens, but this
should work generically with any resource. That being said, this contract
does not actually do minting of new NFTs. Whenever an NFT is minted, registerMint
must be called alongside. This allows for maximum flexibility.
*/

import MutableMetadata from "./MutableMetadata.cdc"

pub contract MutableMetadataTemplate {

  // ===========================================================================
  // Template Capabilities
  // ===========================================================================

  // Public functionality for Template
  pub resource interface TemplatePublic {
    pub fun locked(): Bool
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun maxMint(): UInt64?
    pub fun minted(): UInt64
  }

  // Private functionality for Template
  pub resource interface TemplatePrivate {
    pub fun locked(): Bool
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun maxMint(): UInt64?
    pub fun minted(): UInt64

    pub fun setMaxMint(max: UInt64)
    pub fun metadataAuth():
      &MutableMetadata.Metadata{MutableMetadata.MetadataPrivate}
    pub fun lock()
  }

  // In order to allow public minting if desired by the NFT brand owners,
  // the mint functionality was put in it's own capability.
  pub resource interface TemplateMinter {
    pub fun locked(): Bool
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun maxMint(): UInt64?
    pub fun minted(): UInt64

    pub fun registerMint()
  }

  // ===========================================================================
  // Template
  // ===========================================================================

  pub resource Template: TemplatePublic, TemplatePrivate, TemplateMinter {

    // ========================================================================
    // Attributes
    // ========================================================================

    // Is this template locked for future minting?
    access(self) var _locked: Bool

    // A MutableMetadata instance is used to store the underyling metadata
    access(self) let _metadata: @MutableMetadata.Metadata

    // Max mint allowed for this metadata. Can be set to nil for unlimited
    access(self) var _maxMint: UInt64?

    // Number of times registerMint has been called on this template
    access(self) var _minted: UInt64

    // ========================================================================
    // Public functions
    // ========================================================================

    // Is this template locked for future minting? 
    pub fun locked(): Bool {
      return self._locked
    }

    // Public version of underyling MutableMetadata.Metadata
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic} {
      return &self._metadata 
        as &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    }
    
    // Max mint allowed for this metadata. Can be set to nil for unlimited
    pub fun maxMint(): UInt64? {
      return self._maxMint
    }

    // Number of times registerMint has been called on this template
    pub fun minted(): UInt64 {
      return self._minted
    }

    // ========================================================================
    // Private functions
    // ========================================================================

    // Private version of underyling MutableMetadata.Metadata
    pub fun metadataAuth(): 
      &MutableMetadata.Metadata{MutableMetadata.MetadataPrivate}
    {
      return &self._metadata 
        as &MutableMetadata.Metadata{MutableMetadata.MetadataPrivate}
    }

    // Lock the metadata from any additional future minting.
    pub fun lock() {
      self._locked = true
    }
    
    // Set the maximum mint of this template if not already set and if
    // not locked
    pub fun setMaxMint(max: UInt64) {
      pre {
        self._maxMint == nil: "maxMint already set"
        max < self._minted: "maxMint must be less than minted"
        !self._locked : "Template is locked"
      }
      self._maxMint = max
    }

    // ========================================================================
    // Minter functions
    // ========================================================================

    // Register a new mint.
    pub fun registerMint() {
      pre {
        self._maxMint == nil || self._minted < self._maxMint! :
          "Minting limit of "
            .concat(self._maxMint!.toString())
            .concat(" reached")
        !self._locked : "Template is locked"
      }
      self._minted = self._minted + 1
    }

    init(metadata: @MutableMetadata.Metadata, maxMint: UInt64?) {
      self._locked = false
      self._metadata <- metadata
      self._maxMint = maxMint
      self._minted = 0
    }

    destroy() {
      destroy self._metadata
    }
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  // Create a Template resource with the given metadata and maxMint
  pub fun createTemplate(
    metadata: @MutableMetadata.Metadata,
    maxMint: UInt64?
  ): @Template {
    return <-create Template(metadata: <-metadata, maxMint: maxMint)
  }
}