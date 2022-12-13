import FungibleToken from "../../contracts/FungibleToken.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"
import NiftoryMetadataViewsResolvers from "../../contracts/NiftoryMetadataViewsResolvers.cdc"

transaction(
  registryAddress: Address,
  brand: String,
  // Royalties
  royaltyReceiverAddress: Address?,
  royaltyReceiverPath: String?,
  royaltyCut: UFix64?,
  royaltyDescription: String?,
  // Collection Data (there's nothing)
  // Display
  nftNameField: String,
  nftDefaultName: String,
  nftDescriptionField: String,
  nftDefaultDescription: String,
  nftImageField: String,
  nftDefaultImagePrefix: String,
  nftDefaultImage: String,
  // Collection Display
  colNameField: String,
  colDefaultName: String,
  colDescriptionField: String,
  colDefaultDescription: String,
  colExternalUrlField: String,
  colDefaultExternalURLPrefix: String,
  colDefaultExternalURL: String,
  colSquareImageField: String,
  colDefaultSquareImagePrefix: String,
  colDefaultSquareImage: String,
  colSquareImageMediaTypeField: String,
  colDefaultSquareImageMediaType: String,
  colBannerImageField: String,
  colDefaultBannerImagePrefix: String,
  colDefaultBannerImage: String,
  colBannerImageMediaTypeField: String,
  colDefaultBannerImageMediaType: String,
  colSocialsFields: [String],
  // ExternalURL
  urlField: String,
  urlDefaultPrefix: String,
  urlDefault: String,
) {

  let nftManager: &{NiftoryNonFungibleToken.ManagerPublic, NiftoryNonFungibleToken.ManagerPrivate}

  prepare(acct: AuthAccount) {
    let record = NiftoryNFTRegistry.getRegistryRecord(registryAddress, brand)
    self.nftManager = acct
      .getCapability<&{NiftoryNonFungibleToken.ManagerPublic, NiftoryNonFungibleToken.ManagerPrivate}
      >(record.nftManager.paths.private)
      .borrow()!
  }

  execute {

    // Royalties
    let royalties: [MetadataViews.Royalty] = []
    if royaltyReceiverPath == nil {
      let receiverPublicPath = PublicPath(identifier: royaltyReceiverPath!)!
      let receiver = getAccount(royaltyReceiverAddress!)
        .getCapability<&AnyResource{FungibleToken.Receiver}>(receiverPublicPath)
      let royalty = MetadataViews.Royalty(
          receiver: receiver,
          cut: royaltyCut!,
          description: royaltyDescription!
      )
      royalties.append(royalty)
    }
    let royaltiesResolver = NiftoryMetadataViewsResolvers.RoyaltiesResolver(
      royalties: MetadataViews.Royalties(royalties)
    )
    self.nftManager.setMetadataViewsResolver(royaltiesResolver)

    // Collection Data
    let collectionDataResolver
      = NiftoryMetadataViewsResolvers.NFTCollectionDataResolver()
    self.nftManager.setMetadataViewsResolver(collectionDataResolver)

    // Display
    let displayResolver = NiftoryMetadataViewsResolvers.DisplayResolver(
      nftNameField,
      nftDefaultName,
      nftDescriptionField,
      nftDefaultDescription,
      nftImageField,
      nftDefaultImagePrefix,
      nftDefaultImage
    )
    self.nftManager.setMetadataViewsResolver(displayResolver)

    // Collection Display
    let collectionResolver = NiftoryMetadataViewsResolvers.NFTCollectionDisplayResolver(
      colNameField,
      colDefaultName,
      colDescriptionField,
      colDefaultDescription,
      colExternalUrlField,
      colDefaultExternalURLPrefix,
      colDefaultExternalURL,
      colSquareImageField,
      colDefaultSquareImagePrefix,
      colDefaultSquareImage,
      colSquareImageMediaTypeField,
      colDefaultSquareImageMediaType,
      colBannerImageField,
      colDefaultBannerImagePrefix,
      colDefaultBannerImage,
      colBannerImageMediaTypeField,
      colDefaultBannerImageMediaType,
      colSocialsFields,
    )
    self.nftManager.setMetadataViewsResolver(collectionResolver)

    // ExternalURL
    let externalURLResolver = NiftoryMetadataViewsResolvers.ExternalURLResolver(
      urlField,
      urlDefaultPrefix,
      urlDefault,
    )
    self.nftManager.setMetadataViewsResolver(collectionResolver)
  }
}
