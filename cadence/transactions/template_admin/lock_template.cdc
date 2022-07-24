import MutableSetManager from "../../contracts/MutableSetManager.cdc"

transaction(path: String, setId: Int, templateId: Int) {
  prepare(acct: AuthAccount) {
    let privatePath = PrivatePath(identifier: path)!
    let manager = acct.getCapability(privatePath)
      .borrow<&{MutableSetManager.ManagerPrivate}>()!
    let set = manager.getAuth(setId)
    let template = set.getAuth(templateId)
    template.lock()
  }
}