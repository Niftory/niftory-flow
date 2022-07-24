import Niftory from "../../contracts/Niftory.cdc"

transaction(recipient: Address, collectionPath: String, ids: [UInt64]) {
  prepare(acct: AuthAccount) {

    let recipientCollectionPublicPath = PublicPath(identifier: collectionPath)!
    let recipientCollection = getAccount(recipient)
      .getCapability(recipientCollectionPublicPath)
      .borrow<&{Niftory.CollectionPublic}>()!

    let collectionPrivatePath = PrivatePath(identifier: collectionPath)!
    let collection = acct
      .getCapability(collectionPrivatePath)
      .borrow<&{Niftory.CollectionPrivate}>()!

    recipientCollection.depositBulk(tokens: <- collection.withdrawBulk(withdrawIDs: ids))
  }
}