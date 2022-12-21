import FungibleToken from "../../contracts/FungibleToken.cdc"
import FungibleTokenSwitchboard from "../../contracts/FungibleTokenSwitchboard.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

import TokenForwarding from "../../contracts/TokenForwarding.cdc"
import FiatToken from "../../contracts/FiatToken.cdc"
import OnChainMultiSig from "../../contracts/OnChainMultiSig.cdc"
import FUSD from "../../contracts/FUSD.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"
import NiftoryMetadataViewsResolvers from "../../contracts/NiftoryMetadataViewsResolvers.cdc"


transaction(
  registryAddress: Address,
  brand: String,
  // Royalties
  royaltyReceiverAddresses: [Address],
  royaltyCuts: [UFix64],
  royaltyDescriptions: [String],
  // Collection Data (there's nothing)
  // Display
  nftNameField: String,
  nftDefaultName: String,
  nftDescriptionField: String,
  nftDefaultDescription: String,
  nftImageFields: [String],
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
  // Ipfs gateway
  ipfsGateway: String,
  // Dapper address
  dapperAddressMaybe: Address?
) {

  let nftManager: &{NiftoryNonFungibleToken.ManagerPublic, NiftoryNonFungibleToken.ManagerPrivate}

  prepare(acct: AuthAccount) {
    // get nft manager
    let record = NiftoryNFTRegistry.getRegistryRecord(registryAddress, brand)
    self.nftManager = acct
      .getCapability<&{NiftoryNonFungibleToken.ManagerPublic, NiftoryNonFungibleToken.ManagerPrivate}
      >(record.nftManager.paths.private)
      .borrow()!

    // intialize vaults, if not existing

    // Flow - assume it's initialized

    // FUSD
    if(acct.borrow<&FUSD.Vault>(from: /storage/fusdVault) == nil) {
      acct.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
      acct.link<&FUSD.Vault{FungibleToken.Receiver}>(
        /public/fusdReceiver,
        target: /storage/fusdVault
      )
      acct.link<&FUSD.Vault{FungibleToken.Balance}>(
        /public/fusdBalance,
        target: /storage/fusdVault
      )
    }

    // USDC
    if acct.borrow<&FiatToken.Vault>(from: FiatToken.VaultStoragePath) == nil {
      acct.save(
        <-FiatToken.createEmptyVault(),
        to: FiatToken.VaultStoragePath
      )
      acct.link<&FiatToken.Vault{FungibleToken.Receiver}>(
        FiatToken.VaultReceiverPubPath,
        target: FiatToken.VaultStoragePath
      )
      acct.link<&FiatToken.Vault{FiatToken.ResourceId}>(
        FiatToken.VaultUUIDPubPath,
        target: FiatToken.VaultStoragePath
      )
      acct.link<&FiatToken.Vault{FungibleToken.Balance}>(
        FiatToken.VaultBalancePubPath,
        target: FiatToken.VaultStoragePath
      )
    }

    // DUC
    if acct.borrow<&TokenForwarding.Forwarder>(
      from: /storage/dapperUtilityCoinReceiver
    ) == nil {
      if let dapperAddress = dapperAddressMaybe {
        let dapper = getAccount(dapperAddress)
        let receiver = dapper.getCapability(
          /public/dapperUtilityCoinReceiver
        )
        let forwarder <- TokenForwarding.createNewForwarder(
          recipient: receiver
        )
        acct.save(
          <-forwarder,
          to: /storage/dapperUtilityCoinReceiver
        )
        acct.link<&{FungibleToken.Receiver}>(
          /public/dapperUtilityCoinReceiver,
          target: /storage/dapperUtilityCoinReceiver
        )
      }
    }

    // FUT
    if acct.borrow<&TokenForwarding.Forwarder>(
      from: /storage/flowUtilityTokenReceiver
    ) == nil {
      if let dapperAddress = dapperAddressMaybe {
        let dapper = getAccount(dapperAddress)
        let receiver = dapper.getCapability(
          /public/flowUtilityTokenReceiver
        )
        let forwarder <- TokenForwarding.createNewForwarder(
          recipient: receiver
        )
        acct.save(
          <-forwarder,
          to: /storage/flowUtilityTokenReceiver
        )
        acct.link<&{FungibleToken.Receiver}>(
          /public/flowUtilityTokenReceiver,
          target: /storage/flowUtilityTokenReceiver
        )
      }
    }

    // initialize switchboard, if not existing
    if acct.borrow<&FungibleTokenSwitchboard.Switchboard>(
      from: FungibleTokenSwitchboard.StoragePath
    ) == nil {
      let switchboard <- FungibleTokenSwitchboard.createSwitchboard()
      acct.save(<-switchboard, to: FungibleTokenSwitchboard.StoragePath)
      acct.link<&FungibleTokenSwitchboard.Switchboard{FungibleToken.Receiver}>(
        FungibleTokenSwitchboard.ReceiverPublicPath,
        target: FungibleTokenSwitchboard.StoragePath
      )
      acct.link<&FungibleTokenSwitchboard.Switchboard{FungibleTokenSwitchboard.SwitchboardPublic, FungibleToken.Receiver}>(
          FungibleTokenSwitchboard.PublicPath,
          target: FungibleTokenSwitchboard.StoragePath
      )
    }
  }

  execute {

    // Royalties
    let royalties: [MetadataViews.Royalty] = []
    for i, address  in royaltyReceiverAddresses {
      let receiverPublicPath = FungibleTokenSwitchboard.PublicPath
      let receiver = getAccount(royaltyReceiverAddresses[i])
        .getCapability<&AnyResource{FungibleToken.Receiver}>(receiverPublicPath)
      let royalty = MetadataViews.Royalty(
          receiver: receiver,
          cut: royaltyCuts[i],
          description: royaltyDescriptions[i]
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
    let displayResolver = NiftoryMetadataViewsResolvers.DisplayResolverWithIpfsGateway(
      [nftNameField],
      nftDefaultName,
      [nftDescriptionField],
      nftDefaultDescription,
      nftImageFields,
      nftDefaultImagePrefix,
      nftDefaultImage,
      ipfsGateway
    )
    self.nftManager.setMetadataViewsResolver(displayResolver)

    // Collection Display
    let collectionResolver = NiftoryMetadataViewsResolvers.NFTCollectionDisplayResolverWithIpfsGateway(
      [colNameField],
      colDefaultName,
      [colDescriptionField],
      colDefaultDescription,
      [colExternalUrlField],
      colDefaultExternalURLPrefix,
      colDefaultExternalURL,
      [colSquareImageField],
      colDefaultSquareImagePrefix,
      colDefaultSquareImage,
      colSquareImageMediaTypeField,
      colDefaultSquareImageMediaType,
      [colBannerImageField],
      colDefaultBannerImagePrefix,
      colDefaultBannerImage,
      colBannerImageMediaTypeField,
      colDefaultBannerImageMediaType,
      colSocialsFields,
      ipfsGateway
    )
    self.nftManager.setMetadataViewsResolver(collectionResolver)

    // ExternalURL
    let externalURLResolver = NiftoryMetadataViewsResolvers.ExternalURLResolver(
      urlField,
      urlDefaultPrefix,
      urlDefault,
    )
    self.nftManager.setMetadataViewsResolver(collectionResolver)

    // Serial
    let newSerialResolver = NiftoryMetadataViewsResolvers.SerialResolver()
    self.nftManager.setMetadataViewsResolver(newSerialResolver)
  }
}
