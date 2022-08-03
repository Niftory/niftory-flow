/*
XXTEMPLATEXX

This is the contract for XXTEMPLATEXX NFTs! 

This was implemented using Niftory interfaces. For full details on how this
contract functions, please see the Niftory and NFTRegistry contracts.
*/
import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

import MutableMetadata from "./MutableMetadata.cdc"
import MutableSet from "./MutableSet.cdc"
import MutableSetManager from "./MutableSetManager.cdc"
import MetadataViewsManager from "./MetadataViewsManager.cdc"

import Niftory from "./Niftory.cdc"
import NFTRegistry from "./NFTRegistry.cdc"

pub contract XXTEMPLATEXX: NonFungibleToken {

  // ========================================================================
  // Attributes
  // ========================================================================

  pub var totalSupply: UInt64

  pub let CollectionPrivatePath: PrivatePath
  pub let CollectionPublicPath: PublicPath
  pub let CollectionPath: StoragePath

  // ========================================================================
  // Contract Events
  // ========================================================================

  // This contract was initialized
  pub event ContractInitialized()

  // A withdrawal of NFT `id` has occurred from the `from` Address
  pub event Withdraw(id: UInt64, from: Address?)

  // A deposit of an NFT `id` has occurred to the `to` Address
  pub event Deposit(id: UInt64, to: Address?)

  // ========================================================================
  // Contract functions
  // ========================================================================

  pub fun nftBrandMetadata(): NFTRegistry.RegistryItem {
    let registry = getAccount(0x01cf0e2f2f715450).getCapability(
      NFTRegistry.StandardRegistryPublicPath
    ).borrow<&{NFTRegistry.RegistryPublic}>()!
    let nftBrandMetadata = registry.infoFor(brand: "ExampleNFT")
    return nftBrandMetadata
  }

  pub fun SetManagerPublic():
      Capability<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>
    {
      return XXTEMPLATEXX.account
        .getCapability<
          &MutableSetManager.Manager{MutableSetManager.ManagerPublic}
        >(self.nftBrandMetadata().SetManagerPublicPath)
    }

  pub fun MetadataViewsManagerPublic():
      Capability<
        &MetadataViewsManager.Manager{MetadataViewsManager.ManagerPublic}
      >
    {
      return XXTEMPLATEXX.account
        .getCapability<
          &MetadataViewsManager.Manager{MetadataViewsManager.ManagerPublic}
        >(self.nftBrandMetadata().MetadataViewsPublicPath)
    }

  pub fun NFTCollectionData(): MetadataViews.NFTCollectionData {
    return MetadataViews.NFTCollectionData(
      storagePath: XXTEMPLATEXX.CollectionPath,
      publicPath: XXTEMPLATEXX.CollectionPublicPath,
      providerPath: XXTEMPLATEXX.CollectionPrivatePath,
      publicCollection: Type<&{
        NonFungibleToken.CollectionPublic,
        Niftory.CollectionPublic
      }>(),
      publicLinkedType: Type<&{
        NonFungibleToken.Receiver,
        NonFungibleToken.CollectionPublic,
        MetadataViews.ResolverCollection,
        Niftory.CollectionPublic
      }>(),
      providerLinkedType: Type<&{
        NonFungibleToken.Provider,
        NonFungibleToken.Receiver,
        NonFungibleToken.CollectionPublic,
        MetadataViews.ResolverCollection,
        Niftory.CollectionPublic
      }>(),
      createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
          return <-XXTEMPLATEXX.createEmptyCollection()
      })
    )
  }
    
  // ========================================================================
  // NFT
  // ========================================================================

  pub resource NFT:
    NonFungibleToken.INFT,
    MetadataViews.Resolver,
    Niftory.NFTPublic
  {
    pub let id: UInt64
    pub let metadataAccessor: MutableSetManager.MetadataAccessor
    pub let serial: UInt64

    pub fun set(): &MutableSet.Set{MutableSet.SetPublic} {
      pre {
        XXTEMPLATEXX.SetManagerPublic().check() :
          "Cannot find set manager capability"
      }
      return XXTEMPLATEXX
        .SetManagerPublic()
        .borrow()!
        .get(self.metadataAccessor.setId)
    }
  
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic} {
      pre {
        XXTEMPLATEXX.SetManagerPublic().check() :
          "Cannot find set manager capability"
      }
      return self.set().get(self.metadataAccessor.templateId).metadata()
    }

    pub fun getViews(): [Type] {
      pre {
        XXTEMPLATEXX.MetadataViewsManagerPublic().check() :
          "Cannot find metadata views manager capability"
      }
      return XXTEMPLATEXX
        .MetadataViewsManagerPublic()
        .borrow()!
        .getViews()
    }

    pub fun resolveView(_ view: Type): AnyStruct? {
      pre {
        XXTEMPLATEXX.MetadataViewsManagerPublic().check() :
          "Cannot find metadata views manager capability"
      }
      let nftRef = &self as &{Niftory.NFTPublic}
      return XXTEMPLATEXX
        .MetadataViewsManagerPublic()
        .borrow()!
        .resolveView(view: view, nftRef: nftRef)
    }

    pub fun SetManagerPublic():
      Capability<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>
    {
      return XXTEMPLATEXX.SetManagerPublic()
    }

    pub fun NFTCollectionData(): MetadataViews.NFTCollectionData {
      return XXTEMPLATEXX.NFTCollectionData()
    }
    

    init(metadataAccessor: MutableSetManager.MetadataAccessor, serial: UInt64) {
      self.id = XXTEMPLATEXX.totalSupply
      XXTEMPLATEXX.totalSupply =
        XXTEMPLATEXX.totalSupply + 1
      self.metadataAccessor = metadataAccessor
      self.serial = serial
    }
  }

  // ========================================================================
  // Collection
  // ========================================================================

  pub resource Collection:
    NonFungibleToken.Provider,
    NonFungibleToken.Receiver,
    NonFungibleToken.CollectionPublic,
    MetadataViews.ResolverCollection,
    Niftory.CollectionPublic,
    Niftory.CollectionPrivate
  {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun deposit(token: @NonFungibleToken.NFT) {
      let token <- token as! @XXTEMPLATEXX.NFT
      let id: UInt64 = token.id
      let oldToken <- self.ownedNFTs[id] <- token
      emit Deposit(id: id, to: self.owner?.address)
      destroy oldToken
    }

    pub fun depositBulk(tokens: @[NonFungibleToken.NFT]) {
      while tokens.length > 0 {
        let token <- tokens.removeLast() as! @XXTEMPLATEXX.NFT
        self.deposit(token: <-token)
      }
      destroy tokens
    }

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      pre {
        self.ownedNFTs[withdrawID] != nil
          : "NFT "
            .concat(withdrawID.toString())
            .concat(" does not exist in collection.")
      }
      let token <-self.ownedNFTs.remove(key: withdrawID)!
      emit Withdraw(id: token.id, from: self.owner?.address)
      return <-token
    }

    pub fun withdrawBulk(withdrawIDs: [UInt64]): @[NonFungibleToken.NFT] {
      let tokens: @[NonFungibleToken.NFT] <- []
      while withdrawIDs.length > 0 {
        tokens.append(<- self.withdraw(withdrawID: withdrawIDs.removeLast()))
      }
      return <-tokens
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      pre {
        self.ownedNFTs[id] != nil : "NFT does not exist in collection."
      }
      return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
    }
  
    pub fun borrowViewResolver(
      id: UInt64
    ): &AnyResource{MetadataViews.Resolver} {
      pre {
        self.ownedNFTs[id] != nil : "NFT does not exist in collection."
      }
      let nftRef = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
      let fullNft = nftRef as! &NFT
      return fullNft as &AnyResource{MetadataViews.Resolver}
    }

    pub fun borrow(id: UInt64): &NFT{Niftory.NFTPublic} {
      pre {
        self.ownedNFTs[id] != nil : "NFT does not exist in collection."
      }
      let nftRef = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
      let fullNft = nftRef as! &NFT
      return fullNft as &NFT{Niftory.NFTPublic}
    }
  
    init() {
      self.ownedNFTs <- {}
    }
    
    destroy() {
      destroy self.ownedNFTs
    }
  }

  pub fun createEmptyCollection(): @Collection {
    return <-create Collection()
  }

  // ========================================================================
  // Manager
  // ========================================================================

  pub resource Manager: Niftory.ManagerPublic, Niftory.ManagerPrivate {

    pub fun SetManagerPublic():
      Capability<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>
    {
      return XXTEMPLATEXX.SetManagerPublic()
    }

    pub fun NFTCollectionData(): MetadataViews.NFTCollectionData {
      return XXTEMPLATEXX.NFTCollectionData()
    }

    pub fun MetadataViewsManagerPublic():
      Capability<
        &MetadataViewsManager.Manager{MetadataViewsManager.ManagerPublic}
      >
    {
      return XXTEMPLATEXX.MetadataViewsManagerPublic()
    }
    
    pub fun mint(
      metadataAccessor: MutableSetManager.MetadataAccessor,
    ): @NonFungibleToken.NFT {
      let setManagerMinter = XXTEMPLATEXX.account
        .getCapability<&{MutableSetManager.ManagerMinter}>(
          XXTEMPLATEXX.nftBrandMetadata().SetManagerPrivatePath
        ).borrow()!
      let templateMinter = setManagerMinter
        .getSetMinter(metadataAccessor.setId)
        .getTemplateMinter(metadataAccessor.templateId)
      templateMinter.registerMint()
      let serial = templateMinter.minted()
      let nft <-create NFT(metadataAccessor: metadataAccessor, serial: serial)
      return <-nft
    }

    pub fun mintBulk(
      metadataAccessor: MutableSetManager.MetadataAccessor,
      numToMint: UInt64,
    ): @[NonFungibleToken.NFT] {
      let setManagerMinter = XXTEMPLATEXX.account
        .getCapability<&{MutableSetManager.ManagerMinter}>(
          XXTEMPLATEXX.nftBrandMetadata().SetManagerPrivatePath
        ).borrow()!
      let templateMinter = setManagerMinter
        .getSetMinter(metadataAccessor.setId)
        .getTemplateMinter(metadataAccessor.templateId)
      let nfts: @[NonFungibleToken.NFT] <- []
      var leftToMint = numToMint
      while leftToMint > 0 {
        templateMinter.registerMint()
        let serial = templateMinter.minted()
        let nft <-create NFT(metadataAccessor: metadataAccessor, serial: serial)
        nfts.append(<-nft)
        leftToMint = leftToMint - 1
      }
      return <-nfts
    }
  }

  // ========================================================================
  // Init
  // ========================================================================

  init() {

    let registry = getAccount(0x01cf0e2f2f715450).getCapability(
      NFTRegistry.StandardRegistryPublicPath
    ).borrow<&{NFTRegistry.RegistryPublic}>()!
    let nftBrandMetadata = registry.infoFor(brand: "ExampleNFT")

    // Initialize the total supply to 0.
    self.totalSupply = 0

    self.CollectionPrivatePath = nftBrandMetadata.CollectionPrivatePath
    self.CollectionPublicPath = nftBrandMetadata.CollectionPublicPath
    self.CollectionPath = nftBrandMetadata.CollectionPath

    // Save the NFT Manager to this contract's storage.
    self
      .account
      .save<@Manager>(
        <-create Manager(),
        to: nftBrandMetadata.NftManagerPath
      )
    self
      .account
      .link<&{Niftory.ManagerPublic}>(
        nftBrandMetadata.NftManagerPublicPath,
        target: nftBrandMetadata.NftManagerPath
      )
    self
      .account
      .link<&{Niftory.ManagerPrivate}>(
        nftBrandMetadata.NftManagerPrivatePath,
        target: nftBrandMetadata.NftManagerPath
      )

    // Save a MutableSetManager to this contract's storage, as the source of
    // this NFT contract's metadata.
    self
      .account
      .save<@MutableSetManager.Manager>(
        <-MutableSetManager.createSetManager(
          name: "XXTEMPLATEXX",
          description: "The set manager for XXTEMPLATEXX."
        ),
        to: nftBrandMetadata.SetManagerPath
      )
    self
      .account
      .link<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>(
        nftBrandMetadata.SetManagerPublicPath,
        target: nftBrandMetadata.SetManagerPath
      )
    self
      .account
      .link<&{
        MutableSetManager.ManagerPrivate,
        MutableSetManager.ManagerMinter
      }>(
        nftBrandMetadata.SetManagerPrivatePath,
        target: nftBrandMetadata.SetManagerPath
      )

    // Save a MetadataViewsManager to this contract's storage, which will
    // allow observers to inspect standardized metadata through any of its
    // configured MetadataViews resolvers.
    self
      .account
      .save<@MetadataViewsManager.Manager>(
        <-MetadataViewsManager.createManager(),
        to: nftBrandMetadata.MetadataViewsPath
      )
    self
      .account
      .link<&MetadataViewsManager.Manager{MetadataViewsManager.ManagerPublic}>(
        nftBrandMetadata.MetadataViewsPublicPath,
        target: nftBrandMetadata.MetadataViewsPath
      )
    self
      .account
      .link<&MetadataViewsManager.Manager{MetadataViewsManager.ManagerPrivate}>(
        nftBrandMetadata.MetadataViewsPrivatePath,
        target: nftBrandMetadata.MetadataViewsPath
      )
  }
}