import NFTRegistry from "../../contracts/NFTRegistry.cdc"

transaction() {
  prepare(acct: AuthAccount) {
    let registry <- NFTRegistry.newRegistry()

    let storagePath = NFTRegistry.StandardRegistryPath
    let publicPath = NFTRegistry.StandardRegistryPublicPath
    let privatePath = NFTRegistry.StandardRegistryPrivatePath

    acct.save(<-registry, to: storagePath)
    acct.link<&{
      NFTRegistry.RegistryPublic
    }>(publicPath, target: storagePath)
    acct.link<&{
      NFTRegistry.RegistryPrivate
    }>(privatePath, target: storagePath)
  }
}