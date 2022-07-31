import MutableSetManager from "../../contracts/MutableSetManager.cdc"

pub struct TemplateInfo {
  pub let locked: Bool
  pub let metadataLocked: Bool
  pub let metadata: AnyStruct
  pub let maxMint: UInt64?
  pub let minted: UInt64
  init(locked: Bool, metadataLocked: Bool, metadata: AnyStruct, maxMint: UInt64?, minted: UInt64) {
    self.locked = locked
    self.metadataLocked = metadataLocked
    self.metadata = metadata
    self.maxMint = maxMint
    self.minted = minted
  }
}

pub fun main(address: Address, path: String, setId: Int, templateId: Int): TemplateInfo {
  let publicPath = PublicPath(identifier: path)!
  let manager = getAccount(address)
    .getCapability(publicPath)
    .borrow<&MutableSetManager.Manager{MutableSetManager.ManagerPublic}>()!
  let set = manager.get(setId)
  let template = set.get(templateId)

  return TemplateInfo(
    locked: template.locked(),
    metadataLocked: template.metadata().locked(),
    metadata: template.metadata().get(),
    maxMint: template.maxMint(),
    minted: template.minted()
  )
}