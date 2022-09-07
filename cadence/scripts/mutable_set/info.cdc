import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

pub struct SetInfo {
  pub let locked: Bool
  pub let metadataLocked: Bool
  pub let numTemplates: Int
  pub let metadata: AnyStruct
  init(locked: Bool, metadataLocked: Bool, numTemplates: Int, metadata: AnyStruct) {
    self.locked = locked
    self.metadataLocked = metadataLocked
    self.numTemplates = numTemplates
    self.metadata = metadata
  }
}

pub fun main(registryAddress: Address, brand: String, setId: Int): SetInfo {
  let manager = NiftoryNFTRegistry.getSetManagerPublic(registryAddress, brand)
  let set = manager.getSet(setId)
  return SetInfo(
    locked: set.locked(),
    metadataLocked: set.metadata().locked(),
    numTemplates: set.numTemplates(),
    metadata: set.metadata().get()
  )
}