import MutableMetadata from "../../contracts/MutableMetadata.cdc"
import MutableMetadataTemplate from "../../contracts/MutableMetadataTemplate.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  setId: Int,
  initialMetadata: {String: String},
  maxMint: UInt64?
) {

  let nftManager: &{NiftoryNonFungibleToken.ManagerPrivate}

  prepare(acct: AuthAccount) {
    let record = NiftoryNFTRegistry.getRegistryRecord(registryAddress, brand)
    self.nftManager = acct
      .getCapability<&{NiftoryNonFungibleToken.ManagerPrivate}
      >(record.nftManager.paths.private)
      .borrow()!
  }

  execute {
    let metadata <- MutableMetadata.create(metadata: initialMetadata)
    let template <- MutableMetadataTemplate.create(
      metadata: <-metadata,
      maxMint: maxMint
    )
    self.nftManager.addTemplate(setId: setId, template: <-template)
  }
}