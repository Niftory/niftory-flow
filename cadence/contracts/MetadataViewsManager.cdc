/*
MetadataViewsManager

MetadataViews (please see that contract for more details) provides metadata
standards for NFTs to implement so 3rd-party applications need not rely on the
specific implementation of a given NFT.

This contract provides a way to augment an NFT contract with a customizable
MetadataViews interface so that admins of this manager may add or remove NFT
Resolvers. These Resolvers take an AnyStruct (likely to be an interface of the
NFT itself) and map that AnyStruct to one of the MetadataViews Standards.

For example, one may make a Display resolver and assume that the "AnyStruct"
object can be downcasted into an interface that can resolve the name,
description, and url of that NFT. For instance, the Resolver can assume the
NFT's underlying metadata is a {String: String} dictionary and the Display name
is the same as nftmetadata['name'].

*/

import MetadataViews from "./MetadataViews.cdc"

pub contract MetadataViewsManager {

  // ===========================================================================
  // Resolver
  // ===========================================================================

  // A Resolver effectively converts one struct into another. Under normal
  // conditions, the input should be an NFT and the output should be a
  // standard MetadataViews interface.
  pub struct interface Resolver {

    // The type of the particular MetadataViews struct this Resolver creates
    pub let type: Type

    // The actual resolve function
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct?
  }

  // ===========================================================================
  // Manager
  // ===========================================================================

  pub resource interface Public {

    // Is manager locked?
    pub fun locked(): Bool

    // Get all views supported by the manager
    pub fun getViews(): [Type]

    // Resolve a particular view of a provided reference struct (i.e. NFT)
    pub fun resolveView(view: Type, nftRef: AnyStruct): AnyStruct?

    // Inspect a raw resolver
    pub fun inspectView(view: Type): {Resolver}?
  }

  pub resource interface Private {

    // Lock this manager so that resolvers can be neither added nor removed
    pub fun lock()

    // Add the given resolver if the manager is not locked
    pub fun addResolver(_ resolver: {Resolver})

    // Remove the resolver of the provided type
    pub fun removeResolver(_ type: Type)
  }

  pub resource Manager: Private, Public {

    // ========================================================================
    // Attributes
    // ========================================================================

    // Is this manager locked?
    access(self) var _locked: Bool

    // Resolvers this manager has available
    access(self) let _resolvers: {Type: {Resolver}}

    // ========================================================================
    // Public
    // ========================================================================

    pub fun locked(): Bool {
      return self._locked
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

    pub fun inspectView(view: Type): {Resolver}? {
      return self._resolvers[view]
    }

    // ========================================================================
    // Private
    // ========================================================================

    pub fun lock() {
      self._locked = true
    }

    pub fun addResolver(_ resolver: AnyStruct{Resolver}) {
      pre {
        !self._locked : "Manager is locked."
      }
      self._resolvers[resolver.type] = resolver
    }

    pub fun removeResolver(_ type: Type) {
      pre {
        !self._locked : "Manager is locked."
      }
      self._resolvers.remove(key: type)
    }

    // ========================================================================
    // init/destroy
    // ========================================================================

    init() {
      self._resolvers = {}
      self._locked = false
    }
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  // Create a new Manager
  pub fun create(): @Manager {
    return <-create Manager()
  }
}
