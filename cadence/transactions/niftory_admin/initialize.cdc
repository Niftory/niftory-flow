import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction() {
  prepare(acct: AuthAccount) {
    let registry <- NiftoryNFTRegistry.create()

    let storagePath = NiftoryNFTRegistry.STORAGE_PATH
    let publicPath = NiftoryNFTRegistry.PUBLIC_PATH
    let privatePath = NiftoryNFTRegistry.PRIVATE_PATH

    acct.save(<-registry, to: storagePath)
    acct.link<&{
      NiftoryNFTRegistry.Public
    }>(publicPath, target: storagePath)
    acct.link<&{
      NiftoryNFTRegistry.Public,
      NiftoryNFTRegistry.Private
    }>(privatePath, target: storagePath)
  }
}