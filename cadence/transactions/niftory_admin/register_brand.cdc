import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(contractAddress: Address, brand: String) {

  let registry: &{NiftoryNFTRegistry.Private}

  prepare(acct: AuthAccount) {

    let registryPrivatePath = NiftoryNFTRegistry.PRIVATE_PATH
    self.registry = acct
      .getCapability(registryPrivatePath)
      .borrow<&{NiftoryNFTRegistry.Private}>()!
  }

  execute {

    let record = NiftoryNFTRegistry.generateRecord(
      account: contractAddress,
      project: brand
    )

    self.registry.register(
      brand: brand,
      entry: record
    )
  }
}