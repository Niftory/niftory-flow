
import MutableSetManager from "../../contracts/MutableSetManager.cdc"

transaction(path: String, setId: Int) {
  prepare(acct: AuthAccount) {
    let privatePath = PrivatePath(identifier: path)!
    let manager = acct.getCapability(privatePath)
      .borrow<&{MutableSetManager.ManagerPrivate}>()!
    let set = manager.getAuth(setId)
    set.lock()
  }
}