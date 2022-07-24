import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

import MutableMetadata from "./MutableMetadata.cdc"
import MutableSet from "./MutableSet.cdc"
import MutableSetManager from "./MutableSetManager.cdc"

// import MetadataViewsManager from "./MetadataViewsManager.cdc"

pub contract Niftory {

  // Standard location where every Minter will be located 
  pub let StandardMinterPrivatePath: PrivatePath
  pub let StandardMinterPath: StoragePath

  // Standard location where every Set Manager should be located
  pub let StandardSetManagerPublicPath: PublicPath
  pub let StandardSetManagerPrivatePath: PrivatePath
  pub let StandardSetManagerPath: StoragePath

  pub resource interface NFTPublic {
    pub let id: UInt64
    pub let serial: UInt64
    pub let metadataAccessor: MutableSetManager.MetadataAccessor
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun set(): &MutableSet.Set{MutableSet.SetPublic}
    pub fun getViews(): [Type]
    pub fun resolveView(_ view: Type): AnyStruct?
  }

  pub resource interface MinterPrivate {
    pub fun mint(
      metadataAccessor: MutableSetManager.MetadataAccessor,
    ): @NonFungibleToken.NFT
    pub fun mintBulk(
      metadataAccessor: MutableSetManager.MetadataAccessor,
      numToMint: UInt64,
    ): @[NonFungibleToken.NFT]
  }

  pub resource interface CollectionPublic {
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun depositBulk(tokens: @[NonFungibleToken.NFT])
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver}
    pub fun borrow(id: UInt64): &{NFTPublic}
  }

  pub resource interface CollectionPrivate {
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun depositBulk(tokens: @[NonFungibleToken.NFT])
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver}
    pub fun borrow(id: UInt64): &{NFTPublic}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT
    pub fun withdrawBulk(withdrawIDs: [UInt64]): @[NonFungibleToken.NFT]
  }

  // pub resource RoyaltiesResolver: MetadataViewsManager.Resolver {
  //   pub let type: Type
  //   pub let royalties: [MetadataViews.Royalty]
  //   pub fun resolve(_ nftRef: &NonFungibleToken.NFT): AnyStruct? {
  //     return self.royalties
  //   }
  //   init(royalties: [MetadataViews.Royalty]) {
  //     self.type = Type<MetadataViews.Royalties>()
  //     self.royalties = royalties
  //   }
  // } 

  // pub resource IpfsDisplayResolver: MetadataViewsManager.Resolver {
  //   pub let type: Type
  //   pub let titleField: String
  //   pub let descriptionField: String
  //   pub let ipfsImageField: String
  //   pub let defaultTitle: String
  //   pub let defaultDescription: String
  //   pub let defaultIpfsImage: String
  //   pub fun resolve(_ nftRef: &NonFungibleToken.NFT): AnyStruct? {
  //     let nft = nftRef as! &{NFTPublic}
  //     let metadata = nft.metadata()
  //     return MetadataViews.Display(
  //       name: metadata.getOr(key: self.titleField, else: self.defaultTitle),
  //       description: metadata.getOr(
  //         key: self.descriptionField, 
  //         else: self.defaultDescription
  //       ),
  //       thumbnail: MetadataViews.HTTPFile(
  //         url: metadata.getOr(
  //           key: self.ipfsImageField,
  //           else: self.defaultIpfsImage,
  //         )
  //       )
  //     )
  //   }
  //   init(
  //     titleField: String,
  //     descriptionField: String,
  //     ipfsImageField: String,
  //     defaultTitle: String,
  //     defaultDescription: String,
  //     defaultIpfsImage: String,
  //   ) {
  //     self.type = Type<MetadataViews.Display>()
  //     self.titleField = titleField
  //     self.descriptionField = descriptionField
  //     self.ipfsImageField = ipfsImageField
  //     self.defaultTitle = defaultTitle
  //     self.defaultDescription = defaultDescription
  //     self.defaultIpfsImage = defaultIpfsImage
  //   }
  // }

  init() {
    self.StandardMinterPrivatePath = /private/niftoryminter
    self.StandardMinterPath = /storage/niftoryminter

    self.StandardSetManagerPublicPath = /public/niftorysetmanager
    self.StandardSetManagerPrivatePath = /private/niftorysetmanager
    self.StandardSetManagerPath = /storage/niftorysetmanager
  }
}