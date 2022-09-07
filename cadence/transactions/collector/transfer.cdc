import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  recipientAddress: Address,
  id: UInt64
) {

  let nft: @NonFungibleToken.NFT
  let receiverPath: PublicPath

  prepare(acct: AuthAccount) {
    let nftManager = NiftoryNFTRegistry
      .getNFTManagerPublic(registryAddress, brand)
    let paths = NiftoryNFTRegistry
      .getCollectionPaths(registryAddress, brand)
    let collection = acct
      .getCapability<&{NiftoryNonFungibleToken.CollectionPrivate}>(paths.private)
      .borrow()!
    self.nft <- collection.withdraw(withdrawID: id)
    self.receiverPath = paths.public
  }

  execute {
    let recipientCollection = getAccount(recipientAddress)
      .getCapability<&{NiftoryNonFungibleToken.CollectionPublic}>(
        self.receiverPath
      ).borrow()!
    recipientCollection.deposit(token: <-self.nft)
  }
}