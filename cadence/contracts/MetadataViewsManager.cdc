/*
MetadataViewsManager

MetadataViews (please see that contract for more details) provides metadata 
standards for NFTs to implement so 3rd-party applications do not need to rely
on the specifics of a given NFT.

This contract provides a way to augment an NFT contract with a customizable
MetadataViews interface so that admins of an instance of this manager may 
add or remove NFT Resolvers. These Resolvers take an AnyStruct (likely to
be an interface of the NFT itself) and map that AnyStruct to one of the 
MetadataViews Standards.

For example, one may make a Display resolver and assume that the "AnyStruct"
object can be downcasted into an interface that can resolve the name,
description, and url of that NFT.
*/

import MetadataViews from "./MetadataViews.cdc"

pub contract MetadataViewsManager {

  // ===========================================================================
  // Resolver 
  // ===========================================================================

  // A Resolver effectively converts one struct into another. Under normal
  // conditions, the input should be an NFT and the output should be a 
  // standard MetadataViews interface.
  pub resource interface Resolver {

    // The type of the particular MetadataViews struct this Resolver creates
    pub let type: Type

    // The actual resolve function
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct?
  }

  // ===========================================================================
  // Manager Capabilities
  // ===========================================================================

  // Public functionality for Manager
  pub resource interface ManagerPublic {
    pub fun getViews(): [Type]
    pub fun resolveView(view: Type, nftRef: AnyStruct): AnyStruct?
  }

  // Private functionality for Manager
  pub resource interface ManagerPrivate {
    pub fun getViews(): [Type]
    pub fun resolveView(view: Type, nftRef: AnyStruct): AnyStruct?

    pub fun lock()
    pub fun addResolver(_ resolver: @{Resolver})
    pub fun removeResolver(type: Type)
  }

  // ===========================================================================
  // Manager
  // ===========================================================================

  pub resource Manager: ManagerPrivate, ManagerPublic {

    // ========================================================================
    // Attributes
    // ========================================================================

    // Is this manager locked?
    access(self) var _locked: Bool

    // Resolvers this manager has available
    access(self) let _resolvers: @{Type: {Resolver}}

    // ========================================================================
    // Public functions
    // ========================================================================

    // Get all views supported by the manager
    pub fun getViews(): [Type] {
      return self._resolvers.keys
    }

    // Resolve a particular view of a provided reference struct (i.e. NFT) 
    pub fun resolveView(view: Type, nftRef: AnyStruct): AnyStruct? {
      let resolverRef = &self._resolvers[view] as &{Resolver}?
      if (resolverRef == nil) {
        return nil
      }
      return resolverRef!.resolve(nftRef)
    }

    // ========================================================================
    // Private functions
    // ========================================================================

    // Lock this manager so that resolvers cannot be added nor removed
    pub fun lock() {
      self._locked = true
    }

    // Add the given resolver if the manager is not locked
    pub fun addResolver(_ resolver: @{Resolver}) {
      pre {
        !self._locked : "Manager is locked."
      }
      let oldResolver <- self._resolvers[resolver.type] <- resolver
      destroy oldResolver
    }

    // Remove the resolver of the provided type
    pub fun removeResolver(type: Type) {
      pre {
        !self._locked : "Manager is locked."
      }
      destroy self._resolvers.remove(key: type)
    }

    init() {
      self._resolvers <- {}
      self._locked = false
    }

    destroy() {
      destroy self._resolvers
    }
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  // Create a new Manager
  pub fun createManager(): @Manager {
    return <- create Manager()
  }
}