/*
NiftoryNonFungibleTokenProxy

NiftoryNonFungibleToken broadly defines private and public capabilities for
a Niftory NFT Manager. Providing access to those capabilities can be done in
an endless number of ways. This contract provides a simple way to distribute
full access to the NFT Manager capabilities for multiple Niftory NFT contracts.

A registryAddress and brand can uniquely identify a Niftory NFT project, and so
those are used as part of the index for the corresponding project's NFT Manager
capability.

*/

import NiftoryNonFungibleToken from "./NiftoryNonFungibleToken.cdc"

pub contract NiftoryNonFungibleTokenProxy {

  // ========================================================================
  // Constants
  // ========================================================================

  // Suggested paths where this proxy can be stored
  pub let STORAGE_PATH: StoragePath
  pub let PUBLIC_PATH: PublicPath
  pub let PRIVATE_PATH: PrivatePath

  // ========================================================================
  //  Proxy
  // ========================================================================

  pub resource interface Public {

    // Add a manager capability for the NFT project identified by the given
    // registryAddress and brand
    pub fun add(
      registryAddress: Address,
      brand: String,
      cap: Capability<&{
        NiftoryNonFungibleToken.ManagerPrivate,
        NiftoryNonFungibleToken.ManagerPublic
      }>
    )
  }

  pub resource interface Private {

    // Replace the manager capability for the NFT project identified by the
    // given registryAddress and brand
    pub fun replace(
      registryAddress: Address,
      brand: String,
      cap: Capability<&{
        NiftoryNonFungibleToken.ManagerPrivate,
        NiftoryNonFungibleToken.ManagerPublic
      }>
    )

    // Get the manager capability for the NFT project identified by the given
    // registryAddress and brand
    pub fun access(
      registryAddress: Address,
      brand: String,
    ): &{
        NiftoryNonFungibleToken.ManagerPrivate,
        NiftoryNonFungibleToken.ManagerPublic
      }
  }

  pub resource Proxy: Public, Private {

    // ========================================================================
    // Attributes
    // ========================================================================

    // (registryAddress, brand) -> Manager capabilities
    access(self) let _proxies: {
      Address: {
        String: Capability<&{
          NiftoryNonFungibleToken.ManagerPrivate,
          NiftoryNonFungibleToken.ManagerPublic
        }>
      }
    }

    // ========================================================================
    // Public
    // ========================================================================

    pub fun add(
      registryAddress: Address,
      brand: String,
      cap: Capability<&{
        NiftoryNonFungibleToken.ManagerPrivate,
        NiftoryNonFungibleToken.ManagerPublic
      }>
    ) {
      pre {
        (self._proxies[registryAddress] == nil)
          || self._proxies[registryAddress]![brand] == nil:
          "NFT Manager capability already exists for contract at address "
            .concat(registryAddress.toString())
            .concat(" for brand ")
            .concat(brand)
      }
      if self._proxies[registryAddress] == nil {
        self._proxies[registryAddress] = {}
      }
      let caps = &self._proxies[registryAddress]! as &{
        String: Capability<&{
          NiftoryNonFungibleToken.ManagerPrivate,
          NiftoryNonFungibleToken.ManagerPublic
        }>
      }
      caps[brand] = cap
    }

    // ========================================================================
    // Private
    // ========================================================================

    pub fun replace(
      registryAddress: Address,
      brand: String,
      cap: Capability<&{
        NiftoryNonFungibleToken.ManagerPrivate,
        NiftoryNonFungibleToken.ManagerPublic
      }>
    ) {
      if self._proxies[registryAddress] == nil {
        self._proxies[registryAddress] = {}
      }
      let caps = &self._proxies[registryAddress]! as &{
        String: Capability<&{
          NiftoryNonFungibleToken.ManagerPrivate,
          NiftoryNonFungibleToken.ManagerPublic
        }>
      }
      caps[brand] = cap
    }

    pub fun access(
      registryAddress: Address,
      brand: String,
    ): &{
        NiftoryNonFungibleToken.ManagerPrivate,
        NiftoryNonFungibleToken.ManagerPublic
      } {
      pre {
        (self._proxies[registryAddress] != nil)
          && self._proxies[registryAddress]![brand] != nil:
          "No NFT manager capability for contract at address "
            .concat(registryAddress.toString())
            .concat(" for brand ")
            .concat(brand)
        self._proxies[registryAddress]![brand]!.check() :
          "Cannot find NFT manager for capability for contract at address"
            .concat(registryAddress.toString())
            .concat(" for brand ")
            .concat(brand)
      }
      return self._proxies[registryAddress]![brand]!.borrow()!
    }

    // ========================================================================
    // init/destroy
    // ========================================================================

    init() {
      self._proxies = {}
    }
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  // Create a proxy
  pub fun create(): @Proxy {
    return <-create Proxy()
  }

  // Initialize contract params
  init() {
    self.STORAGE_PATH = /storage/niftory_nft_manager_proxy
    self.PUBLIC_PATH = /public/niftory_nft_manager_proxy
    self.PRIVATE_PATH = /private/niftory_nft_manager_proxy
  }
}