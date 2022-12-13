import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNonFungibleTokenProxy
  from "../../contracts/NiftoryNonFungibleTokenProxy.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  key: String
) {

  let nftManager: &{NiftoryNonFungibleToken.ManagerPrivate}

  prepare(signer: AuthAccount) {
    self.nftManager = signer
      .getCapability<&{
        NiftoryNonFungibleTokenProxy.Private,
        NiftoryNonFungibleTokenProxy.Public
      }>(
        NiftoryNonFungibleTokenProxy.PRIVATE_PATH
      ).borrow()!.access(
        registryAddress: registryAddress,
        brand: brand
      )
  }

  execute {
    let metadataAuth = self.nftManager.modifyContractMetadata()
      as! &{String: String}
    metadataAuth.remove(key: key)
  }
}
