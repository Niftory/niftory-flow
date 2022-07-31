import NFTRegistry from "../../contracts/NFTRegistry.cdc"

transaction(brand: String) {
  prepare(acct: AuthAccount) {

    let CollectionPublicPath = PublicPath(identifier: brand.concat("_collection"))!
    let CollectionPrivatePath = PrivatePath(identifier: brand.concat("_collection"))!
    let CollectionPath = StoragePath(identifier: brand.concat("_collection"))!

    let NftManagerPublicPath = PublicPath(identifier: brand.concat("_nftmanager"))!
    let NftManagerPrivatePath = PrivatePath(identifier: brand.concat("_nftmanager"))!
    let NftManagerPath = StoragePath(identifier: brand.concat("_nftmanager"))!

    let SetManagerPublicPath = PublicPath(identifier: brand.concat("_setmanager"))!
    let SetManagerPrivatePath = PrivatePath(identifier: brand.concat("_setmanager"))!
    let SetManagerPath = StoragePath(identifier: brand.concat("_setmanager"))!

    let MetadataViewsPublicPath = PublicPath(
      identifier: brand.concat("_metadataviews")
    )!
    let MetadataViewsPrivatePath = PrivatePath(
      identifier: brand.concat("_metadataviews")
    )!
    let MetadataViewsPath = StoragePath(identifier: brand.concat("_metadataviews"))!
    
    let registryItem = NFTRegistry.RegistryItem(
      CollectionPublicPath: CollectionPublicPath,
      CollectionPrivatePath: CollectionPrivatePath,
      CollectionPath: CollectionPath,
      NftManagerPublicPath: NftManagerPublicPath,
      NftManagerPrivatePath: NftManagerPrivatePath,
      NftManagerPath: NftManagerPath,
      SetManagerPublicPath: SetManagerPublicPath,
      SetManagerPrivatePath: SetManagerPrivatePath,
      SetManagerPath: SetManagerPath,
      MetadataViewsPublicPath: MetadataViewsPublicPath,
      MetadataViewsPrivatePath: MetadataViewsPrivatePath,
      MetadataViewsPath: MetadataViewsPath
    )

    let RegistryPrivatePath = NFTRegistry.StandardRegistryPrivatePath
    let registry = acct
      .getCapability(RegistryPrivatePath)
      .borrow<&{NFTRegistry.RegistryPrivate}>()!

    registry.register(
      brand: brand,
      entry: registryItem
    )
  }
}