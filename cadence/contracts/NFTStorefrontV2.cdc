import FungibleToken from "./FungibleToken.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

pub contract NFTStorefrontV2 {

    pub event StorefrontInitialized(storefrontResourceID: UInt64)

    pub event StorefrontDestroyed(storefrontResourceID: UInt64)

    pub event ListingAvailable(
        storefrontAddress: Address,
        listingResourceID: UInt64,
        nftType: Type,
        nftUUID: UInt64, 
        nftID: UInt64,
        salePaymentVaultType: Type,
        salePrice: UFix64,
        customID: String?,
        commissionAmount: UFix64,
        commissionReceivers: [Address]?,
        expiry: UInt64
    )

    pub event ListingCompleted(
        listingResourceID: UInt64, 
        storefrontResourceID: UInt64, 
        purchased: Bool,
        nftType: Type,
        nftUUID: UInt64,
        nftID: UInt64,
        salePaymentVaultType: Type,
        salePrice: UFix64,
        customID: String?,
        commissionAmount: UFix64,
        commissionReceiver: Address?,
        expiry: UInt64
    )

    pub event UnpaidReceiver(receiver: Address, entitledSaleCut: UFix64)

    pub let StorefrontStoragePath: StoragePath

    pub let StorefrontPublicPath: PublicPath


    pub struct SaleCut {
        pub let receiver: Capability<&{FungibleToken.Receiver}>

        pub let amount: UFix64

        init(receiver: Capability<&{FungibleToken.Receiver}>, amount: UFix64) {
            self.receiver = receiver
            self.amount = amount
        }
    }


    pub struct ListingDetails {
        pub var storefrontID: UInt64
        pub var purchased: Bool
        pub let nftType: Type
        pub let nftUUID: UInt64
        pub let nftID: UInt64
        pub let salePaymentVaultType: Type
        pub let salePrice: UFix64
        pub let saleCuts: [SaleCut]
        pub var customID: String?
        pub let commissionAmount: UFix64
        pub let expiry: UInt64

        access(contract) fun setToPurchased() {
            self.purchased = true
        }

        access(contract) fun setCustomID(customID: String?){
            self.customID = customID
        }

        init (
            nftType: Type,
            nftUUID: UInt64,
            nftID: UInt64,
            salePaymentVaultType: Type,
            saleCuts: [SaleCut],
            storefrontID: UInt64,
            customID: String?,
            commissionAmount: UFix64,
            expiry: UInt64
        ) {

            pre {
                expiry > UInt64(getCurrentBlock().timestamp) : "Expiry should be in the future"
                saleCuts.length > 0: "Listing must have at least one payment cut recipient"
            }
            self.storefrontID = storefrontID
            self.purchased = false
            self.nftType = nftType
            self.nftUUID = nftUUID
            self.nftID = nftID
            self.salePaymentVaultType = salePaymentVaultType
            self.customID = customID
            self.commissionAmount = commissionAmount
            self.expiry = expiry
            self.saleCuts = saleCuts

            var salePrice = commissionAmount
            for cut in self.saleCuts {
                cut.receiver.borrow()
                    ?? panic("Cannot borrow receiver")
                salePrice = salePrice + cut.amount
            }
            assert(salePrice > 0.0, message: "Listing must have non-zero price")

            self.salePrice = salePrice
        }
    }


    pub resource interface ListingPublic {
        pub fun borrowNFT(): &NonFungibleToken.NFT?

        pub fun purchase(
            payment: @FungibleToken.Vault, 
            commissionRecipient: Capability<&{FungibleToken.Receiver}>?,
        ): @NonFungibleToken.NFT

        pub fun getDetails(): ListingDetails

        pub fun getAllowedCommissionReceivers(): [Capability<&{FungibleToken.Receiver}>]?

    }


    pub resource Listing: ListingPublic {
        access(self) let details: ListingDetails

        access(contract) let nftProviderCapability: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>

        access(contract) let marketplacesCapability: [Capability<&{FungibleToken.Receiver}>]?

        pub fun borrowNFT(): &NonFungibleToken.NFT? {
            let ref = self.nftProviderCapability.borrow()!.borrowNFT(id: self.details.nftID)
            if ref.isInstance(self.details.nftType) && ref.id == self.details.nftID {
                return ref as! &NonFungibleToken.NFT  
            } 
            return nil
        }

        pub fun getDetails(): ListingDetails {
            return self.details
        }

        pub fun getAllowedCommissionReceivers(): [Capability<&{FungibleToken.Receiver}>]? {
            return self.marketplacesCapability
        }

        pub fun purchase(
            payment: @FungibleToken.Vault, 
            commissionRecipient: Capability<&{FungibleToken.Receiver}>?,
        ): @NonFungibleToken.NFT {

            pre {
                self.details.purchased == false: "listing has already been purchased"
                payment.isInstance(self.details.salePaymentVaultType): "payment vault is not requested fungible token"
                payment.balance == self.details.salePrice: "payment vault does not contain requested price"
                self.details.expiry > UInt64(getCurrentBlock().timestamp): "Listing is expired"
                self.owner != nil : "Resource doesn't have the assigned owner"
            }
            self.details.setToPurchased() 
            
            if self.details.commissionAmount > 0.0 {
                let commissionReceiver = commissionRecipient ?? panic("Commission recipient can't be nil")
                if self.marketplacesCapability != nil {
                    var isCommissionRecipientHasValidType = false
                    var isCommissionRecipientAuthorised = false
                    for cap in self.marketplacesCapability! {
                        if cap.getType() == commissionReceiver.getType() {
                            isCommissionRecipientHasValidType = true
                            if cap.address == commissionReceiver.address && cap.check() {
                                isCommissionRecipientAuthorised = true
                                break
                            }
                        }
                    }
                    assert(isCommissionRecipientHasValidType, message: "Given recipient does not has valid type")
                    assert(isCommissionRecipientAuthorised,   message: "Given recipient has not authorised to receive the commission")
                }
                let commissionPayment <- payment.withdraw(amount: self.details.commissionAmount)
                let recipient = commissionReceiver.borrow() ?? panic("Unable to borrow the recipent capability")
                recipient.deposit(from: <- commissionPayment)
            }
            let nft <-self.nftProviderCapability.borrow()!.withdraw(withdrawID: self.details.nftID)
            assert(nft.isInstance(self.details.nftType), message: "withdrawn NFT is not of specified type")
            assert(nft.id == self.details.nftID, message: "withdrawn NFT does not have specified ID")

            let storeFrontPublicRef = self.owner!.getCapability<&NFTStorefrontV2.Storefront{NFTStorefrontV2.StorefrontPublic}>(NFTStorefrontV2.StorefrontPublicPath)
                                        .borrow() ?? panic("Unable to borrow the storeFrontManager resource")
            let duplicateListings = storeFrontPublicRef.getDuplicateListingIDs(nftType: self.details.nftType, nftID: self.details.nftID, listingID: self.uuid)

            for listingID in duplicateListings {
                storeFrontPublicRef.cleanup(listingResourceID: listingID)
            }

            var residualReceiver: &{FungibleToken.Receiver}? = nil

            for cut in self.details.saleCuts {
                if let receiver = cut.receiver.borrow() {
                   let paymentCut <- payment.withdraw(amount: cut.amount)
                    receiver.deposit(from: <-paymentCut)
                    if (residualReceiver == nil) {
                        residualReceiver = receiver
                    }
                } else {
                    emit UnpaidReceiver(receiver: cut.receiver.address, entitledSaleCut: cut.amount)
                }
            }

            assert(residualReceiver != nil, message: "No valid payment receivers")

            residualReceiver!.deposit(from: <-payment)


            emit ListingCompleted(
                listingResourceID: self.uuid,
                storefrontResourceID: self.details.storefrontID,
                purchased: self.details.purchased,
                nftType: self.details.nftType,
                nftUUID: self.details.nftUUID,
                nftID: self.details.nftID,
                salePaymentVaultType: self.details.salePaymentVaultType,
                salePrice: self.details.salePrice,
                customID: self.details.customID,
                commissionAmount: self.details.commissionAmount,
                commissionReceiver: self.details.commissionAmount != 0.0 ? commissionRecipient!.address : nil,
                expiry: self.details.expiry
            )

            return <-nft
        }

        destroy () {
            if !self.details.purchased {
                emit ListingCompleted(
                    listingResourceID: self.uuid,
                    storefrontResourceID: self.details.storefrontID,
                    purchased: self.details.purchased,
                    nftType: self.details.nftType,
                    nftUUID: self.details.nftUUID,
                    nftID: self.details.nftID,
                    salePaymentVaultType: self.details.salePaymentVaultType,
                    salePrice: self.details.salePrice,
                    customID: self.details.customID,
                    commissionAmount: self.details.commissionAmount,
                    commissionReceiver: nil,
                    expiry: self.details.expiry
                )
            }
        }

        init (
            nftProviderCapability: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>,
            nftType: Type,
            nftUUID: UInt64,
            nftID: UInt64,
            salePaymentVaultType: Type,
            saleCuts: [SaleCut],
            marketplacesCapability: [Capability<&{FungibleToken.Receiver}>]?,
            storefrontID: UInt64,
            customID: String?,
            commissionAmount: UFix64,
            expiry: UInt64
        ) {
            self.details = ListingDetails(
                nftType: nftType,
                nftUUID: nftUUID,
                nftID: nftID,
                salePaymentVaultType: salePaymentVaultType,
                saleCuts: saleCuts,
                storefrontID: storefrontID,
                customID: customID,
                commissionAmount: commissionAmount,
                expiry: expiry
            )

            self.nftProviderCapability = nftProviderCapability
            self.marketplacesCapability = marketplacesCapability

            let provider = self.nftProviderCapability.borrow()
            assert(provider != nil, message: "cannot borrow nftProviderCapability")

            let nft = provider!.borrowNFT(id: self.details.nftID)
            assert(nft.isInstance(self.details.nftType), message: "token is not of specified type")
            assert(nft.id == self.details.nftID, message: "token does not have specified ID")
        }
    }

    pub resource interface StorefrontManager {
        pub fun createListing(
            nftProviderCapability: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>,
            nftType: Type,
            nftID: UInt64,
            salePaymentVaultType: Type,
            saleCuts: [SaleCut],
            marketplacesCapability: [Capability<&{FungibleToken.Receiver}>]?,
            customID: String?,
            commissionAmount: UFix64,
            expiry: UInt64
        ): UInt64

        pub fun removeListing(listingResourceID: UInt64)
    }

    pub resource interface StorefrontPublic {
        pub fun getListingIDs(): [UInt64]
        pub fun getDuplicateListingIDs(nftType: Type, nftID: UInt64, listingID: UInt64): [UInt64]
        pub fun borrowListing(listingResourceID: UInt64): &Listing{ListingPublic}?
        pub fun cleanupExpiredListings(fromIndex: UInt64, toIndex: UInt64)
        access(contract) fun cleanup(listingResourceID: UInt64)
        pub fun getExistingListingIDs(nftType: Type, nftID: UInt64): [UInt64]
        pub fun cleanupPurchasedListings(listingResourceID: UInt64)
   }

    pub resource Storefront : StorefrontManager, StorefrontPublic {
        access(contract) var listings: @{UInt64: Listing}
        access(contract) var listedNFTs: {String: {UInt64 : [UInt64]}}

         pub fun createListing(
            nftProviderCapability: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>,
            nftType: Type,
            nftID: UInt64,
            salePaymentVaultType: Type,
            saleCuts: [SaleCut],
            marketplacesCapability: [Capability<&{FungibleToken.Receiver}>]?,
            customID: String?,
            commissionAmount: UFix64,
            expiry: UInt64
         ): UInt64 {
            
            let collectionRef = nftProviderCapability.borrow()
                ?? panic("Could not borrow reference to collection")
            let nftRef = collectionRef.borrowNFT(id: nftID)

            let uuid = nftRef.uuid
            let listing <- create Listing(
                nftProviderCapability: nftProviderCapability,
                nftType: nftType,
                nftUUID: uuid,
                nftID: nftID,
                salePaymentVaultType: salePaymentVaultType,
                saleCuts: saleCuts,
                marketplacesCapability: marketplacesCapability,
                storefrontID: self.uuid,
                customID: customID,
                commissionAmount: commissionAmount,
                expiry: expiry
            )
        
            let listingResourceID = listing.uuid
            let listingPrice = listing.getDetails().salePrice
            let oldListing <- self.listings[listingResourceID] <- listing

            destroy oldListing

            self.addDuplicateListing(nftIdentifier: nftType.identifier, nftID: nftID, listingResourceID: listingResourceID)

            var allowedCommissionReceivers : [Address]? = nil
            if let allowedReceivers = marketplacesCapability {
                allowedCommissionReceivers = []
                for receiver in allowedReceivers {
                    allowedCommissionReceivers!.append(receiver.address)
                }
            }

            emit ListingAvailable(
                storefrontAddress: self.owner?.address!,
                listingResourceID: listingResourceID,
                nftType: nftType,
                nftUUID: uuid,
                nftID: nftID,
                salePaymentVaultType: salePaymentVaultType,
                salePrice: listingPrice,
                customID: customID,
                commissionAmount: commissionAmount,
                commissionReceivers: allowedCommissionReceivers,
                expiry: expiry
            )

            return listingResourceID
        }

        access(contract) fun addDuplicateListing(nftIdentifier: String, nftID: UInt64, listingResourceID: UInt64) {
             if !self.listedNFTs.containsKey(nftIdentifier) {
                self.listedNFTs.insert(key: nftIdentifier, {nftID: [listingResourceID]})
            } else {
                if !self.listedNFTs[nftIdentifier]!.containsKey(nftID) {
                    self.listedNFTs[nftIdentifier]!.insert(key: nftID, [listingResourceID])
                } else {
                    self.listedNFTs[nftIdentifier]![nftID]!.append(listingResourceID)
                } 
            }
        }

        access(contract) fun removeDuplicateListing(nftIdentifier: String, nftID: UInt64, listingResourceID: UInt64) {
            let listingIndex = self.listedNFTs[nftIdentifier]![nftID]!.firstIndex(of: listingResourceID) ?? panic("Should contain the index")
            self.listedNFTs[nftIdentifier]![nftID]!.remove(at: listingIndex)
        }
        
        pub fun removeListing(listingResourceID: UInt64) {
            let listing <- self.listings.remove(key: listingResourceID)
                ?? panic("missing Listing")
            let listingDetails = listing.getDetails()
            self.removeDuplicateListing(nftIdentifier: listingDetails.nftType.identifier, nftID: listingDetails.nftID, listingResourceID: listingResourceID)
            destroy listing
        }

        pub fun getListingIDs(): [UInt64] {
            return self.listings.keys
        }

        pub fun getExistingListingIDs(nftType: Type, nftID: UInt64): [UInt64] {
            if self.listedNFTs[nftType.identifier] == nil || self.listedNFTs[nftType.identifier]![nftID] == nil {
                return []
            }
            var listingIDs = self.listedNFTs[nftType.identifier]![nftID]!
            return listingIDs
        }

        pub fun cleanupPurchasedListings(listingResourceID: UInt64) {
            pre {
                self.listings[listingResourceID] != nil: "could not find listing with given id"
                self.borrowListing(listingResourceID: listingResourceID)!.getDetails().purchased == true: "listing not purchased yet"
            }
            let listing <- self.listings.remove(key: listingResourceID)!
            let listingDetails = listing.getDetails()
            self.removeDuplicateListing(nftIdentifier: listingDetails.nftType.identifier, nftID: listingDetails.nftID, listingResourceID: listingResourceID)

            destroy listing
        }

        pub fun getDuplicateListingIDs(nftType: Type, nftID: UInt64, listingID: UInt64): [UInt64] {
            var listingIDs = self.getExistingListingIDs(nftType: nftType, nftID: nftID)

            let doesListingExist = listingIDs.contains(listingID)
            if doesListingExist {
                var index: Int = 0
                for id in listingIDs {
                    if id == listingID {
                        break
                    }
                    index = index + 1
                }
                listingIDs.remove(at:index)
                return listingIDs
            } 
           return []
        }

        pub fun cleanupExpiredListings(fromIndex: UInt64, toIndex: UInt64) {
            pre {
                fromIndex <= toIndex : "Incorrect start index"
                Int(toIndex - fromIndex) < self.getListingIDs().length : "Provided range is out of bound"
            }
            var index = fromIndex
            let listingsIDs = self.getListingIDs()
            while index <= toIndex {
                
                if let listing = self.borrowListing(listingResourceID: listingsIDs[index]) {
                    if listing.getDetails().expiry <= UInt64(getCurrentBlock().timestamp) {
                        self.cleanup(listingResourceID: listingsIDs[index])
                    }
                }
                index = index + UInt64(1) 
            }
        } 

        pub fun borrowListing(listingResourceID: UInt64): &Listing{ListingPublic}? {
             if self.listings[listingResourceID] != nil {
                return &self.listings[listingResourceID] as &Listing{ListingPublic}?
            } else {
                return nil
            }
        }

        access(contract) fun cleanup(listingResourceID: UInt64) {
            pre {
                self.listings[listingResourceID] != nil: "could not find listing with given id"
            }
            let listing <- self.listings.remove(key: listingResourceID)!
            let listingDetails = listing.getDetails()
            self.removeDuplicateListing(nftIdentifier: listingDetails.nftType.identifier, nftID: listingDetails.nftID, listingResourceID: listingResourceID)

            destroy listing
        }

        destroy () {
            destroy self.listings

            emit StorefrontDestroyed(storefrontResourceID: self.uuid)
        }

        init () {
            self.listings <- {}
            self.listedNFTs = {}

            emit StorefrontInitialized(storefrontResourceID: self.uuid)
        }
    }

    pub fun createStorefront(): @Storefront {
        return <-create Storefront()
    }

    init () {
        self.StorefrontStoragePath = /storage/NFTStorefrontV2
        self.StorefrontPublicPath = /public/NFTStorefrontV2
    }
}
 
