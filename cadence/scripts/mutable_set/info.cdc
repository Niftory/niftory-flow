import MutableSetManager from "../../contracts/MutableSetManager.cdc"

pub struct SetInfo {
  pub let locked: Bool
  pub let metadataLocked: Bool
  pub let numTemplates: Int
  pub let metadata: {String: String}
  init(locked: Bool, metadataLocked: Bool, numTemplates: Int, metadata: {String: String}) {
    self.locked = locked
    self.metadataLocked = metadataLocked
    self.numTemplates = numTemplates
    self.metadata = metadata
  }
}

pub fun main(address: Address, path: String, setId: Int): SetInfo {
  let publicPath = PublicPath(identifier: path)!
  let manager = getAccount(address)
    .getCapability(publicPath)
    .borrow<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>()!
  let set = manager.get(setId)
  return SetInfo(
    locked: set.locked(),
    metadataLocked: set.metadata().locked(),
    numTemplates: set.numTemplates(),
    metadata: set.metadata().all()
  )
}