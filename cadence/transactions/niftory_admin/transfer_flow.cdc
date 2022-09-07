import FungibleToken from "../../contracts/FungibleToken.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(brand: String, amount: UFix64) {

  let registryAddress: Address
  let vault: @FungibleToken.Vault

  prepare(acct: AuthAccount) {
    self.registryAddress = acct.address
    self.vault <- acct
      .borrow<&{FungibleToken.Provider}>(from: /storage/flowTokenVault)!
      .withdraw(amount: amount)
  }

  execute {
    let brandFlowAddress = NiftoryNFTRegistry.getRegistryRecord(
      self.registryAddress,
      brand
    ).contractAddress
    let receiver = getAccount(brandFlowAddress)
      .getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)
      .borrow()!
    receiver.deposit(from: <-self.vault)
  }
}