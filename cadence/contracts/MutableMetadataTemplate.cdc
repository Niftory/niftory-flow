import MutableMetadata from "./MutableMetadata.cdc"

pub contract MutableMetadataTemplate {

  pub resource interface TemplatePublic {
    pub fun locked(): Bool
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun maxMint(): UInt64?
    pub fun minted(): UInt64
  }

  pub resource interface TemplatePrivate {
    pub fun locked(): Bool
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun maxMint(): UInt64?
    pub fun minted(): UInt64

    pub fun metadataAuth():
      &MutableMetadata.Metadata{MutableMetadata.MetadataPrivate}
    pub fun lock()
  }

  pub resource interface TemplateMinter {
    pub fun locked(): Bool
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun maxMint(): UInt64?
    pub fun minted(): UInt64

    pub fun registerMint()
  }

  pub resource Template: TemplatePublic, TemplatePrivate, TemplateMinter {

    access(self) var _locked: Bool
    access(self) var _metadata: @MutableMetadata.Metadata
    access(self) let _maxMint: UInt64?
    access(self) var _minted: UInt64

    pub fun locked(): Bool {
      return self._locked
    }

    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic} {
      return &self._metadata 
        as &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    }

    pub fun maxMint(): UInt64? {
      return self._maxMint
    }

    pub fun minted(): UInt64 {
      return self._minted
    }

    pub fun metadataAuth(): 
      &MutableMetadata.Metadata{MutableMetadata.MetadataPrivate}
    {
      return &self._metadata 
        as &MutableMetadata.Metadata{MutableMetadata.MetadataPrivate}
    }

    pub fun lock() {
      self._locked = true
    }

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

  pub fun createTemplate(
    metadata: @MutableMetadata.Metadata,
    maxMint: UInt64?
  ): @Template {
    return <-create Template(metadata: <-metadata, maxMint: maxMint)
  }
}