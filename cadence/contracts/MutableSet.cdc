import MutableMetadata from "./MutableMetadata.cdc"
import MutableMetadataTemplate from "./MutableMetadataTemplate.cdc"

pub contract MutableSet {

  pub resource interface SetPublic {
    pub fun locked(): Bool
    pub fun metadata():
      &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun numTemplates(): Int
    pub fun get(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplatePublic}
  }

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

  pub resource interface SetMinter {
    pub fun locked(): Bool
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun numTemplates(): Int
    pub fun get(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplatePublic}

    pub fun getTemplateMinter(_ id: Int):
      &MutableMetadataTemplate.Template{MutableMetadataTemplate.TemplateMinter} 
  }

  pub resource Set: SetPublic, SetPrivate, SetMinter {

    access(self) var _locked: Bool
    access(self) var _metadata: @MutableMetadata.Metadata
    access(self) var _templates: @[MutableMetadataTemplate.Template]

    pub fun locked(): Bool {
      return self._locked
    }

    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic} {
      return &self._metadata 
        as &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    }

    pub fun metadataAuth():
      &MutableMetadata.Metadata{MutableMetadata.MetadataPrivate}
    {
      return &self._metadata as &MutableMetadata.Metadata
    }
    
    pub fun numTemplates(): Int {
      return self._templates.length
    }

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

    pub fun lock() {
      self._locked = true
    }

    pub fun addTemplate(_ template: @MutableMetadataTemplate.Template) {
      pre {
        !self._locked : "Cannot add template. Set is locked"
      }
      self._templates.append(<-template)
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

  pub fun createSet(metadata: @MutableMetadata.Metadata): @MutableSet.Set {
    return <-create Set(metadata: <-metadata)
  }
}