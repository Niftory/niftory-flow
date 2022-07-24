import MutableSetManager from "../../contracts/MutableSetManager.cdc"

pub struct SetManagerInfo {
  pub let name: String
  pub let description: String
  pub let numSets: Int
  init(name: String, description: String, numSets: Int) {
    self.name = name
    self.description = description
    self.numSets = numSets
  }
}

pub fun main(address: Address, path: String): SetManagerInfo {
  let publicPath = PublicPath(identifier: path)!
  let manager = getAccount(address)
    .getCapability(publicPath)
    .borrow<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>()!
  return SetManagerInfo(
    name: manager.name(),
    description: manager.description(),
    numSets: manager.numSets()
  )
}