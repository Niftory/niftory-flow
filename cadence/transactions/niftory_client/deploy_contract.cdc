import MutableMetadataSetManager from "../../contracts/MutableMetadataSetManager.cdc"
import MetadataViewsManager from "../../contracts/MetadataViewsManager.cdc"

import NiftoryNFTDeployer from "../../contracts/NiftoryNFTDeployer.cdc"
import NiftoryNFTRegistry from "../../contracts/NiftoryNFTRegistry.cdc"

transaction(
    nonFungibleTokenAddress: Address,
    niftoryContractAddress: Address,
    contractName: String
) {
  prepare(acct: AuthAccount) {

    // Generate the code to be deployed
    let code = NiftoryNFTDeployer.generateContractCode(
      nonFungibleTokenAddress: nonFungibleTokenAddress,
      niftoryContractAddress: niftoryContractAddress,
      contractName: contractName
    )

    // Just to generate paths
    let record = NiftoryNFTRegistry.generateRecordFull(
      contractAddress: acct.address,
      project: contractName
    )

    // Save a MutableSetManager to this contract's storage, as the source of
    // this NFT contract's metadata.
    //
    // MutableMetadataSetManager storage
    acct.save<@MutableMetadataSetManager.Manager>(
        <-MutableMetadataSetManager.create(
          name: contractName,
          description: "The set manager for ".concat(contractName)
        ),
        to: record.setManager.paths.storage
      )

    // MutableMetadataSetManager public
    acct.link<&MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public}>(
        record.setManager.paths.public,
        target: record.setManager.paths.storage
      )

    // MutableMetadataSetManager private
    acct.link<&
        MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public,
        MutableMetadataSetManager.Private
      }>(
        record.setManager.paths.private,
        target: record.setManager.paths.storage
      )

    // Save a MetadataViewsManager to this contract's storage, which will
    // allow observers to inspect standardized metadata through any of its
    // configured MetadataViews resolvers.
    //
    // MetadataViewsManager storage
    acct.save<@MetadataViewsManager.Manager>(
        <-MetadataViewsManager.create(),
        to: record.metadataViewsManager.paths.storage
      )

    // MetadataViewsManager public
    acct.link<&MetadataViewsManager.Manager{MetadataViewsManager.Public}>(
        record.metadataViewsManager.paths.public,
        target: record.metadataViewsManager.paths.storage
      )

    // MetadataViewsManager private
    acct.link<&
        MetadataViewsManager.Manager{MetadataViewsManager.Private,
        MetadataViewsManager.Public
      }>(
        record.metadataViewsManager.paths.private,
        target: record.metadataViewsManager.paths.storage
      )

    // Capabilities to the MutableMetadataSetManager and MetadataViewsManager
    let setManagerCap = acct.getCapability<&
      MutableMetadataSetManager.Manager{MutableMetadataSetManager.Public,
        MutableMetadataSetManager.Private}>(record.setManager.paths.private)
    let metadataViewsManagerCap = acct.getCapability<&
      MetadataViewsManager.Manager{MetadataViewsManager.Public,
        MetadataViewsManager.Private}>(
          record.metadataViewsManager.paths.private
        )

    // Deploy the contract
    acct.contracts.add(
      name: contractName,
      code: code,
      record: record,
      setManagerCap: setManagerCap,
      metadataViewsManagerCap: metadataViewsManagerCap
    )
  }
}