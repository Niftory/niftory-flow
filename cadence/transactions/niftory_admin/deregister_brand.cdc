import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(brand: String) {

  let registry: &{NiftoryNFTRegistry.Private}

  prepare(acct: AuthAccount) {

    let registryPrivatePath = NiftoryNFTRegistry.PRIVATE_PATH
    self.registry = acct
      .getCapability(registryPrivatePath)
      .borrow<&{NiftoryNFTRegistry.Private}>()!
  }

  execute {
    self.registry.deregister(brand)
  }
}