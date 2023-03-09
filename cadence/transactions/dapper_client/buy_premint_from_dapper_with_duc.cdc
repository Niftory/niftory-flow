import FungibleToken from "../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

import NiftoryNonFungibleToken from "../../contracts/NiftoryNonFungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"
import NiftoryNonFungibleTokenProxy
  from "../../contracts/NiftoryNonFungibleTokenProxy.cdc"

import NiftoryTemplate from "../../contracts/NiftoryTemplate.cdc"

transaction(
  merchantAccountAddress: Address,
  nftId: UInt64,
  price: UFix64
) {

  // Static params - change these to customize the transaction
  let EXPECTED_MERCHANT_ACCOUNT_ADDRESS: Address
  let REGISTRY_ADDRESS: Address
  let BRAND: String
  let FORWARDER_RECEIVER_PATH: PublicPath
  let DAPPER_STORAGE_PATH: StoragePath

  // Niftory app assets
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

    // Params
    self.EXPECTED_MERCHANT_ACCOUNT_ADDRESS = 0x1
    self.REGISTRY_ADDRESS = 0x2
    self.BRAND = "fdsa"
    self.FORWARDER_RECEIVER_PATH = /public/dapperUtilityCoinReceiver
    self.DAPPER_STORAGE_PATH = /storage/dapperUtilityCoinVault

    // Get the NFT Collection Paths
    let appCollectionPaths = NiftoryNFTRegistry
      .getCollectionPaths(self.REGISTRY_ADDRESS, self.BRAND)

    // Get the NFT provider from the app storage account
    self.nftProvider = niftoryApp.getCapability<&{
      NonFungibleToken.Provider,
      NonFungibleToken.CollectionPublic
    }>(appCollectionPaths.private)

    // Get the DUC forwarder for the merchant account associated with this app
    let merchantAccount = getAccount(merchantAccountAddress)
    self.niftoryAppPaymentReceiver = merchantAccount
      .getCapability<&{FungibleToken.Receiver}>(self.FORWARDER_RECEIVER_PATH)

    // Withdraw the DUC payment from the Dapper vault
    self.mainUtilityCoinVault = dapper.borrow<&FungibleToken.Vault>(
      from: self.DAPPER_STORAGE_PATH
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
      let collection <- NiftoryTemplate
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

    merchantAccountAddress == self.EXPECTED_MERCHANT_ACCOUNT_ADDRESS:
      "Merchant account address does not match expected address"
  }

  execute {

    // Retrieve the NFT to give to the buyer
    var nft <- self.nftProvider.borrow()!.withdraw(withdrawID: nftId)

    // Deposit the NFT into the buyer's collection
    self.buyerCollection.deposit(token: <-nft)

    // Deposit the payment into the seller DUC forwarder
    self.niftoryAppPaymentReceiver.borrow()!.deposit(from: <-self.paymentVault)
  }

  // Check that all utilityCoin was routed back to Dapper
  post {
    self.mainUtilityCoinVault.balance ==
      self.balanceBeforeTransfer: "UtilityCoin leakage"
  }
}
