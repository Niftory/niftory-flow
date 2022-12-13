import NiftoryNonFungibleToken
  from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNonFungibleTokenProxy
  from "../../contracts/NiftoryNonFungibleTokenProxy.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  proxyAddress: Address
) {

  let nftManagerCap: Capability<&{
    NiftoryNonFungibleToken.ManagerPrivate,
    NiftoryNonFungibleToken.ManagerPublic
  }>

  prepare(acct: AuthAccount) {
    let record = NiftoryNFTRegistry.getRegistryRecord(registryAddress, brand)
    self.nftManagerCap = acct
      .getCapability<&{
        NiftoryNonFungibleToken.ManagerPrivate,
        NiftoryNonFungibleToken.ManagerPublic
      }
      >(record.nftManager.paths.private)
  }

  execute {
    let proxy = getAccount(proxyAddress)
      .getCapability<&{NiftoryNonFungibleTokenProxy.Public}>(
        NiftoryNonFungibleTokenProxy.PUBLIC_PATH
      )
      .borrow() ?? panic("Could not borrow proxy")
    proxy.add(
      registryAddress: registryAddress,
      brand: brand,
      cap: self.nftManagerCap
    )
  }
}
