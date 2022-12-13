import { emulator, init } from 'flow-js-testing'
import * as path from 'path'
import * as sdk from '../src/sdk'
import {
  checkContextAlive,
  checkSuccessfulTransactions,
  initAccount,
} from '../src/testers'

// For the emulator environment, the values from flow.json are used.
const PRIVATE_KEY =
  '418acca4607d4a220009623d5d4f392b0e1511a3cca422cbd54ae817a0f65f69'
const PUBLIC_KEY =
  '6e1bfdf4da1e5c1930465c8bbe0af3ca398cc252e824dd224c79e4d2111c5a7c36a7099f9019f46df4fb9903939c083fe8409e8899af0a05fbbfe8d994569f23'

// All accounts
const BASE_CONTRACTS = 'base_contracts'
const DAPPER = 'dapper'
const NIFTORY_LIBRARIES = 'niftory_libraries'
const NIFTORY = 'niftory'
const BRAND_A_CONTRACT = 'brand_a_contract'
const BRAND_A_STORAGE = 'brand_a_storage'
const BRAND_B_CONTRACT = 'brand_b_contract'
const BRAND_B_STORAGE = 'brand_b_storage'
const COLLECTOR_A = 'collector_a'
const COLLECTOR_B = 'collector_b'

// Testing constants
const BRAND_A_NAME = 'brand_a'

// MISC
const MAX_UINT_64 = BigInt('18446744073709551615')

// These tests can take a _long_ time
jest.setTimeout(1000000)

const sansPrefix = (address: string): string => address.replace(/^0x/, '')

describe('basic-test', () => {
  beforeAll(async () => {
    // Basic emulator params
    const basePath = path.resolve(__dirname, '../cadence')
    const port = 8080
    const logging = true

    // Start the emulator - it runs the emulator in a subprocess
    await init(basePath, { port })
    return emulator.start(port, logging)
  })

  afterAll(async () => {
    // Stop the emulator so it stops the subprocess
    return emulator.stop()
  })

  test('+++', async () => {
    // Create accounts and get their addresses
    const addresses = {
      baseContracts: await initAccount(BASE_CONTRACTS, '100'),
      dapper: await initAccount(DAPPER, '100'),
      niftoryLibraries: await initAccount(NIFTORY_LIBRARIES, '100'),
      niftory: await initAccount(NIFTORY, '100'),
      brandAContract: await initAccount(BRAND_A_CONTRACT, '100'),
      brandAStorage: await initAccount(BRAND_A_STORAGE, '100'),
      brandBContract: await initAccount(BRAND_B_CONTRACT, '100'),
      brandBStorage: await initAccount(BRAND_B_STORAGE, '100'),
      collectorA: await initAccount(COLLECTOR_A, '100'),
      collectorB: await initAccount(COLLECTOR_B, '100'),
    }
    console.log(addresses)

    // Get all of our actors
    const baseContractDeployer = sdk.createBaseContractDeployer(BASE_CONTRACTS)
    const dapperContractDeployer = sdk.createExternalContractDeployer(DAPPER)
    const niftoryLibrariesContractDeployer =
      sdk.createNiftoryContractDeployer(NIFTORY_LIBRARIES)

    const niftoryAdmin = sdk.createNiftoryAdmin(NIFTORY)

    const brandAContractManager = sdk.createContractManager(BRAND_A_CONTRACT)
    const brandAStorageManager = sdk.createBrandManager(
      BRAND_A_STORAGE,
      addresses.niftory,
      BRAND_A_NAME,
    )

    const dapperBuyer = sdk.createDapperTripleAuthorizer(
      BRAND_A_STORAGE,
      DAPPER,
      COLLECTOR_A,
    )

    // Deploy all contracts
    await baseContractDeployer
      .deploy('NonFungibleToken')
      .deploy('MetadataViews')
      .deploy('NFTStorefrontV2')
      .deploy('TokenForwarding')
      .do(checkSuccessfulTransactions(4))
      .do(checkContextAlive)
      .wait()

    await dapperContractDeployer
      .deploy('DapperUtilityCoin')
      .deploy('NFTCatalog')
      .deploy('NFTCatalogAdmin')
      .do(checkSuccessfulTransactions(3))
      .do(checkContextAlive)
      .wait()

    await niftoryLibrariesContractDeployer
      .deploy('MetadataViewsManager')
      .deploy('MutableMetadata')
      .deploy('MutableMetadataTemplate')
      .deploy('MutableMetadataSet')
      .deploy('MutableMetadataSetManager')
      .deploy('NiftoryNonFungibleToken')
      .deploy('NiftoryNonFungibleTokenProxy')
      .deploy('NiftoryMetadataViewsResolvers')
      .deploy('NiftoryNFTRegistry')
      .do(checkSuccessfulTransactions(9))
      .do(checkContextAlive)
      .wait()

    // Niftory Admin will initialize the registry
    await niftoryAdmin
      .initialize({})
      .register_brand({
        contractAddress: addresses.brandAContract,
        brand: BRAND_A_NAME,
      })
      .do(checkContextAlive)
      .wait()

    // Brand contract manager will deploy the template contract
    await brandAContractManager
      .deployNFTContract({
        registryAddress: addresses.niftory,
        brand: BRAND_A_NAME,
      })
      .log()
      .do(checkContextAlive)
      .wait()

    // Brand storage manager will create a proxy manager for their account and
    // intialize a collection for pre-minting
    await brandAStorageManager
      .initialize_proxy({})
      .initialize_collection({})
      .do(checkContextAlive)
      .wait()

    // Brand contract manager will transfer proxy to brand storage manager
    await brandAContractManager
      .transfer_proxy({
        registryAddress: addresses.niftory,
        brand: BRAND_A_NAME,
        proxyAddress: addresses.brandAStorage,
      })
      .do(checkContextAlive)
      .wait()

    // Storage manager will create a template
    await brandAStorageManager
      .add_set({ initialMetadata: { name: 'Set 1' } })
      .add_template({
        setId: 0,
        initialMetadata: { name: 'Template 1' },
        maxMint: 5,
      })
      .do(checkContextAlive)
      .wait()

    // DUC lazy minting
    await dapperBuyer
      .custom_buy({
        merchantAccountAddress: addresses.brandAContract,
        registryAddress: addresses.niftory,
        nftType: `A.${sansPrefix(
          addresses.brandAContract,
        )}.NiftoryTemplate.NFT`,
        brand: BRAND_A_NAME,
        setId: 0,
        templateId: 0,
        price: '10.0',
      })
      .do(checkContextAlive)
      .wait()

    // Pre-mint one token

    // DUC purchase pre-minted
  })
})
