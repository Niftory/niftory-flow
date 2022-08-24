import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

pub fun main(registryAddress: Address): {String: NiftoryNFTRegistry.Record} {
    let RegistryPublicPath = 
      NiftoryNFTRegistry.PUBLIC_PATH
    let registry = getAccount(registryAddress)
      .getCapability(RegistryPublicPath)
      .borrow<&{NiftoryNFTRegistry.Public}>()!
    return registry.all()
}
