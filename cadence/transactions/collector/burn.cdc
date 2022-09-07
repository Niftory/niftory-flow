import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  id: UInt64
) {

  prepare(acct: AuthAccount) {
    let nftManager = NiftoryNFTRegistry
      .getNFTManagerPublic(registryAddress, brand)
    let paths = NiftoryNFTRegistry
      .getCollectionPaths(registryAddress, brand)
    let collection = acct
      .getCapability<&{NiftoryNonFungibleToken.CollectionPrivate}>(paths.private)
      .borrow()!
    destroy collection.withdraw(withdrawID: id)
  }
}