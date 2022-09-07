import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  setId: Int,
  templateId: Int,
  key: String,
  value: String
) {

  let nftManager: &{NiftoryNonFungibleToken.ManagerPrivate}

  prepare(acct: AuthAccount) {
    let record = NiftoryNFTRegistry.getRegistryRecord(registryAddress, brand)
    self.nftManager = acct
      .getCapability<&{NiftoryNonFungibleToken.ManagerPrivate}
      >(record.nftManager.paths.private)
      .borrow()!
  }

  execute {
    let metadataAuth = self.nftManager.modifyNFTMetadata(
      setId: setId, 
      templateId: templateId
    ) as! &{String: String}
    metadataAuth[key] = value
  }
}