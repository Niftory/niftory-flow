import MutableMetadata from "../../contracts/MutableMetadata.cdc"
import MutableMetadataTemplate from "../../contracts/MutableMetadataTemplate.cdc"
import MutableSetManager from "../../contracts/MutableSetManager.cdc"

transaction(managerPath: String, setId: Int, initialMetadata: {String: String}, maxMint: UInt64?) {
  prepare(acct: AuthAccount) {
    let managerPrivatePath = PrivatePath(identifier: managerPath)!
    let mutableMetadata <- MutableMetadata.createMetadata(metadata: initialMetadata)
    let mutableTemplate <- MutableMetadataTemplate.createTemplate(
      metadata: <-mutableMetadata,
      maxMint: maxMint
    )
    let manager = acct.getCapability(managerPrivatePath)
      .borrow<&{MutableSetManager.ManagerPrivate}>()!
    let set = manager.getAuth(setId)
    set.addTemplate(<-mutableTemplate)
  }
}