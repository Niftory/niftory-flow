import NFTRegistry from "../../contracts/NFTRegistry.cdc"

pub fun main(registryAddress: Address): {String: NFTRegistry.RegistryItem} {
    let RegistryPublicPath = NFTRegistry.StandardRegistryPublicPath
    let registry = getAccount(registryAddress)
      .getCapability(RegistryPublicPath)
      .borrow<&{NFTRegistry.RegistryPublic}>()!
    return registry.all()
}
