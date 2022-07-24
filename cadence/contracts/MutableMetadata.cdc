pub contract MutableMetadata {

  pub resource interface MetadataPublic {
    pub fun locked(): Bool
    pub fun get(key: String): String?
    pub fun getOr(key: String, else: String): String
    pub fun fields(): [String]
    pub fun all(): {String: String}
  }

  pub resource interface MetadataPrivate {
    pub fun locked(): Bool
    pub fun get(key: String): String?
    pub fun getOr(key: String, else: String): String
    pub fun fields(): [String]
    pub fun all(): {String: String}

    pub fun lock()
    pub fun replace(newMetadata: {String: String})
    pub fun set(key: String, value: String)
    pub fun delete(key: String)
  }

  pub resource Metadata: MetadataPublic, MetadataPrivate {

    access(self) var _locked: Bool
    access(self) var _metadata: {String: String}

    pub fun locked(): Bool {
      return self._locked
    }

    pub fun get(key: String): String? {
      return self._metadata[key]
    }

    pub fun getOr(key: String, else: String): String {
      if self._metadata.containsKey(key) {
        return self._metadata[key]!
      } else {
        return else
      }
    }

    pub fun fields(): [String] {
      return self._metadata.keys
    }

    pub fun all(): {String: String} {
      return self._metadata
    }

    pub fun lock() {
      self._locked = true
    }

    pub fun replace(newMetadata: {String: String}) {
      pre {
        !self._locked : "Metadata is locked"
      }
      self._metadata = newMetadata
    }

    pub fun set(key: String, value: String) {
      pre {
        !self._locked : "Metadata is locked"
      }
      self._metadata[key] = value
    }

    pub fun delete(key: String) {
      pre {
        !self._locked : "Metadata is locked"
      }
      self._metadata.remove(key: key)
    }
    
    init(metadata: {String: String}) {
      self._locked = false
      self._metadata = metadata
    }
  }

  pub fun createMetadata(metadata: {String: String}): @Metadata {
    return <- create Metadata(metadata: metadata)
  }
}