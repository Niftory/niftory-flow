import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

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

pub fun main(registryAddress: Address, brand: String): SetManagerInfo {
  let manager = NiftoryNFTRegistry.getSetManagerPublic(registryAddress, brand)
  return SetManagerInfo(
    name: manager.name(),
    description: manager.description(),
    numSets: manager.numSets()
  )
}
