import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  recipientAddress: Address,
  ids: [UInt64]
) {

  let nfts: @[NonFungibleToken.NFT]
  let paths: NiftoryNFTRegistry.Paths

  prepare(acct: AuthAccount) {
    self.paths = NiftoryNFTRegistry
      .getCollectionPaths(registryAddress, brand)
    let collection = acct
      .getCapability<&{
        NiftoryNonFungibleToken.CollectionPublic,
        NiftoryNonFungibleToken.CollectionPrivate
      }>(self.paths.private)
      .borrow()!
    self.nfts <- collection.withdrawBulk(withdrawIDs: ids)
  }

  execute {
    let recipientCollection = getAccount(recipientAddress)
      .getCapability<&{NiftoryNonFungibleToken.CollectionPublic}>(
        self.paths.public
      ).borrow()!
    recipientCollection.depositBulk(tokens: <-self.nfts)
  }
}
