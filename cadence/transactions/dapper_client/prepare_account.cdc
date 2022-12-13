import FungibleToken from "../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

import NFTStorefrontV2 from "../../contracts/NFTStorefrontV2.cdc"
import TokenForwarding from "../../contracts/TokenForwarding.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"
import NiftoryMetadataViewsResolvers from "../../contracts/NiftoryMetadataViewsResolvers.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  dapperAddress: Address
) {

  let nftManager:
    &{NiftoryNonFungibleToken.ManagerPublic,
      NiftoryNonFungibleToken.ManagerPrivate
    }

  prepare(niftory: AuthAccount) {

    /////////////////
    // NFT Manager //
    /////////////////

    let record = NiftoryNFTRegistry.getRegistryRecord(registryAddress, brand)
    self.nftManager = niftory
      .getCapability<&{
        NiftoryNonFungibleToken.ManagerPublic,
        NiftoryNonFungibleToken.ManagerPrivate
      }>(record.nftManager.paths.private)
      .borrow()!

    ////////////////
    // Collection //
    ////////////////

    let paths = NiftoryNFTRegistry
      .getCollectionPaths(registryAddress, brand)

    if niftory.borrow<&NonFungibleToken.Collection>(
      from: paths.storage
    ) == nil {
      let collection <- self.nftManager
        .getNFTCollectionData()
        .createEmptyCollection()
      niftory.save(<-collection, to: paths.storage)
    }

    if (niftory.getCapability
      <&{
        NonFungibleToken.Receiver,
        NonFungibleToken.CollectionPublic,
        MetadataViews.ResolverCollection,
        NiftoryNonFungibleToken.CollectionPublic
      }>(paths.public).borrow() == nil)
    {
      niftory.unlink(paths.public)
      niftory.link
        <&{
          NonFungibleToken.Receiver,
          NonFungibleToken.CollectionPublic,
          MetadataViews.ResolverCollection,
          NiftoryNonFungibleToken.CollectionPublic
        }>(
          paths.public,
          target: paths.storage
        )
    }

    if (niftory.getCapability
      <&{
        NonFungibleToken.Provider,
        NonFungibleToken.CollectionPublic,
        MetadataViews.ResolverCollection,
        NiftoryNonFungibleToken.CollectionPrivate,
        NiftoryNonFungibleToken.CollectionPublic
      }>(
        paths.private
      ).borrow() == nil)
    {
      niftory.unlink(paths.private)
      niftory.link
        <&{
          NonFungibleToken.Provider,
          NonFungibleToken.CollectionPublic,
          MetadataViews.ResolverCollection,
          NiftoryNonFungibleToken.CollectionPrivate,
          NiftoryNonFungibleToken.CollectionPublic
        }>(
          paths.private,
          target: paths.storage
        )
    }

    ////////////////
    // Storefront //
    ////////////////

    if niftory.borrow<&NFTStorefrontV2.Storefront>(
      from: NFTStorefrontV2.StorefrontStoragePath
    ) == nil {
      let storefront <- NFTStorefrontV2.createStorefront()
      niftory.save(<-storefront, to: NFTStorefrontV2.StorefrontStoragePath)
      niftory.link<&NFTStorefrontV2.Storefront{NFTStorefrontV2.StorefrontPublic}>(
        NFTStorefrontV2.StorefrontPublicPath,
        target: NFTStorefrontV2.StorefrontStoragePath
      )
    }

    /////////////////////////////
    // Dapper Token Forwarding //
    /////////////////////////////

    if niftory.borrow<&TokenForwarding.Forwarder>(
      from: /storage/dapperUtilityCoinReceiver
    ) == nil {
      let dapper = getAccount(dapperAddress)
      let receiver = dapper.getCapability(
        /public/dapperUtilityCoinReceiver
      )
      let forwarder <- TokenForwarding.createNewForwarder(
        recipient: receiver
      )
      niftory.save(
        <-forwarder,
        to: /storage/dapperUtilityCoinReceiver
      )
      niftory.link<&{FungibleToken.Receiver}>(
        /public/dapperUtilityCoinReceiver,
        target: /storage/dapperUtilityCoinReceiver
      )
    }

    if niftory.borrow<&TokenForwarding.Forwarder>(
      from: /storage/flowUtilityTokenReceiver
    ) == nil {
      let dapper = getAccount(dapperAddress)
      let receiver = dapper.getCapability(
        /public/flowUtilityTokenReceiver
      )
      let forwarder <- TokenForwarding.createNewForwarder(
        recipient: receiver
      )
      niftory.save(
        <-forwarder,
        to: /storage/flowUtilityTokenReceiver
      )
      niftory.link<&{FungibleToken.Receiver}>(
        /public/flowUtilityTokenReceiver,
        target: /storage/flowUtilityTokenReceiver
      )
    }
  }

  execute {

    //////////////
    // Defaults //
    //////////////

    let DEFAULT_DOMAIN = "https://niftory.com"
    let DEFAULT_DISPLAY = "ipfs://bafybeig6la3me5x3veull7jzxmwle4sfuaguou2is3o3z44ayhe7ihlqpa/NiftoryBanner.png"
    let DEFAULT_BANNER = "ipfs://bafybeig6la3me5x3veull7jzxmwle4sfuaguou2is3o3z44ayhe7ihlqpa/NiftoryBanner.png"
    let DEFAULT_SQ_IMG = "ipfs://bafybeihc76uodw2at2xi2l5jydpvscj5ophfpqgblbrmsfpeffhcmgdtl4/squareImage.png"

    //////////////////////////
    // Info we already have //
    //////////////////////////

    let setManager = self.nftManager.getSetManagerPublic()
    let implViews = self.nftManager.getMetadataViewsManagerPublic().getViews()
    let viewsSet: {Type: Bool} = {}
    for view in implViews {
      viewsSet[view] = true
    }
    let contractName = setManager.name()

    //////////////////////////
    // MetadataViewsManager //
    //////////////////////////

    // Royalties
    if viewsSet[Type<MetadataViews.Royalties>()] == nil {
      let royaltiesResolver = NiftoryMetadataViewsResolvers.RoyaltiesResolver(
          royalties: MetadataViews.Royalties([])
      )
      self.nftManager.setMetadataViewsResolver(royaltiesResolver)
    }

    // Collection Data
    if viewsSet[Type<MetadataViews.NFTCollectionData>()] == nil {
      let collectionDataResolver
          = NiftoryMetadataViewsResolvers.NFTCollectionDataResolver()
      self.nftManager.setMetadataViewsResolver(collectionDataResolver)
    }

    // Display
    if viewsSet[Type<MetadataViews.Display>()] == nil {
      let displayResolver = NiftoryMetadataViewsResolvers.DisplayResolver(
          "title",
          contractName.concat("NFT"),
          "description",
          contractName.concat(" NFT"),
          "mediaUrl",
          "ipfs://",
          DEFAULT_DISPLAY
      )
      self.nftManager.setMetadataViewsResolver(displayResolver)
    }

    // Collection Display
    if viewsSet[Type<MetadataViews.NFTCollectionDisplay>()] == nil {
      let collectionResolver = NiftoryMetadataViewsResolvers.NFTCollectionDisplayResolver(
          "title",
          contractName,
          "description",
          contractName.concat(" Collection"),
          "domainUrl",
          "https://",
          DEFAULT_DOMAIN,
          "squareImage",
          "ipfs://",
          DEFAULT_SQ_IMG,
          "squareImageMediaType",
          "image/png",
          "bannerImage",
          "ipfs://",
          DEFAULT_BANNER,
          "bannerImageMediaType",
          "image/png",
          []
      )
      self.nftManager.setMetadataViewsResolver(collectionResolver)
    }

    // ExternalURL
    if viewsSet[Type<MetadataViews.ExternalURL>()] == nil {
      let externalURLResolver = NiftoryMetadataViewsResolvers.ExternalURLResolver(
          "domainUrl",
          "https://",
          DEFAULT_DOMAIN
      )
      self.nftManager.setMetadataViewsResolver(externalURLResolver)
    }
  }
}
 