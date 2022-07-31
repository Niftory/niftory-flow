import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

import MutableMetadata from "./MutableMetadata.cdc"
import MutableSet from "./MutableSet.cdc"
import MutableSetManager from "./MutableSetManager.cdc"

import MetadataViewsManager from "./MetadataViewsManager.cdc"

pub contract Niftory {

  //=========================================================================

  pub resource interface NFTPublic {
    pub let id: UInt64
    pub let serial: UInt64
    pub let metadataAccessor: MutableSetManager.MetadataAccessor
    pub fun metadata(): &MutableMetadata.Metadata{MutableMetadata.MetadataPublic}
    pub fun set(): &MutableSet.Set{MutableSet.SetPublic}
    pub fun getViews(): [Type]
    pub fun resolveView(_ view: Type): AnyStruct?
    pub fun SetManagerPublic():
        Capability<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>
    pub fun NFTCollectionData(): MetadataViews.NFTCollectionData
  }

  //=========================================================================

  pub resource interface ManagerPublic {
    pub fun SetManagerPublic():
      Capability<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>
    pub fun NFTCollectionData(): MetadataViews.NFTCollectionData
    pub fun MetadataViewsManagerPublic():
      Capability<
        &MetadataViewsManager.Manager{MetadataViewsManager.ManagerPublic}
      >
  }

  pub resource interface ManagerPrivate {
    pub fun SetManagerPublic():
      Capability<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>
    pub fun NFTCollectionData(): MetadataViews.NFTCollectionData
    pub fun MetadataViewsManagerPublic():
      Capability<
        &MetadataViewsManager.Manager{MetadataViewsManager.ManagerPublic}
      >

    pub fun mint(
      metadataAccessor: MutableSetManager.MetadataAccessor,
    ): @NonFungibleToken.NFT
    pub fun mintBulk(
      metadataAccessor: MutableSetManager.MetadataAccessor,
      numToMint: UInt64,
    ): @[NonFungibleToken.NFT]
  }

  //=========================================================================

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

  //=========================================================================

  pub resource RoyaltiesResolver: MetadataViewsManager.Resolver {
    pub let type: Type
    pub let royalties: MetadataViews.Royalties
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      return self.royalties
    }
    init(royalties: MetadataViews.Royalties) {
      self.type = Type<MetadataViews.Royalties>()
      self.royalties = royalties
    }
  } 

  pub fun createRoyaltiesResolver(royalties: MetadataViews.Royalties): @RoyaltiesResolver {
      return <-create RoyaltiesResolver(royalties: royalties)
  }

  pub resource NFTCollectionDataResolver: MetadataViewsManager.Resolver {
    pub let type: Type
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let nft = nftRef as! &{NFTPublic}
      return nft.NFTCollectionData()
    }
    init() {
      self.type = Type<MetadataViews.NFTCollectionData>()
    }
  } 

  pub fun createNFTCollectionDataResolver(): @NFTCollectionDataResolver {
      return <-create NFTCollectionDataResolver()
  }

  pub resource IpfsDisplayResolver: MetadataViewsManager.Resolver {
    pub let type: Type
    pub let titleField: String
    pub let descriptionField: String
    pub let ipfsImageField: String
    pub let defaultTitle: String
    pub let defaultDescription: String
    pub let defaultIpfsImage: String
    pub fun resolve(_ nftRef: AnyStruct): AnyStruct? {
      let nft = nftRef as! &{NFTPublic}
      let metadata = nft.metadata().get() as! &{String: String}
      let name = metadata[self.titleField] ?? self.defaultTitle
      let description = metadata[self.descriptionField]
        ?? self.defaultDescription
      let url = metadata[self.ipfsImageField] ?? self.defaultIpfsImage
      return MetadataViews.Display(
        name: name,
        description: description,
        thumbnail: MetadataViews.HTTPFile(url: url)
      )
    }

    init(
      titleField: String,
      descriptionField: String,
      ipfsImageField: String,
      defaultTitle: String,
      defaultDescription: String,
      defaultIpfsImage: String,
    ) {
      self.type = Type<MetadataViews.Display>()
      self.titleField = titleField
      self.descriptionField = descriptionField
      self.ipfsImageField = ipfsImageField
      self.defaultTitle = defaultTitle
      self.defaultDescription = defaultDescription
      self.defaultIpfsImage = defaultIpfsImage
    }
  }

  pub fun createIpfsDispayResolver(
    titleField: String,
    descriptionField: String,
    ipfsImageField: String,
    defaultTitle: String,
    defaultDescription: String,
    defaultIpfsImage: String,
  ): @IpfsDisplayResolver {
      return <-create IpfsDisplayResolver(
        titleField: titleField,
        descriptionField: descriptionField,
        ipfsImageField: ipfsImageField,
        defaultTitle: defaultTitle,
        defaultDescription: defaultDescription,
        defaultIpfsImage: defaultIpfsImage,
      )
  }
}