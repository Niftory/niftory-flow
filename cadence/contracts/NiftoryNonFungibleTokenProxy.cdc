import NiftoryNonFungibleToken from "./NiftoryNonFungibleToken.cdc"

pub contract NiftoryNonFungibleTokenProxy {

  pub let STORAGE_PATH: StoragePath
  pub let PUBLIC_PATH: PublicPath
  pub let PRIVATE_PATH: PrivatePath

  pub resource interface Public {
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
    pub fun replace(
      registryAddress: Address,
      brand: String,
      cap: Capability<&{
        NiftoryNonFungibleToken.ManagerPrivate,
        NiftoryNonFungibleToken.ManagerPublic
      }>
    )

    pub fun access(
      registryAddress: Address,
      brand: String,
    ): &{
        NiftoryNonFungibleToken.ManagerPrivate,
        NiftoryNonFungibleToken.ManagerPublic
      }
  }

  pub resource Proxy: Public, Private {

    // NFT contract address -> Manager capabilities
    access(self) let _proxies: {
      Address: {
        String: Capability<&{
          NiftoryNonFungibleToken.ManagerPrivate,
          NiftoryNonFungibleToken.ManagerPublic
        }>
      }
    }

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

    init() {
      self._proxies = {}
    }
  }

  pub fun create(): @Proxy {
    return <-create Proxy()
  }

  init() {
    self.STORAGE_PATH = /storage/niftory_nft_manager_proxy
    self.PUBLIC_PATH = /public/niftory_nft_manager_proxy
    self.PRIVATE_PATH = /private/niftory_nft_manager_proxy
  }
}