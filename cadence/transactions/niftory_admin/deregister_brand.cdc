import NFTRegistry from "../../contracts/NFTRegistry.cdc"

transaction(brand: String) {
  prepare(acct: AuthAccount) {
    let RegistryPrivatePath = NFTRegistry.StandardRegistryPrivatePath
    let registry = acct
      .getCapability(RegistryPrivatePath)
      .borrow<&{NFTRegistry.RegistryPrivate}>()!

    registry.deregister(
      brand: brand
    )
  }
}