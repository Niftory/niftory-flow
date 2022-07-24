import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"
import Niftory from "../../contracts/Niftory.cdc"

import XXTEMPLATEXX from "../../contracts/XXTEMPLATEXX.cdc"

transaction() {
  prepare(acct: AuthAccount) {
    let collection <- XXTEMPLATEXX.createEmptyCollection()
    let storagePath = XXTEMPLATEXX.CollectionPath
    let publicPath = XXTEMPLATEXX.CollectionPublicPath
    let privatePath = XXTEMPLATEXX.CollectionPrivatePath
    acct.save(<-collection, to: storagePath)
    acct.link<&{
      NonFungibleToken.Receiver,
      NonFungibleToken.CollectionPublic,
      MetadataViews.ResolverCollection,
      Niftory.CollectionPublic
    }>(publicPath, target: storagePath)
    acct.link<&{
      NonFungibleToken.Provider,
      Niftory.CollectionPrivate
    }>(privatePath, target: storagePath)
  }
}