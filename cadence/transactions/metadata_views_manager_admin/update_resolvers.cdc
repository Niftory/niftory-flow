import FungibleToken from "../../contracts/FungibleToken.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"
import NiftoryMetadataViewsResolvers from "../../contracts/NiftoryMetadataViewsResolvers.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  ipfsGateway: String
) {

  let nftManager: &{NiftoryNonFungibleToken.ManagerPublic, NiftoryNonFungibleToken.ManagerPrivate}

  prepare(acct: AuthAccount) {
    let record = NiftoryNFTRegistry.getRegistryRecord(registryAddress, brand)
    self.nftManager = acct
      .getCapability<&{NiftoryNonFungibleToken.ManagerPublic, NiftoryNonFungibleToken.ManagerPrivate}
      >(record.nftManager.paths.private)
      .borrow()!
  }

  execute {

    let manager = NiftoryNFTRegistry.getMetadataViewsManagerPublic(
      registryAddress,
      brand
    )

    // NFT Display
    let displayViewType = Type<MetadataViews.Display>()
    let obsoleteDisplayResolverType = Type<NiftoryMetadataViewsResolvers.DisplayResolver>()
    let maybeOldDisplayResolver = manager
      .inspectView(view: displayViewType)

    if maybeOldDisplayResolver != nil
      && maybeOldDisplayResolver!.getType().isSubtype(of: obsoleteDisplayResolverType)
    {
      let oldDisplayResolver = maybeOldDisplayResolver!
        as! NiftoryMetadataViewsResolvers.DisplayResolver
      let newDisplayResolver = NiftoryMetadataViewsResolvers.DisplayResolverWithIpfsGateway(
        [oldDisplayResolver.nameField],
        oldDisplayResolver.defaultName,
        [oldDisplayResolver.descriptionField],
        oldDisplayResolver.defaultDescription,
        ["posterUrl", "mediaUrl"],
        oldDisplayResolver.defaultImagePrefix,
        oldDisplayResolver.defaultImage,
        ipfsGateway,
      )
      self.nftManager.setMetadataViewsResolver(newDisplayResolver)
    }

    // Royalties
    // TODO

    // NFT Collection Display
    let nftCollectionDisplayViewType = Type<MetadataViews.NFTCollectionDisplay>()
    let obsoleteNftCollectionDisplayResolverType
      = Type<NiftoryMetadataViewsResolvers.NFTCollectionDisplayResolver>()
    let maybeOldNftCollectionDisplayResolver = manager
      .inspectView(view: nftCollectionDisplayViewType)

    if maybeOldNftCollectionDisplayResolver != nil
      && maybeOldNftCollectionDisplayResolver!.getType().isSubtype(of: obsoleteNftCollectionDisplayResolverType)
    {
      let oldNftCollectionDisplayResolver = maybeOldNftCollectionDisplayResolver!
        as! NiftoryMetadataViewsResolvers.NFTCollectionDisplayResolver
      let newNftCollectionDisplayResolver = NiftoryMetadataViewsResolvers.NFTCollectionDisplayResolverWithIpfsGateway(
        [oldNftCollectionDisplayResolver.nameField],
        oldNftCollectionDisplayResolver.defaultName,
        [oldNftCollectionDisplayResolver.descriptionField],
        oldNftCollectionDisplayResolver.defaultDescription,
        [oldNftCollectionDisplayResolver.externalUrlField],
        oldNftCollectionDisplayResolver.defaultExternalURLPrefix,
        oldNftCollectionDisplayResolver.defaultExternalURL,
        [oldNftCollectionDisplayResolver.squareImageField],
        oldNftCollectionDisplayResolver.defaultSquareImagePrefix,
        oldNftCollectionDisplayResolver.defaultSquareImage,
        oldNftCollectionDisplayResolver.squareImageMediaTypeField,
        oldNftCollectionDisplayResolver.defaultSquareImageMediaType,
        [oldNftCollectionDisplayResolver.bannerImageField],
        oldNftCollectionDisplayResolver.defaultBannerImagePrefix,
        oldNftCollectionDisplayResolver.defaultBannerImage,
        oldNftCollectionDisplayResolver.bannerImageMediaTypeField,
        oldNftCollectionDisplayResolver.defaultBannerImageMediaType,
        oldNftCollectionDisplayResolver.socialsFields,
        ipfsGateway,
      )
      self.nftManager.setMetadataViewsResolver(newNftCollectionDisplayResolver)
    }

    // Serial
    let newSerialResolver = NiftoryMetadataViewsResolvers.SerialResolver()
    self.nftManager.setMetadataViewsResolver(newSerialResolver)
  }
}
