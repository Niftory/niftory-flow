/*
MutableSet

We want to be able to associate metadata with a group of related resources.  
Those resources themselves may have their own metadata represented by
MutableMetadataTemplate.Template (please see that contract for more details).
However, think of a use case like an NFT brand manager wanting to release a
season of NFTs. The attributes of the 'season' would apply to all of the NFTs.

MutableSet.Set allows for multiple Templates to be associated with a single
Set-wide MutableMetadata.Metadata.

A Set owner can also signal to observers that no more resources will be added
to a particular logical set of NFTs by locking the Set.
*/

import MutableMetadata from "./MutableMetadata.cdc"
import MutableMetadataTemplate from "./MutableMetadataTemplate.cdc"

pub contract MutableMetadataSet {

  // ===========================================================================
  // Set
  // ===========================================================================

  pub resource interface Public {

    // Is this set locked from more Templates being added?
    pub fun locked(): Bool

    // Number of Templates in this set
    pub fun numTemplates(): Int
    
    // Public version of underyling MutableMetadata.Metadata
    pub fun metadata():
      &MutableMetadata.Metadata{MutableMetadata.Public}
    
    // Retrieve the public version of a particular template given by the
    // Template ID (index into the self._templates array) only if it exists
    pub fun getTemplate(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.Public}
  }

  pub resource interface Private {

    // Lock this set so more Templates may not be added to it.
    pub fun lock()

    // Private version of underyling MutableMetadata.Metadata
    pub fun metadataMutable():
      &MutableMetadata.Metadata{MutableMetadata.Public, MutableMetadata.Private}

    // Retrieve the private version of a particular template given by the
    // Template ID (index into the self._templates array) only if it exists
    pub fun getTemplateMutable(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.Public, MutableMetadataTemplate.Private} 

    // Add a Template to this set if not locked
    pub fun addTemplate(_ template: @MutableMetadataTemplate.Template)
  }

  pub resource Set: Public, Private {

    // ========================================================================
    // Attributes
    // ========================================================================

    // Is this set locked from more Templates being added?
    access(self) var _locked: Bool

    // Public version of underyling MutableMetadata.Metadata
    access(self) var _metadata: @MutableMetadata.Metadata

    // Templates in this set
    access(self) var _templates: @[MutableMetadataTemplate.Template]

    // ========================================================================
    // Public
    // ========================================================================

    pub fun locked(): Bool {
      return self._locked
    }
    
    pub fun numTemplates(): Int {
      return self._templates.length
    }

    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.Public} {
      return &self._metadata 
        as &MutableMetadata.Metadata{MutableMetadata.Public}
    }

    pub fun getTemplate(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.Public}
    {
      pre {
        id >= 0 && id < self._templates.length :
          id
            .toString()
            .concat(" is not a valid template ID. Number of templates is ")
            .concat(self._templates.length.toString())
      }
      return &self._templates[id]
        as &MutableMetadataTemplate.Template{MutableMetadataTemplate.Public}
    }

    // ========================================================================
    // Private
    // ========================================================================

    pub fun lock() {
      self._locked = true
    }

    pub fun metadataMutable():
      &MutableMetadata.Metadata{MutableMetadata.Public, MutableMetadata.Private}
    {
      return &self._metadata as &MutableMetadata.Metadata
    }
    
    pub fun getTemplateMutable(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.Public, MutableMetadataTemplate.Private}
    {
      pre {
        id >= 0 && id < self._templates.length :
          id
            .toString()
            .concat(" is not a valid template ID. Number of templates is ")
            .concat(self._templates.length.toString())
      }
      return &self._templates[id]
        as &MutableMetadataTemplate.Template{MutableMetadataTemplate.Public, MutableMetadataTemplate.Private} 
    }

    pub fun addTemplate(_ template: @MutableMetadataTemplate.Template) {
      pre {
        !self._locked : "Cannot add template. Set is locked"
      }
      self._templates.append(<-template)
    }

    // ========================================================================
    // init/destroy
    // ========================================================================

    init(metadata: @MutableMetadata.Metadata) {
      self._locked = false
      self._metadata <- metadata
      self._templates <- []
    }

    destroy() {
      destroy self._metadata
      destroy self._templates
    }
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  // Create a new Set resource with the given Metadata
  pub fun create(metadata: @MutableMetadata.Metadata): @Set {
    return <-create Set(metadata: <-metadata)
  }
}