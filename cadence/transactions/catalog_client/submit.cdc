import MetadataViews from "../../contracts/MetadataViews.cdc"
import NFTCatalog from "../../contracts/NFTCatalog.cdc"

transaction(
  collectionIdentifier : String,
  contractName: String,
  contractAddress: Address,
  nftTypeIdentifer: String,
  storagePathIdentifier: String,
  publicPathIdentifier: String,
  privatePathIdentifier: String,
  publicLinkedTypeIdentifier : String,
  publicLinkedTypeRestrictions : [String],
  privateLinkedTypeIdentifier : String,
  privateLinkedTypeRestrictions : [String],
  collectionName : String,
  collectionDescription: String,
  externalURL : String,
  squareImageMediaURL : String,
  squareImageMediaType : String,
  bannerImageMediaURL : String,
  bannerImageMediaType : String,
  socials: {String : String},
  message: String
) {

  let nftCatalogProposalResourceRef : &NFTCatalog.NFTCatalogProposalManager

  prepare(acct: AuthAccount) {

    if acct.borrow<&NFTCatalog.NFTCatalogProposalManager>(
      from: NFTCatalog.ProposalManagerStoragePath
    ) == nil {
      let proposalManager <- NFTCatalog.createNFTCatalogProposalManager()
      acct.save(<-proposalManager, to: NFTCatalog.ProposalManagerStoragePath)
      acct.link<&NFTCatalog.NFTCatalogProposalManager{NFTCatalog.NFTCatalogProposalManagerPublic}>(
        NFTCatalog.ProposalManagerPublicPath,
        target: NFTCatalog.ProposalManagerStoragePath
      )
    }

    self.nftCatalogProposalResourceRef = acct
      .borrow<&NFTCatalog.NFTCatalogProposalManager>(
        from: NFTCatalog.ProposalManagerStoragePath
      )!
  }

  execute {
    let gateway = "https://cloudflare-ipfs.com/ipfs/"
    var realSquareImageMediaURL = squareImageMediaURL
    var realBannerImageMediaURL = bannerImageMediaURL
    if realSquareImageMediaURL.slice(from: 0, upTo: 7) == "ipfs://" {
      realSquareImageMediaURL = gateway.concat(
        realSquareImageMediaURL.slice(
          from: 7,
          upTo: realSquareImageMediaURL.length
        )
      )
    }
    if realBannerImageMediaURL.slice(from: 0, upTo: 7) == "ipfs://" {
      realBannerImageMediaURL = gateway.concat(
        realBannerImageMediaURL.slice(
          from: 7,
          upTo: realBannerImageMediaURL.length
        )
      )
    }

    var privateLinkedType: Type? = nil
    if (privateLinkedTypeRestrictions.length == 0) {
      privateLinkedType = CompositeType(publicLinkedTypeIdentifier)
    } else {
      privateLinkedType = RestrictedType(
        identifier : privateLinkedTypeIdentifier,
        restrictions: privateLinkedTypeRestrictions
      )
    }

    let collectionData = NFTCatalog.NFTCollectionData(
      storagePath: StoragePath(identifier: storagePathIdentifier)!,
      publicPath: PublicPath(identifier : publicPathIdentifier)!,
      privatePath: PrivatePath(identifier: privatePathIdentifier)!,
      publicLinkedType : RestrictedType(
        identifier : publicLinkedTypeIdentifier,
        restrictions: publicLinkedTypeRestrictions
      )!,
      privateLinkedType : privateLinkedType!
    )

    let squareMedia = MetadataViews.Media(
            file: MetadataViews.HTTPFile(
              url: realSquareImageMediaURL
            ),
            mediaType: squareImageMediaType
          )

    let bannerMedia = MetadataViews.Media(
            file: MetadataViews.HTTPFile(
              url: realBannerImageMediaURL
            ),
            mediaType: bannerImageMediaType
          )

    let socialsStruct : {String : MetadataViews.ExternalURL} = {}
    for key in socials.keys {
      socialsStruct[key] =  MetadataViews.ExternalURL(socials[key]!)
    }

    let collectionDisplay = MetadataViews.NFTCollectionDisplay(
      name: collectionName,
      description: collectionDescription,
      externalURL: MetadataViews.ExternalURL(externalURL),
      squareImage: squareMedia,
      bannerImage: bannerMedia,
      socials: socialsStruct
    )

    let catalogData = NFTCatalog.NFTCatalogMetadata(
      contractName: contractName,
      contractAddress: contractAddress,
      nftType: CompositeType(nftTypeIdentifer)!,
      collectionData: collectionData,
      collectionDisplay: collectionDisplay
    )

    self
      .nftCatalogProposalResourceRef
      .setCurrentProposalEntry(identifier : collectionIdentifier)

    NFTCatalog.proposeNFTMetadata(
      collectionIdentifier: collectionIdentifier,
      metadata: catalogData,
      message: message,
      proposer: self.nftCatalogProposalResourceRef.owner!.address
    )

    self.nftCatalogProposalResourceRef.setCurrentProposalEntry(identifier : nil)
  }
}
