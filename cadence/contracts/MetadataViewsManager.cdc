import MetadataViews from "./MetadataViews.cdc"

pub contract MetadataViewsManager {

  pub resource interface Resolver {
    pub let type: Type
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct?
  }

  pub resource interface ManagerPublic {
    pub fun getViews(): [Type]
    pub fun resolveView(view: Type, nftRef: AnyStruct): AnyStruct?
  }

  pub resource interface ManagerPrivate {
    pub fun getViews(): [Type]
    pub fun resolveView(view: Type, nftRef: AnyStruct): AnyStruct?

    pub fun addResolver(_ resolver: @{Resolver})
    pub fun removeResolver(type: Type)
  }

  pub resource Manager: ManagerPrivate, ManagerPublic {

    access(self) let _resolvers: @{Type: {Resolver}}
    access(self) var _locked: Bool

    pub fun addResolver(_ resolver: @{Resolver}) {
      pre {
        !self._locked : "Manager is locked."
      }
      let oldResolver <- self._resolvers[resolver.type] <- resolver
      destroy oldResolver
    }

    pub fun removeResolver(type: Type) {
      pre {
        !self._locked : "Manager is locked."
      }
      destroy self._resolvers.remove(key: type)
    }

    pub fun getViews(): [Type] {
      return self._resolvers.keys
    }

    pub fun resolveView(view: Type, nftRef: AnyStruct): AnyStruct? {
      let resolverRef = &self._resolvers[view] as &{Resolver}?
      if (resolverRef == nil) {
        return nil
      }
      return resolverRef!.resolve(nftRef)
    }

    pub fun lock() {
      self._locked = true
    }

    init() {
      self._resolvers <- {}
      self._locked = false
    }

    destroy() {
      destroy self._resolvers
    }
  }

  pub fun createManager(): @Manager {
    return <- create Manager()
  }
}