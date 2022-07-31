import FungibleToken from "../../contracts/FungibleToken.cdc"

import MetadataViewsManager from "../../contracts/MetadataViewsManager.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

import Niftory from "../../contracts/Niftory.cdc"
import NFTRegistry from "../../contracts/NFTRegistry.cdc"

transaction(
  metataViewsManagerPath: String,
  receiverAddress: Address,
  receiverPath: String,
  cut: UFix64,
  description: String
) {
  prepare(acct: AuthAccount) {
    let registry = getAccount(0x01cf0e2f2f715450).getCapability(
      NFTRegistry.StandardRegistryPublicPath
    ).borrow<&{NFTRegistry.RegistryPublic}>()!
    let nftBrandMetadata = registry.infoFor(brand: "ExampleNFT")

    let receiverPublicPath = PublicPath(identifier: receiverPath)!
    let receiver = getAccount(receiverAddress)
      .getCapability<&AnyResource{FungibleToken.Receiver}>(receiverPublicPath)
    let royalty = MetadataViews.Royalty(
        receiver: receiver,
        cut: cut,
        description: description
    )
    let resolver <- Niftory.createRoyaltiesResolver(
      royalties: MetadataViews.Royalties([royalty])
    )

    let metadataViewsPrivatePath = nftBrandMetadata.MetadataViewsPrivatePath
    let manager = acct.getCapability(metadataViewsPrivatePath)
      .borrow<
        &MetadataViewsManager.Manager{MetadataViewsManager.ManagerPrivate}
      >()!
    manager.addResolver(<-resolver)
  }
}