import { emulator, getAccountAddress, init } from 'flow-js-testing'
import * as path from 'path'
import {
  brandManager,
  collection,
  collector,
  contractAccount,
  metadataViewsManagerAdmin,
  mutable_metadata,
  mutable_set,
  mutable_set_manager,
  niftory,
  niftoryAdmin,
  setAdmin,
  setManagerAdmin,
  templateAdmin,
} from '../src/sdk2'
import {
  assertScriptValue,
  checkContextAlive,
  checkScriptFailed,
  checkScriptSucceeded,
  checkScriptValue,
  checkSuccessfulTransactions,
  initAccount,
} from '../src/testers'

const ADMIN_ALICE = 'admin_alice'
const BRAND_MANAGER_BOB = 'brand_manager_bob'
const BRAND_MANAGER_BARBARA = 'brand_manager_barbara'
const COLLECTOR_CHARLIE = 'collector_bob'
const COLLECTOR_CAROL = 'collector_carol'

// Return if one string->string object is a subset of another
const isSubset = (
  subset: { [key: string]: string },
  superset: { [key: string]: string },
): boolean => Object.keys(subset).every((key) => superset[key] === subset[key])

const sansPrefix = (str: string): string => str.slice(2)

const t = (str: string) =>
  console.log(
    `================================================================
${str}
================================================================`,
  )

jest.setTimeout(1000000)

