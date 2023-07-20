import FungibleToken from "../../contracts/FungibleToken.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"
import NiftoryMetadataViewsResolvers from "../../contracts/NiftoryMetadataViewsResolvers.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  ipfsGateway: String,
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

    let contractName = "Gamisodes"

    // Royalties
    let royaltiesResolver = NiftoryMetadataViewsResolvers.RoyaltiesResolver(
        royalties: MetadataViews.Royalties([])
    )
    self.nftManager.setMetadataViewsResolver(royaltiesResolver)

    // Collection Data
    let collectionDataResolver
      = NiftoryMetadataViewsResolvers.NFTCollectionDataResolver()
    self.nftManager.setMetadataViewsResolver(collectionDataResolver)

    // Display
    let displayResolver = NiftoryMetadataViewsResolvers.DisplayResolverWithIpfsGateway(
        ["title"],
        contractName.concat("NFT"),
        ["description"],
        contractName.concat(" NFT"),
        ["posterUrl", "mediaUrl"],
        "ipfs://",
        "ipfs://bafybeibe5njsqkslexfkxziudveq66yr45nomu72qrby6moru63ma2gvbq/Badge_Purple.png",
        "https://cloudflare-ipfs.com/ipfs/"
    )
    self.nftManager.setMetadataViewsResolver(displayResolver)

    // Collection Display
    let collectionResolver = NiftoryMetadataViewsResolvers.NFTCollectionDisplayResolverWithIpfsGateway(
      ["title"],
      contractName,
      ["description"],
      contractName.concat(" Collection"),
      ["domainUrl"],
      "https://",
      "https://gamisodes.com",
      ["squareImage"],
      "ipfs://",
      "ipfs://bafybeic6gt52p7tcg3uxpjlfnyre5rbmm2ahq2lkjriifwgnbjrcggr5rq/Dapper%20Banner.jpg",
      "squareImageMediaType",
      "image/png",
      ["bannerImage"],
      "ipfs://",
      "ipfs://bafybeibe5njsqkslexfkxziudveq66yr45nomu72qrby6moru63ma2gvbq/Badge_Purple.png",
      "bannerImageMediaType",
      "image/png",
      [],
      "https://cloudflare-ipfs.com/ipfs/"
    )
    self.nftManager.setMetadataViewsResolver(collectionResolver)

    // ExternalURL
    let externalURLResolver = NiftoryMetadataViewsResolvers.ExternalURLResolver(
      "domainUrl",
      "https://",
      "https://gamisodes.com"
    )
    self.nftManager.setMetadataViewsResolver(externalURLResolver)

    // Serial
    let newSerialResolver = NiftoryMetadataViewsResolvers.SerialResolver()
    self.nftManager.setMetadataViewsResolver(newSerialResolver)
  }
}
