import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNonFungibleTokenProxy
  from "../../contracts/NiftoryNonFungibleTokenProxy.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  newMetadata: {String: String}
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
    self.nftManager.replaceContractMetadata(newMetadata)
  }
}
