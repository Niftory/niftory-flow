import NiftoryNonFungibleTokenProxy
  from "../../contracts/NiftoryNonFungibleTokenProxy.cdc"

transaction() {

  prepare(acct: AuthAccount) {
    let proxy <- NiftoryNonFungibleTokenProxy.create()
    acct.save(<-proxy, to: NiftoryNonFungibleTokenProxy.STORAGE_PATH)
    acct.link<&{
      NiftoryNonFungibleTokenProxy.Public,
      NiftoryNonFungibleTokenProxy.Private
    }>(
      NiftoryNonFungibleTokenProxy.PRIVATE_PATH,
      target: NiftoryNonFungibleTokenProxy.STORAGE_PATH
    )
    acct.link<&{
      NiftoryNonFungibleTokenProxy.Public
    }>(
      NiftoryNonFungibleTokenProxy.PUBLIC_PATH,
      target: NiftoryNonFungibleTokenProxy.STORAGE_PATH
    )
  }
}
