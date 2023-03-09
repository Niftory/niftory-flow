import FungibleToken from "../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"
import NiftoryNonFungibleTokenProxy
  from "../../contracts/NiftoryNonFungibleTokenProxy.cdc"

// Static params - change these to customize the transaction
let EXPECTED_MERCHANT_ACCOUNT_ADDRESS: Address = 0x01
let REGISTRY_ADDRESS: Address = 0x02
let BRAND: String = "fdsa"
let FORWARDER_RECEIVER_PATH: PublicPath = /public/dapperUtilityCoinReceiver
let DAPPER_STORAGE_PATH: StoragePath = /storage/dapperUtilityCoinVault

transaction(
  merchantAccountAddress: Address,
  nftId: UInt64?,
  setId: Int?,
  templateId: Int?,
  price: UFix64
) {
  // Niftory app assets
  let nftManager:
    &{NiftoryNonFungibleToken.ManagerPublic,
      NiftoryNonFungibleToken.ManagerPrivate
    }
  let nftProvider: Capability<&{
    NonFungibleToken.Provider,
    NonFungibleToken.CollectionPublic
  }>
  let niftoryAppPaymentReceiver: Capability<&{FungibleToken.Receiver}>

  // Dapper assets
  let mainUtilityCoinVault: &FungibleToken.Vault
  let balanceBeforeTransfer: UFix64
  let paymentVault: @FungibleToken.Vault

  // Buyer assets
  let buyerCollection: &{NonFungibleToken.Receiver}

  prepare(
    niftoryApp: AuthAccount,
    dapper: AuthAccount,
    buyer: AuthAccount
  ) {
    // Get the NFT manager for the app
    self.nftManager = niftoryApp
      .getCapability<&{
        NiftoryNonFungibleTokenProxy.Private,
        NiftoryNonFungibleTokenProxy.Public
      }>(
        NiftoryNonFungibleTokenProxy.PRIVATE_PATH
      ).borrow()!.access(
        registryAddress: REGISTRY_ADDRESS,
        brand: BRAND
      )
    let appCollectionPaths = NiftoryNFTRegistry
      .getCollectionPaths(REGISTRY_ADDRESS, BRAND)

    // Get the NFT provider from the app storage account
    self.nftProvider = niftoryApp.getCapability<&{
      NonFungibleToken.Provider,
      NonFungibleToken.CollectionPublic
    }>(appCollectionPaths.private)

    // Get the token forwarder for the merchant account associated with this app
    let merchantAccount = getAccount(merchantAccountAddress)
    self.niftoryAppPaymentReceiver = merchantAccount
      .getCapability<&{FungibleToken.Receiver}>(FORWARDER_RECEIVER_PATH)

    // Withdraw the token payment from the Dapper vault
    self.mainUtilityCoinVault = dapper.borrow<&FungibleToken.Vault>(
      from: DAPPER_STORAGE_PATH
    )
      ?? panic("Cannot borrow UtilityCoin vault from account storage")
    self.balanceBeforeTransfer = self.mainUtilityCoinVault.balance
    self.paymentVault <- self.mainUtilityCoinVault.withdraw(
      amount: price
    )

    // Create a collection for the buyer if they don't have one
    if buyer.borrow<&NonFungibleToken.Collection>(
      from: appCollectionPaths.storage
    ) == nil {
      let collection <- NiftoryNFTRegistry
        .getNFTManagerPublic(REGISTRY_ADDRESS, BRAND)
        .getNFTCollectionData()
        .createEmptyCollection()
      buyer.save(<-collection, to: appCollectionPaths.storage)
    }

    if (buyer.getCapability
      <&{
        NonFungibleToken.Receiver,
        NonFungibleToken.CollectionPublic,
        MetadataViews.ResolverCollection,
        NiftoryNonFungibleToken.CollectionPublic
      }>(appCollectionPaths.public).borrow() == nil)
    {
      buyer.unlink(appCollectionPaths.public)
      buyer.link
        <&{
          NonFungibleToken.Receiver,
          NonFungibleToken.CollectionPublic,
          MetadataViews.ResolverCollection,
          NiftoryNonFungibleToken.CollectionPublic
        }>(
          appCollectionPaths.public,
          target: appCollectionPaths.storage
        )
    }

    if (buyer.getCapability
      <&{
        NonFungibleToken.Provider,
        NonFungibleToken.CollectionPublic,
        MetadataViews.ResolverCollection,
        NiftoryNonFungibleToken.CollectionPrivate,
        NiftoryNonFungibleToken.CollectionPublic
      }>(
        appCollectionPaths.private
      ).borrow() == nil)
    {
      buyer.unlink(appCollectionPaths.private)
      buyer.link
        <&{
          NonFungibleToken.Provider,
          NonFungibleToken.CollectionPublic,
          MetadataViews.ResolverCollection,
          NiftoryNonFungibleToken.CollectionPrivate,
          NiftoryNonFungibleToken.CollectionPublic
        }>(
          appCollectionPaths.private,
          target: appCollectionPaths.storage
        )
    }

    // Get the collection from the buyer so the NFT can be deposited into it
    self.buyerCollection = buyer.borrow
      <&{NonFungibleToken.Receiver}>(
        from: appCollectionPaths.storage
      ) ?? panic("Cannot borrow NFT collection receiver from account")
  }

  pre {
    self.niftoryAppPaymentReceiver.check()
      : "Missing or mis-typed UtilityCoin receiver"

    merchantAccountAddress == EXPECTED_MERCHANT_ACCOUNT_ADDRESS:
      "Merchant account address does not match expected address"

    (nftId == nil && setId != nil && templateId != nil)
      || (nftId != nil)
      : "Either nftId or (setId and templateId) must be provided"
  }

  execute {

    // Retrieve the NFT to give to the buyer
    var nft: @NonFungibleToken.NFT? <- nil

    if nftId != nil {
      // If the nft has been pre-minted, withdraw it from the apps's collection
      nft <-! self.nftProvider.borrow()!.withdraw(withdrawID: nftId!)
    } else {
      // Else, mint it from the nft manager
      nft <-! self.nftManager.mint(setId: setId!, templateId: templateId!)
    }

    // Deposit the NFT into the buyer's collection
    self.buyerCollection.deposit(token: <-nft!)

    // Deposit the payment into the seller token forwarder
    self.niftoryAppPaymentReceiver.borrow()!.deposit(from: <-self.paymentVault)
  }

  // Check that all utilityCoin was routed back to Dapper
  post {
    self.mainUtilityCoinVault.balance ==
      self.balanceBeforeTransfer: "UtilityCoin leakage"
  }
}
