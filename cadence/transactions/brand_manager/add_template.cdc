import MutableMetadata from "../../contracts/MutableMetadata.cdc"
import MutableMetadataTemplate from "../../contracts/MutableMetadataTemplate.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNonFungibleTokenProxy
  from "../../contracts/NiftoryNonFungibleTokenProxy.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  setId: Int,
  initialMetadata: {String: String},
  maxMint: UInt64?
) {

  let nftManager: &{NiftoryNonFungibleToken.ManagerPrivate}

  prepare(acct: AuthAccount) {
    self.nftManager = acct
      .getCapability<&{
        NiftoryNonFungibleTokenProxy.Private,
        NiftoryNonFungibleTokenProxy.Public
      }>(
        NiftoryNonFungibleTokenProxy.PRIVATE_PATH
      ).borrow()!.access(
        registryAddress: registryAddress,
        brand: brand
      )
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