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

pub contract MutableSet {

  // ===========================================================================
  // Template Capabilities
  // ===========================================================================

  // Public functionality for Set
  pub resource interface SetPublic {
    pub fun locked(): Bool
    pub fun metadata():
      &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun numTemplates(): Int
    pub fun get(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplatePublic}
  }

  // Private functionality for Set
  pub resource interface SetPrivate {
    pub fun locked(): Bool
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun numTemplates(): Int
    pub fun get(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplatePublic}

    pub fun metadataAuth():
      &MutableMetadata.Metadata{MutableMetadata.MetadataPrivate}
    pub fun getAuth(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplatePrivate} 
    pub fun lock()
    pub fun addTemplate(_ template: @MutableMetadataTemplate.Template)
  }

  // In order to allow public minting if desired by the NFT brand owners,
  // the mint functionality was put in it's own capability. 
  pub resource interface SetMinter {
    pub fun locked(): Bool
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun numTemplates(): Int
    pub fun get(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplatePublic}

    pub fun getTemplateMinter(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplateMinter} 
  }

  // ===========================================================================
  // Set
  // ===========================================================================

  pub resource Set: SetPublic, SetPrivate, SetMinter {

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
    // Public functions
    // ========================================================================

    // Is this set locked from more Templates being added?
    pub fun locked(): Bool {
      return self._locked
    }
    
    // Public version of underyling MutableMetadata.Metadata
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic} {
      return &self._metadata 
        as &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    }

    // Number of Templates in this set
    pub fun numTemplates(): Int {
      return self._templates.length
    }

    // Retrieve the public version of a particular template given by the
    // Template ID (index into the self._templates array) only if it exists
    pub fun get(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplatePublic}
    {
      pre {
        id >= 0 && id < self._templates.length :
          id
            .toString()
            .concat(" is not a valid template ID. Number of templates is ")
            .concat(self._templates.length.toString())
      }
      return &self._templates[id]
        as &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplatePublic}
    }

    // ========================================================================
    // Private functions
    // ========================================================================

    // Private version of underyling MutableMetadata.Metadata
    pub fun metadataAuth():
      &MutableMetadata.Metadata{MutableMetadata.MetadataPrivate}
    {
      return &self._metadata as &MutableMetadata.Metadata
    }
    
    // Retrieve the private version of a particular template given by the
    // Template ID (index into the self._templates array) only if it exists
    pub fun getAuth(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplatePrivate}
    {
      pre {
        id >= 0 && id < self._templates.length :
          id
            .toString()
            .concat(" is not a valid template ID. Number of templates is ")
            .concat(self._templates.length.toString())
      }
      return &self._templates[id]
        as &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplatePrivate} 
    }

    // Lock this set so more Templates may not be added to it.
    pub fun lock() {
      self._locked = true
    }

    // Add a Template to this set if not locked
    pub fun addTemplate(_ template: @MutableMetadataTemplate.Template) {
      pre {
        !self._locked : "Cannot add template. Set is locked"
      }
      self._templates.append(<-template)
    }

    // ========================================================================
    // Minter functions
    // ========================================================================

    // Get the minter for a particular Template.
    pub fun getTemplateMinter(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplateMinter}
    {
      pre {
        id >= 0 && id < self._templates.length :
          id
            .toString()
            .concat(" is not a valid template ID. Number of templates is ")
            .concat(self._templates.length.toString())
      }
      return &self._templates[id]
        as &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplateMinter} 
    }


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
  pub fun createSet(metadata: @MutableMetadata.Metadata): @MutableSet.Set {
    return <-create Set(metadata: <-metadata)
  }
}