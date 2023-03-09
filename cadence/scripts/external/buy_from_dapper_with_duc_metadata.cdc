import DapperUtilityCoin from "../../contracts/DapperUtilityCoin.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

// Static params - change these to customize the script
let REGISTRY_ADDRESS: Address = 0x1
let BRAND: String = "adf"

// Constants
let NAME_FIELD = "title"
let DESCRIPTION_FIELD = "description"
let POSTER_URL_FIELD = "posterUrl"
let MEDIA_URL_FIELD = "mediaUrl"
let IPFS_GATEWAY = "https://cloudflare-ipfs.com/ipfs/"

pub struct PurchaseData {
  pub let id: UInt64
  pub let name: String
  pub let amount: UFix64
  pub let description: String
  pub let imageURL: String
  pub let paymentVaultTypeID: Type

  init(
    id: UInt64,
    name: String,
    amount: UFix64,
    description: String,
    imageURL: String,
    paymentVaultTypeID: Type
  ) {
    self.id = id
    self.name = name
    self.amount = amount
    self.description = description
    self.imageURL = imageURL
    self.paymentVaultTypeID = paymentVaultTypeID
  }
}

pub fun main(
  merchantAccountAddress: Address,
  nftId: UInt64?,
  setId: Int?,
  templateId: Int?,
  price: UFix64,
): PurchaseData {

  if setId == nil || templateId == nil {
    panic("setId and templateId must be provided")
  }

  // The set manager has all the metadata for the NFT (which may not be minted yet)
  let setManager = NiftoryNFTRegistry.getSetManagerPublic(
    REGISTRY_ADDRESS,
    BRAND
  )

  // Find the corresponding template
  let template = setManager
    .getSet(setId!)
    .getTemplate(templateId!)
    .metadata()
    .get() as! {String: String}
  let name = template[NAME_FIELD]!
  let description = template[DESCRIPTION_FIELD]!
  let posterURL = template[POSTER_URL_FIELD]
  let mediaURL = template[MEDIA_URL_FIELD]

  // Figure out which imageURL to use
  var imageURL = ""
  if (posterURL != nil && posterURL! != "") {
    imageURL = posterURL!
  } else {
    imageURL = mediaURL!
  }

  // IPFS Gateway > IPFS
  if (imageURL.slice(from: 0, upTo: 7) == "ipfs://") {
    imageURL = IPFS_GATEWAY.concat(
      imageURL.slice(
        from: 7,
        upTo: imageURL.length
      )
    )
  }

  return PurchaseData(
    id: nftId ?? 0,
    name: name,
    amount: price,
    description: description,
    imageURL: imageURL,
    paymentVaultTypeID: Type<@DapperUtilityCoin.Vault>()
  )
}
