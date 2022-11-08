import MutableMetadata from "../../contracts/MutableMetadata.cdc"
import MutableMetadataSet from "../../contracts/MutableMetadataSet.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNonFungibleTokenProxy
  from "../../contracts/NiftoryNonFungibleTokenProxy.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  initialMetadata: {String: String}
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
    let mutableMetadata <- MutableMetadata.create(metadata: initialMetadata)
    let mutableSet <- MutableMetadataSet.create(metadata: <- mutableMetadata)
    self.nftManager.addSet(<-mutableSet)
  }
}