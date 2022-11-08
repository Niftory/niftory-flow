import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(
  registryAddress: Address,
  brand: String
) {

  prepare(acct: AuthAccount) {
    let nftManager = NiftoryNFTRegistry
      .getNFTManagerPublic(registryAddress, brand)
    let paths = NiftoryNFTRegistry
      .getCollectionPaths(registryAddress, brand)
    let collection <- nftManager.getNFTCollectionData().createEmptyCollection()
    acct.save(<-collection, to: paths.storage)
    acct.link<&{
      NonFungibleToken.Receiver,
      NonFungibleToken.CollectionPublic,
      MetadataViews.ResolverCollection,
      NiftoryNonFungibleToken.CollectionPublic
    }>(paths.public, target: paths.storage)
    acct.link<&{
      NonFungibleToken.Provider,
      NiftoryNonFungibleToken.CollectionPrivate
    }>(paths.private, target: paths.storage)
  }
}
