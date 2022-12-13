import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  ids: [UInt64]
) {

  let nfts: @[NonFungibleToken.NFT]

  prepare(acct: AuthAccount) {
    let paths = NiftoryNFTRegistry
      .getCollectionPaths(registryAddress, brand)
    let collection = acct
      .getCapability<&{NiftoryNonFungibleToken.CollectionPrivate}>(paths.private)
      .borrow()!
    self.nfts <- collection.withdrawBulk(withdrawIDs: ids)
  }

  execute {
    destroy self.nfts
  }
}
