import MutableMetadata from "../../contracts/MutableMetadata.cdc"
import MutableSet from "../../contracts/MutableSet.cdc"
import MutableSetManager from "../../contracts/MutableSetManager.cdc"

import Niftory from "../../contracts/Niftory.cdc"
import NFTRegistry from "../../contracts/NFTRegistry.cdc"

transaction(
  setId: Int,
  templateId: Int,
  collectorAddress: Address,
  collectionPath: String,
  numToMint: UInt64
) {
  prepare(acct: AuthAccount) {
    let registry = getAccount(0x01cf0e2f2f715450).getCapability(
      NFTRegistry.StandardRegistryPublicPath
    ).borrow<&{NFTRegistry.RegistryPublic}>()!
    let nftBrandMetadata = registry.infoFor(brand: "ExampleNFT")

    let metadataAccessor = MutableSetManager.MetadataAccessor(
      setId: setId,
      templateId: templateId
    )
    let collectionPublicPath = PublicPath(identifier: collectionPath)!
    let collection = getAccount(collectorAddress)
      .getCapability(collectionPublicPath)
      .borrow<&{Niftory.CollectionPublic}>()!

    let minter = acct.getCapability<&{Niftory.ManagerPrivate}>(
      nftBrandMetadata.NftManagerPrivatePath
    ).borrow()!
    collection.depositBulk(
      tokens: <-minter.mintBulk(
        metadataAccessor: metadataAccessor, 
        numToMint: numToMint
      )
    )
  }
}