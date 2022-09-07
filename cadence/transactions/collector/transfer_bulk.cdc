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
  let receiverPath: PublicPath

  prepare(acct: AuthAccount) {
    let nftManager = NiftoryNFTRegistry
      .getNFTManagerPublic(registryAddress, brand)
    let paths = NiftoryNFTRegistry
      .getCollectionPaths(registryAddress, brand)
    let collection = acct
      .getCapability<&{NiftoryNonFungibleToken.CollectionPrivate}>(paths.private)
      .borrow()!
    self.nfts <- collection.withdrawBulk(withdrawIDs: ids)
    self.receiverPath = paths.public
  }

  execute {
    let recipientCollection = getAccount(recipientAddress)
      .getCapability<&{NiftoryNonFungibleToken.CollectionPublic}>(
        self.receiverPath
      ).borrow()!
    recipientCollection.depositBulk(tokens: <-self.nfts)
  }
}