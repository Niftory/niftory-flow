import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

import MutableMetadata from "./MutableMetadata.cdc"
import MutableSet from "./MutableSet.cdc"
import MutableSetManager from "./MutableSetManager.cdc"
import Niftory from "./Niftory.cdc"

pub contract XXTEMPLATEXX: NonFungibleToken {

  pub var totalSupply: UInt64

  pub let CollectionPrivatePath: PrivatePath
  pub let CollectionPublicPath: PublicPath
  pub let CollectionPath: StoragePath

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  pub fun SetManagerPublic():
      Capability<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>
    {
      return XXTEMPLATEXX.account
        .getCapability<
          &MutableSetManager.Manager{MutableSetManager.ManagerPublic}
        >(Niftory.StandardSetManagerPublicPath)
    }

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
      return []
    }

    pub fun resolveView(_ view: Type): AnyStruct? {
      return nil
    }

    init(metadataAccessor: MutableSetManager.MetadataAccessor, serial: UInt64) {
      self.id = XXTEMPLATEXX.totalSupply
      XXTEMPLATEXX.totalSupply =
        XXTEMPLATEXX.totalSupply + 1
      self.metadataAccessor = metadataAccessor
      self.serial = serial
    }
  }

  // ===========================================================================

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

  // ===========================================================================

  pub resource Minter: Niftory.MinterPrivate {
    pub fun mint(
      metadataAccessor: MutableSetManager.MetadataAccessor,
    ): @NonFungibleToken.NFT {
      let setManagerMinter = XXTEMPLATEXX.account
        .getCapability<&{MutableSetManager.ManagerMinter}>(
          Niftory.StandardSetManagerPrivatePath
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
          Niftory.StandardSetManagerPrivatePath
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

  //=========================================================================

  pub resource ContractData {

    pub fun SetManagerPublic():
      Capability<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>
    {
      return XXTEMPLATEXX.account
        .getCapability<
          &MutableSetManager.Manager{MutableSetManager.ManagerPublic}
        >(Niftory.StandardSetManagerPublicPath)
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
  }


  init() {
    self.totalSupply = 0

    self.CollectionPrivatePath = /private/xxtemplatexxcollection
    self.CollectionPublicPath = /public/xxtemplatexxcollection
    self.CollectionPath = /storage/xxtemplatexxcollection

    self.account.save<@Minter>(
      <-create Minter(),
      to: Niftory.StandardMinterPath
    )
    self.account.link<&{Niftory.MinterPrivate}>(
      Niftory.StandardMinterPrivatePath,
      target: Niftory.StandardMinterPath
    )

    self.account.save<@MutableSetManager.Manager>(
      <-MutableSetManager.createSetManager(
        name: "XXTEMPLATEXX",
        description: "The set manager for XXTEMPLATEXX."
      ),
      to: Niftory.StandardSetManagerPath
    )
    self.account.link<&{
      MutableSetManager.ManagerPrivate,
      MutableSetManager.ManagerMinter
    }>(
      Niftory.StandardSetManagerPrivatePath,
      target: Niftory.StandardSetManagerPath
    )
    self
      .account
      .link<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>(
        Niftory.StandardSetManagerPublicPath,
        target: Niftory.StandardSetManagerPath
      )
  }
}