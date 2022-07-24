import Beam from "../contracts/Beam.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"

pub fun main(account: Address, id: UInt64): AnyStruct {

    let collectionRef = getAccount(account).getCapability(Beam.CollectionPublicPath)
        .borrow<&{Beam.BeamCollectionPublic}>()
        ?? panic("Could not get public Collectible collection reference")

    let viewResolver = collectionRef.borrowViewResolver(id: id)

    let data = viewResolver.resolveView(Type<MetadataViews.Display>())
    let display = data as! MetadataViews.Display

    return data!
}