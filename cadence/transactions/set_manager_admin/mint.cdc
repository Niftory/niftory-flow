import MutableMetadata from "../../contracts/MutableMetadata.cdc"
import MutableSet from "../../contracts/MutableSet.cdc"
import MutableSetManager from "../../contracts/MutableSetManager.cdc"

import Niftory from "../../contracts/Niftory.cdc"

transaction(setId: Int, templateId: Int, collectorAddress: Address, collectionPath: String) {
  prepare(acct: AuthAccount) {
    let metadataAccessor = MutableSetManager.MetadataAccessor(
      setId: setId,
      templateId: templateId
    )
    let collectionPublicPath = PublicPath(identifier: collectionPath)!
    let collection = getAccount(collectorAddress)
      .getCapability(collectionPublicPath)
      .borrow<&{Niftory.CollectionPublic}>()!

    let minter = acct.getCapability<&{Niftory.MinterPrivate}>(
      Niftory.StandardMinterPrivatePath
    ).borrow()!
    collection.deposit(token: <-minter.mint(metadataAccessor: metadataAccessor))
  }
}