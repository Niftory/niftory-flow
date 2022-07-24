import MutableSetManager from "../../contracts/MutableSetManager.cdc"

transaction(path: String, description: String) {
  prepare(acct: AuthAccount) {
    let privatePath = PrivatePath(identifier: path)!
    let manager = acct.getCapability(privatePath)
      .borrow<&{MutableSetManager.ManagerPrivate}>()!
    manager.setDescription(description)
  }
}