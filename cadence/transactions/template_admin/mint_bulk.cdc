import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  setId: Int,
  templateId: Int,
  collectorAddress: Address,
  numToMint: UInt64
) {

  let collectionPublicPath: PublicPath
  let nftManager: &{NiftoryNonFungibleToken.ManagerPrivate}

  prepare(acct: AuthAccount) {
    let record = NiftoryNFTRegistry.getRegistryRecord(registryAddress, brand)
    self.collectionPublicPath = record.collectionPaths.public
    self.nftManager = acct
      .getCapability<&{NiftoryNonFungibleToken.ManagerPrivate}
      >(record.nftManager.paths.private)
      .borrow()!
  }

  execute {
    let collection = getAccount(collectorAddress)
      .getCapability(self.collectionPublicPath)
      .borrow<&{NiftoryNonFungibleToken.CollectionPublic}>()!
    let nfts <- self.nftManager.mintBulk(
      setId: setId,
      templateId: templateId,
      numToMint: numToMint
    )
    collection.depositBulk(tokens: <-nfts)
  }
}