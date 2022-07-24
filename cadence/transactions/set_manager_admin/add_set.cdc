import MutableMetadata from "../../contracts/MutableMetadata.cdc"
import MutableSet from "../../contracts/MutableSet.cdc"
import MutableSetManager from "../../contracts/MutableSetManager.cdc"

transaction(path: String, initialMetadata: {String: String}) {
  prepare(acct: AuthAccount) {
    let privatePath = PrivatePath(identifier: path)!
    let mutableMetadata <- MutableMetadata.createMetadata(metadata: initialMetadata)
    let mutableSet <- MutableSet.createSet( metadata: <- mutableMetadata)
    let manager = acct.getCapability(privatePath)
      .borrow<&{MutableSetManager.ManagerPrivate}>()!
    manager.addMutableSet(<- mutableSet)
  }
}