import MetadataViewsManager from "../../contracts/MetadataViewsManager.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

import Niftory from "../../contracts/Niftory.cdc"
import NFTRegistry from "../../contracts/NFTRegistry.cdc"

transaction(
  metataViewsManagerPath: String,
  titleField: String,
  descriptionField: String,
  ipfsImageField: String,
  defaultTitle: String,
  defaultDescription: String,
  defaultIpfsImage: String
) {
  prepare(acct: AuthAccount) {
    let registry = getAccount(0x01cf0e2f2f715450).getCapability(
      NFTRegistry.StandardRegistryPublicPath
    ).borrow<&{NFTRegistry.RegistryPublic}>()!
    let nftBrandMetadata = registry.infoFor(brand: "ExampleNFT")

    let resolver <- Niftory.createIpfsDispayResolver(
      titleField: titleField,
      descriptionField: descriptionField,
      ipfsImageField: ipfsImageField,
      defaultTitle: defaultTitle,
      defaultDescription: defaultDescription,
      defaultIpfsImage: defaultIpfsImage
    )

    let metadataViewsPrivatePath = nftBrandMetadata.MetadataViewsPrivatePath
    let manager = acct.getCapability(metadataViewsPrivatePath)
      .borrow<
        &MetadataViewsManager.Manager{MetadataViewsManager.ManagerPrivate}
      >()!
    manager.addResolver(<-resolver)
  }
}