describe('basic-test', () => {
  beforeEach(async () => {
    const basePath = path.resolve(__dirname, '../cadence')
    const port = 8080
    const logging = false

    await init(basePath, { port })
    return emulator.start(port, logging)
  })

  // Stop emulator, so it could be restarted
  afterEach(async () => {
    return emulator.stop()
  })

  test('+++', async () => {
    type AddressBook = { [key: string]: string }

    const addressBook: AddressBook = {
      alice: await getAccountAddress(ADMIN_ALICE),
      bob: await getAccountAddress(BRAND_MANAGER_BOB),
      barbara: await getAccountAddress(BRAND_MANAGER_BARBARA),
      carol: await getAccountAddress(COLLECTOR_CAROL),
      charlie: await getAccountAddress(COLLECTOR_CHARLIE),
    }

    const alice = {
      deployer: contractAccount(ADMIN_ALICE),
      niftoryAdmin: niftoryAdmin(ADMIN_ALICE),
    }

    const bob = {
      setManagerAdmin: setManagerAdmin(
        BRAND_MANAGER_BOB,
        addressBook.alice,
        'NiftoryTemplate',
      ),
      metadataViewsAdmin: metadataViewsManagerAdmin(
        BRAND_MANAGER_BOB,
        addressBook.alice,
        'NiftoryTemplate',
      ),
      set: ({ setId }: { setId: number }) => ({
        admin: setAdmin(
          BRAND_MANAGER_BOB,
          addressBook.alice,
          'NiftoryTemplate',
          setId,
        ),
        template: ({ templateId }: { templateId: number }) => ({
          admin: templateAdmin(
            BRAND_MANAGER_BOB,
            addressBook.alice,
            'NiftoryTemplate',
            setId,
            templateId,
          ),
        }),
      }),
      deployer: brandManager(BRAND_MANAGER_BOB),
    }

    const carol = {
      collector: collector(
        COLLECTOR_CAROL,
        addressBook.alice,
        'NiftoryTemplate',
      ),
    }

    const charlie = {
      collector: collector(
        COLLECTOR_CHARLIE,
        addressBook.alice,
        'NiftoryTemplate',
      ),
    }

    const q = {
      nfts: {
        x: {
          setManager: mutable_set_manager(addressBook.alice, 'NiftoryTemplate'),
          set: ({ setId }: { setId: number }) => ({
            info: mutable_set(addressBook.alice, 'NiftoryTemplate', setId),
            template: ({ templateId }: { templateId: number }) => ({
              info: mutable_metadata(
                addressBook.alice,
                'NiftoryTemplate',
                setId,
                templateId,
              ),
            }),
          }),
          collection: ({ collectorAddress }: { collectorAddress: string }) => ({
            info: collection(
              addressBook.alice,
              'NiftoryTemplate',
              collectorAddress,
            ),
          }),
        },
      },
      niftory: niftory(addressBook.alice),
    }

    // ================================

    t("Alice deploys Niftory's contract")

    // Initialize all our accounts and give everyone 10 FLOW
    await Promise.resolve()
      .then(() => initAccount(ADMIN_ALICE, '10'))
      .then(() => initAccount(BRAND_MANAGER_BOB, '10'))
      .then(() => initAccount(BRAND_MANAGER_BARBARA, '10'))
      .then(() => initAccount(COLLECTOR_CHARLIE, '10'))
      .then(() => initAccount(COLLECTOR_CAROL, '10'))

    // Alice will deploy all the public contracts
    await alice.deployer
      .deployNonFungibleToken()
      .deployMetadataViews()
      .deployMutableMetadata()
      .deployMutableMetadataTemplate()
      .deployMutableMetadataSet()
      .deployMutableMetadataSetManager()
      .deployMetadataViewsManager()
      .deployNiftoryNonFungibleToken()
      .deployNiftoryMetadataViewsResolvers()
      .do(checkContextAlive)
      .do(checkSuccessfulTransactions(9))
      .wait()

    t(
      'Alice will deploy the NFT registry and register NiftoryTemplate as a brand owned by Bob',
    )

    await alice.niftoryAdmin
      .deployNFTRegistry()
      .initialize({})
      .register_brand({
        contractAddress: addressBook.bob,
        brand: 'NiftoryTemplate',
      })
      .do(checkContextAlive)
      .do(checkSuccessfulTransactions(3))
      .wait()
    await q.niftory.brands().then(checkScriptSucceeded)

    // Our first attempt to fetch info fails because it's not initialized
    await q.nfts.x.setManager.info().then(checkScriptFailed)

    t('Bob will deploy the NFT contract and we will check the info again')

    // Bob will deploy the XXTEMPLATEXX NFT contract.
    await bob.deployer
      .deployNFTContract()
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x.setManager
      .info()
      .then(checkScriptSucceeded)
      .then(
        checkScriptValue({
          name: 'NiftoryTemplate',
          description: 'The set manager for NiftoryTemplate.',
          numSets: 0,
        }),
      )

    // t('Bob will change the name and description of the set manager')

    // // Bob will change the name and description of the set manager
    // await bob.setManagerAdmin
    //   .set_name({ name: 'Set Manager 2' })
    //   .set_description({ description: 'This is a mutable set manager' })
    //   .do(checkSuccessfulTransactions(2))
    //   .wait()
    // await q.nfts.x.setManager
    //   .info()
    //   .then(checkScriptSucceeded)
    //   .then(
    //     checkScriptValue({
    //       name: 'Set Manager 2',
    //       description: 'This is a mutable set manager',
    //       numSets: 0,
    //     }),
    //   )

    // t('Bob will add three empty sets')

    // Bob will add three empty sets to the set manager
    await bob.setManagerAdmin
      .add_set({ initialMetadata: { name: 'Set 1' } })
      // .add_set({ initialMetadata: { name: 'Set 2' } })
      // .add_set({ initialMetadata: { name: 'Set 3' } })
      // .do(checkSuccessfulTransactions(3))
      .wait()
    // await q.nfts.x.setManager
    //   .info()
    //   .then(checkScriptSucceeded)
    //   .then(
    //     checkScriptValue({
    //       name: 'Set Manager 2',
    //       description: 'This is a mutable set manager',
    //       numSets: 3,
    //     }),
    //   )

    // t('Check to see if the first set was initialized correctly')

    // // Let's make sure the first set was initialized correctly
    // await q.nfts.x
    //   .set({ setId: 0 })
    //   .info.info()
    //   .then(
    //     assertScriptValue(
    //       ({ locked, metadataLocked, metadata, numTemplates }) =>
    //         !locked &&
    //         !metadataLocked &&
    //         metadata['name'] === 'Set 1' &&
    //         numTemplates == 0,
    //     ),
    //   )

    t('Bob will add three templates to the first set')

    // Bob will add three templates to the first set
    await bob
      .set({ setId: 0 })
      .admin.add_template({ initialMetadata: { name: 'Template 1' } })
      .add_template({ initialMetadata: { name: 'Template 2' }, maxMint: 5 })
      .add_template({ initialMetadata: { name: 'Template 3' }, maxMint: 10 })
      .do(checkSuccessfulTransactions(3))
      .wait()
    await q.nfts.x
      .set({ setId: 0 })
      .info.info()
      .then(
        assertScriptValue(
          ({ locked, metadataLocked, metadata, numTemplates }) =>
            !locked &&
            !metadataLocked &&
            metadata['name'] === 'Set 1' &&
            numTemplates == 3,
        ),
      )

    // t('Bob will lock the set to make sure no more templates can be added')

    // // Locking the set should stop Bob from adding templates
    // await bob
    //   .set({ setId: 0 })
    //   .admin.lock()
    //   .do(checkSuccessfulTransactions(1))
    //   .wait()

    // await bob
    //   .set({ setId: 0 })
    //   .admin.add_template({ initialMetadata: { name: 'Template 4' } })
    //   .add_template({ initialMetadata: { name: 'Template 5' }, maxMint: 5 })
    //   .add_template({ initialMetadata: { name: 'Template 6' }, maxMint: 10 })
    //   .do(checkContextDead)
    //   .do(checkSkippedTransactions(3))
    //   .do(checkSuccessfulTransactions(0))
    //   .wait()
    // await q.nfts.x
    //   .set({ setId: 0 })
    //   .info.info()
    //   .then(
    //     assertScriptValue(
    //       ({ locked, metadataLocked, metadata, numTemplates }) =>
    //         locked &&
    //         !metadataLocked &&
    //         metadata['name'] === 'Set 1' &&
    //         numTemplates == 3,
    //     ),
    //   )

    // t("Let's inspect the first two templates")

    // // Let's take a look at the first two templates
    // await q.nfts.x
    //   .set({ setId: 0 })
    //   .template({ templateId: 0 })
    //   .info.info()
    //   .then(
    //     assertScriptValue(
    //       ({ locked, metadataLocked, metadata, maxMint, minted }) =>
    //         !locked &&
    //         !metadataLocked &&
    //         metadata['name'] === 'Template 1' &&
    //         maxMint == undefined &&
    //         minted == 0,
    //     ),
    //   )
    // await q.nfts.x
    //   .set({ setId: 0 })
    //   .template({ templateId: 1 })
    //   .info.info()
    //   .then(
    //     assertScriptValue(
    //       ({ locked, metadataLocked, metadata, maxMint, minted }) =>
    //         !locked &&
    //         !metadataLocked &&
    //         metadata['name'] === 'Template 2' &&
    //         maxMint == 5 &&
    //         minted == 0,
    //     ),
    //   )

    // t(
    //   'Bob will try modifying the metadata of the first template using various methods',
    // )

    // // Bob will try modifying the metadata of the first template using
    // // various methods
    // await bob
    //   .set({ setId: 0 })
    //   .template({ templateId: 0 })
    //   .admin.set_field({ key: 'key1', value: 'value1' })
    //   .set_field({ key: 'key2', value: 'value2' })
    //   .set_field({ key: 'key3', value: 'value3' })
    //   .delete_field({ key: 'key2' })
    //   .do(checkSuccessfulTransactions(4))
    //   .wait()
    // await q.nfts.x
    //   .set({ setId: 0 })
    //   .template({ templateId: 0 })
    //   .info.info()
    //   .then(
    //     assertScriptValue(
    //       ({ metadata }) =>
    //         isSubset({ key1: 'value1', key3: 'value3' }, metadata) &&
    //         !isSubset({ key2: 'value2' }, metadata),
    //     ),
    //   )
    // await bob
    //   .set({ setId: 0 })
    //   .template({ templateId: 0 })
    //   .admin.replace_metadata({
    //     metadata: {
    //       KEY1: 'VALUE1',
    //       KEY2: 'VALUE2',
    //       KEY3: 'VALUE3',
    //     },
    //   })
    //   .delete_field({ key: 'KEY2' })
    //   .do(checkSuccessfulTransactions(2))
    //   .wait()
    // await q.nfts.x
    //   .set({ setId: 0 })
    //   .template({ templateId: 0 })
    //   .info.info()
    //   .then(
    //     assertScriptValue(
    //       ({ metadata }) =>
    //         isSubset({ KEY1: 'VALUE1', KEY3: 'VALUE3' }, metadata) &&
    //         !isSubset({ KEY2: 'VALUE2' }, metadata),
    //     ),
    //   )

    // t('Bob should not be able to modify the metadata anymore after locking it.')

    // // Bob should not be able to modify the metadata any more
    // // after trying to lock it.
    // await bob
    //   .set({ setId: 0 })
    //   .template({ templateId: 0 })
    //   .admin.lock_metadata()
    //   .set_field({ key: 'key1', value: 'value1' })
    //   .do(checkContextDead)
    //   .do(checkSkippedTransactions(1))
    //   .do(checkSuccessfulTransactions(1))
    //   .wait()
    // await q.nfts.x
    //   .set({ setId: 0 })
    //   .template({ templateId: 0 })
    //   .info.info()
    //   .then(
    //     assertScriptValue(
    //       ({ metadataLocked, metadata }) =>
    //         metadataLocked && !isSubset({ key1: 'value1' }, metadata),
    //     ),
    //   )

    t('Carol and Charlie will initialize their collections.')

    // Carol and Charlie will initialize their NFT Collections.
    // They should have zero NFTs to start with
    await carol.collector
      .initialize({})
      .do(checkSuccessfulTransactions(1))
      .wait()
    // await charlie.collector
    //   .initialize({})
    //   .do(checkSuccessfulTransactions(1))
    //   .wait()
    // await q.nfts.x
    //   .collection({ collectorAddress: addressBook.carol })
    //   .info.info()
    //   .then(
    //     checkScriptValue({
    //       numNfts: 0,
    //       nftIds: new Set<number>([]),
    //     }),
    //   )
    // await q.nfts.x
    //   .collection({ collectorAddress: addressBook.charlie })
    //   .info.info()
    //   .then(
    //     checkScriptValue({
    //       numNfts: 0,
    //       nftIds: new Set<number>([]),
    //     }),
    //   )

    t('Bob will mint 50 NFTs for Carol and 10 to Charlie')

    // // Bob will mint 50 NFTs for the first template to Carol, and 10 to Charlie.
    // await bob.setManagerAdmin
    //   .mint({
    //     setId: 0,
    //     templateId: 0,
    //     collectorAddress: addressBook.carol,
    //   })
    //   .mint({
    //     setId: 0,
    //     templateId: 0,
    //     collectorAddress: addressBook.carol,
    //   })
    //   .do(checkSuccessfulTransactions(2))
    //   .wait()
    // await q.nfts.x
    //   .collection({ collectorAddress: addressBook.carol })
    //   .info.info()
    //   .then(
    //     checkScriptValue({
    //       numNfts: 2,
    //       nftIds: new Set([0, 1]),
    //     }),
    //   )

    await bob.setManagerAdmin
      .mint_bulk({
        setId: 0,
        templateId: 0,
        collectorAddress: addressBook.carol,
        numToMint: 10,
      })
      // .mint({
      //   setId: 0,
      //   templateId: 0,
      //   collectorAddress: addressBook.charlie,
      // })
      // .mint({
      //   setId: 0,
      //   templateId: 0,
      //   collectorAddress: addressBook.carol,
      // })
      // .mint_bulk({
      //   setId: 0,
      //   templateId: 0,
      //   collectorAddress: addressBook.charlie,
      //   numToMint: 9,
      // })
      // .mint_bulk({
      //   setId: 0,
      //   templateId: 0,
      //   collectorAddress: addressBook.carol,
      //   numToMint: 19,
      // })
      // .mint_bulk({
      //   setId: 0,
      //   templateId: 0,
      //   collectorAddress: addressBook.carol,
      //   numToMint: 18,
      // })
      // .do(checkContextAlive)
      // .do(checkSuccessfulTransactions(6))
      .wait()
    // await q.nfts.x
    //   .collection({ collectorAddress: addressBook.carol })
    //   .info.info()
    //   .then(
    //     assertScriptValue(
    //       (actual) => actual.numNfts == 50 && actual.nftIds.has(59),
    //     ),
    //   )
    // await q.nfts.x
    //   .collection({ collectorAddress: addressBook.charlie })
    //   .info.info()
    //   .then(
    //     checkScriptValue({
    //       numNfts: 10,
    //       nftIds: new Set([12, 14, 15, 16, 17, 18, 19, 20, 21, 22]),
    //     }),
    //   )
    // await q.nfts.x
    //   .set({ setId: 0 })
    //   .template({ templateId: 0 })
    //   .info.info()
    //   .then(
    //     assertScriptValue(
    //       ({ locked, maxMint, minted }) =>
    //         !locked && maxMint == undefined && minted == 60,
    //     ),
    //   )

    // t('Bob will lock the NFT template to prevent future minting.')

    // // Bob will lock first template and should not be able to mint any more
    // await bob
    //   .set({ setId: 0 })
    //   .template({ templateId: 0 })
    //   .admin.lock_template()
    //   .do(checkSuccessfulTransactions(1))
    //   .wait()
    // await bob.setManagerAdmin
    //   .mint({
    //     setId: 0,
    //     templateId: 0,
    //     collectorAddress: addressBook.carol,
    //   })
    //   .do(checkContextDead)
    //   .wait()
    // await q.nfts.x
    //   .set({ setId: 0 })
    //   .template({ templateId: 0 })
    //   .info.info()
    //   .then(assertScriptValue(({ locked, minted }) => locked && minted == 60))

    // t('Bob will mint 6 NFTs from the second template (limited to 5)')

    // // Bob will now try to mint 6 NFTs for the second template. The first
    // // five should be minted successfully, but the sixth should fail because
    // // the limit will have been reached.
    // await bob.setManagerAdmin
    //   .mint_bulk({
    //     setId: 0,
    //     templateId: 1,
    //     collectorAddress: addressBook.carol,
    //     numToMint: 5,
    //   })
    //   .do(checkSuccessfulTransactions(1))
    //   .wait()
    // await bob.setManagerAdmin
    //   .mint({
    //     setId: 0,
    //     templateId: 1,
    //     collectorAddress: addressBook.carol,
    //   })
    //   .do(checkContextDead)
    //   .wait()
    // await q.nfts.x
    //   .set({ setId: 0 })
    //   .template({ templateId: 1 })
    //   .info.info()
    //   .then(
    //     assertScriptValue(
    //       ({ locked, maxMint, minted }) =>
    //         !locked && maxMint == 5 && minted == 5,
    //     ),
    //   )

    // t(
    //   'Bob will mint 5 NFTs from the third template (limited to 10) and lock it',
    // )

    // // Bob will now try to mint 5 NFTs for the third template and lock it.
    // // Even though the limit hasn't been reached, he should not be able
    // // to mint from it anymore.
    // await bob.setManagerAdmin
    //   .mint_bulk({
    //     setId: 0,
    //     templateId: 2,
    //     collectorAddress: addressBook.carol,
    //     numToMint: 5,
    //   })
    //   .do(checkSuccessfulTransactions(1))
    //   .wait()
    // await bob
    //   .set({ setId: 0 })
    //   .template({ templateId: 2 })
    //   .admin.lock_template()
    //   .do(checkSuccessfulTransactions(1))
    //   .wait()
    // await bob.setManagerAdmin
    //   .mint({
    //     setId: 0,
    //     templateId: 2,
    //     collectorAddress: addressBook.carol,
    //   })
    //   .do(checkContextDead)
    //   .wait()
    // await q.nfts.x
    //   .set({ setId: 0 })
    //   .template({ templateId: 2 })
    //   .info.info()
    //   .then(
    //     assertScriptValue(
    //       ({ locked, maxMint, minted }) =>
    //         locked && maxMint == 10 && minted == 5,
    //     ),
    //   )

    // t('Carol will transfer 10 NFTs to Charlie')

    // // Carol will transfer 10 NFTs to Charlie.
    // await carol.collector
    //   .transfer_bulk({
    //     recipientAddress: addressBook.charlie,
    //     ids: [30, 31, 32, 33, 34, 35, 36, 37, 38, 39],
    //   })
    //   .do(checkSuccessfulTransactions(1))
    //   .wait()
    // await q.nfts.x
    //   .collection({ collectorAddress: addressBook.charlie })
    //   .info.info()
    //   .then(assertScriptValue((collection) => collection.numNfts == 20))

    // // Carol can't transfer what she doesn't have
    // await carol.collector
    //   .transfer_bulk({
    //     recipientAddress: addressBook.charlie,
    //     ids: [30],
    //   })
    //   .do(checkContextDead)
    //   .wait()

    // t(
    //   'Bob will change the metadata of one of the templates for an NFT Carol has.',
    // )

    // // Let's inspect one of Carol's NFTs for template 2,
    // // before and after Bob changes the metadata for it.
    // await q.nfts.x
    //   .collection({ collectorAddress: addressBook.carol })
    //   .info.nft(60)
    //   .then(
    //     checkScriptValue({
    //       id: 60,
    //       serial: 1,
    //       setId: 0,
    //       templateId: 1,
    //       metadata: { name: 'Template 2' } as { [key: string]: string },
    //       setMetadata: { name: 'Set 1' } as { [key: string]: string },
    //       views: [] as string[],
    //     }),
    //   )
    // await bob
    //   .set({ setId: 0 })
    //   .template({ templateId: 1 })
    //   .admin.set_field({ key: 'key', value: 'value' })
    //   .do(checkSuccessfulTransactions(1))
    //   .wait()
    // await q.nfts.x
    //   .collection({ collectorAddress: addressBook.carol })
    //   .info.nft(60)
    //   .then(
    //     checkScriptValue({
    //       id: 60,
    //       serial: 1,
    //       setId: 0,
    //       templateId: 1,
    //       metadata: { name: 'Template 2', key: 'value' } as {
    //         [key: string]: string
    //       },
    //       setMetadata: { name: 'Set 1' } as { [key: string]: string },
    //       views: [] as string[],
    //     }),
    //   )

    // For the below section, we will look at the MetadataViews standard
    // metadata interface. Bob will configure generic resolvers for
    // his brand. In the below section, for each resolver, we will inspect
    // each resolver before and after Bob adds it. We will inspect it once
    // more after Bob removes it.

    t('Royalty resolver')

    // Royalty resolver should be null to start with
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.royalty(0)
      // .then(log)
      .then(checkScriptFailed)

    // Configure a royalty resolver
    await bob.metadataViewsAdmin
      .set_royalty_resolver({
        receiverAddress: addressBook.bob,
        description: 'royalty for xx',
        cut: '0.05',
        receiverPath: 'flowTokenReceiver',
      })
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.royalty(0)
      .then(
        checkScriptValue({
          token: 'A.0ae53cb6e3f42a79.FlowToken.Vault',
          cut: 0.05,
          description: 'royalty for xx',
        }),
      )

    t('Royalty resolver removed')

    // Remove the royalty resolver
    await bob.metadataViewsAdmin
      .remove_royalty_resolver({})
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.royalty(0)
      .then(checkScriptFailed)

    t('Display resolver')

    // // Display resolver should be null to start with
    // await q.nfts.x
    //   .collection({ collectorAddress: addressBook.carol })
    //   .info.display(0)
    //   .then(checkScriptFailed)

    // Configure a display resolver
    await bob.metadataViewsAdmin
      .set_ipfs_display_resolver({
        nameField: 'nam',
        defaultName: 'defaultName',
        descriptionField: 'description',
        defaultDescription: 'defaultDescription',
        imageField: 'ipfsImage',
        defaultImagePrefix: 'ipfs://',
        defaultImage: 'defaultIpfsImage',
      })
      .do(checkSuccessfulTransactions(1))
      .wait()
    // await q.nfts.x
    //   .collection({ collectorAddress: addressBook.carol })
    //   .info.display(0)
    //   .then(checkScriptFailed)

    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.display(0)
      .then(
        checkScriptValue({
          name: 'defaultTitle',
          description: 'defaultDescription',
          thumbnail: 'defaultIpfsImage',
        }),
      )

    t('Display resolver reset (there was a typo)')

    // There was a typo in the titleField. Let's fix it.
    await bob.metadataViewsAdmin
      .set_ipfs_display_resolver({
        nameField: 'name',
        defaultName: 'defaultName',
        descriptionField: 'description',
        defaultDescription: 'defaultDescription',
        imageField: 'ipfsImage',
        defaultImagePrefix: 'ipfs://',
        defaultImage: 'defaultIpfsImage',
      })
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.display(0)
      .then(
        checkScriptValue({
          name: 'Template 2',
          description: 'defaultDescription',
          thumbnail: 'defaultIpfsImage',
        }),
      )

    t('Display resolver removed')

    // Remove the display resolver
    await bob.metadataViewsAdmin
      .remove_ipfs_display_resolver({})
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.display(60)
      .then(checkScriptFailed)

    //   // NFT Collection Data resolver should be null to start with
    //   await q.nfts.x
    //     .collection({ collectorAddress: addressBook.carol })
    //     .info.collection_data(60)
    //     .then(checkScriptFailed)

    //   // Configure a collection data resolver
    //   await bob.metadataViewsAdmin.set_collection_data_resolver({}).wait()
    //   await q.nfts.x
    //     .collection({ collectorAddress: addressBook.carol })
    //     .info.collection_data(60)
    //     .then(
    //       checkScriptValue({
    //         storagePath: '/storage/NiftoryTemplate_nft_collection',
    //         publicPath: '/public/NiftoryTemplate_nft_collection',
    //         providerPath: '/private/NiftoryTemplate_nft_collection',
    //       }),
    //     )

    //   // Remove the collection data resolver
    //   await bob.metadataViewsAdmin
    //     .remove_collection_data_resolver({})
    //     .do(checkSuccessfulTransactions(1))
    //     .wait()
    //   await q.nfts.x
    //     .collection({ collectorAddress: addressBook.carol })
    //     .info.collection_data(60)
    //     .then(checkScriptFailed)
  })
})
