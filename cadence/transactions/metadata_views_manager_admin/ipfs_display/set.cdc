import MetadataViewsManager from "../../../contracts/MetadataViewsManager.cdc"
import MetadataViews from "../../../contracts/MetadataViews.cdc"

import NiftoryNonFungibleToken from "../../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../../contracts/NiftoryNFTRegistry.cdc"
import NiftoryMetadataViewsResolvers from "../../../contracts/NiftoryMetadataViewsResolvers.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  nameField: String,
  defaultName: String,
  descriptionField: String,
  defaultDescription: String,
  imageField: String,
  defaultImagePrefix: String,
  defaultImage: String,
) {

  let nftManager: &{NiftoryNonFungibleToken.ManagerPrivate}

  prepare(acct: AuthAccount) {
    let record = NiftoryNFTRegistry.getRegistryRecord(registryAddress, brand)
    self.nftManager = acct
      .getCapability<&{NiftoryNonFungibleToken.ManagerPrivate}
      >(record.nftManager.paths.private)
      .borrow()!
  }

  execute {
    let resolver = NiftoryMetadataViewsResolvers.DisplayResolver(
      nameField: nameField,
      defaultName: defaultName,
      descriptionField: descriptionField,
      defaultDescription: defaultDescription,
      imageField: imageField,
      defaultImagePrefix: defaultImagePrefix,
      defaultImage: defaultImage,
    )

    self.nftManager.setMetadataViewsResolver(resolver)
  }
}
 