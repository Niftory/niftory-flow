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
} from '../src/sdk'
import {
  assertScriptValue,
  checkContextAlive,
  checkContextDead,
  checkScriptFailed,
  checkScriptSucceeded,
  checkScriptValue,
  checkSkippedTransactions,
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
        'ExampleNFT_setmanager',
      ),
      metadataViewsAdmin: metadataViewsManagerAdmin(
        BRAND_MANAGER_BOB,
        'ExampleNFT_setmanager',
      ),
      set: ({ setId }: { setId: number }) => ({
        admin: setAdmin(BRAND_MANAGER_BOB, 'ExampleNFT_setmanager', setId),
        template: ({ templateId }: { templateId: number }) => ({
          admin: templateAdmin(
            BRAND_MANAGER_BOB,
            'ExampleNFT_setmanager',
            setId,
            templateId,
          ),
        }),
      }),
      deployer: brandManager(BRAND_MANAGER_BOB),
    }

    const carol = {
      collector: collector(COLLECTOR_CAROL),
    }

    const charlie = {
      collector: collector(COLLECTOR_CHARLIE),
    }

    const q = {
      nfts: {
        x: {
          setManager: mutable_set_manager(
            addressBook.bob,
            'ExampleNFT_setmanager',
          ),
          set: ({ setId }: { setId: number }) => ({
            info: mutable_set(addressBook.bob, 'ExampleNFT_setmanager', setId),
            template: ({ templateId }: { templateId: number }) => ({
              info: mutable_metadata(
                addressBook.bob,
                'ExampleNFT_setmanager',
                setId,
                templateId,
              ),
            }),
          }),
          collection: ({ collectorAddress }: { collectorAddress: string }) => ({
            info: collection(collectorAddress, 'ExampleNFT_collection'),
          }),
        },
      },
      niftory: niftory(addressBook.alice),
    }

    // ================================

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
      .deployMutableSet()
      .deployMutableSetManager()
      .deployMetadataViewsManager()
      .deployNiftory()
      .do(checkContextAlive)
      .do(checkSuccessfulTransactions(8))
      .wait()

    await alice.niftoryAdmin
      .deployNFTRegistry()
      .initialize({})
      .register_brand({ brand: 'ExampleNFT' })
      .wait()
    await q.niftory.brands().then(checkScriptSucceeded)

    // Our first attempt to fetch info fails because it's not initialized
    await q.nfts.x.setManager.info().then(checkScriptFailed)

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
          name: 'XXTEMPLATEXX',
          description: 'The set manager for XXTEMPLATEXX.',
          numSets: 0,
        }),
      )

    // Bob will change the name and description of the set manager
    await bob.setManagerAdmin
      .set_name({ name: 'Set Manager 2' })
      .set_description({ description: 'This is a mutable set manager' })
      .do(checkSuccessfulTransactions(2))
      .wait()
    await q.nfts.x.setManager
      .info()
      .then(checkScriptSucceeded)
      .then(
        checkScriptValue({
          name: 'Set Manager 2',
          description: 'This is a mutable set manager',
          numSets: 0,
        }),
      )

    // Bob will add three empty sets to the set manager
    await bob.setManagerAdmin
      .add_set({ initialMetadata: { name: 'Set 1' } })
      .add_set({ initialMetadata: { name: 'Set 2' } })
      .add_set({ initialMetadata: { name: 'Set 3' } })
      .do(checkSuccessfulTransactions(3))
      .wait()
    await q.nfts.x.setManager
      .info()
      .then(checkScriptSucceeded)
      .then(
        checkScriptValue({
          name: 'Set Manager 2',
          description: 'This is a mutable set manager',
          numSets: 3,
        }),
      )

    // Let's make sure the first set was initialized correctly
    await q.nfts.x
      .set({ setId: 0 })
      .info.info()
      .then(
        assertScriptValue(
          ({ locked, metadataLocked, metadata, numTemplates }) =>
            !locked &&
            !metadataLocked &&
            metadata['name'] === 'Set 1' &&
            numTemplates == 0,
        ),
      )

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

    // Locking the set should stop Bob from adding templates
    await bob
      .set({ setId: 0 })
      .admin.lock()
      .do(checkSuccessfulTransactions(1))
      .wait()

    await bob
      .set({ setId: 0 })
      .admin.add_template({ initialMetadata: { name: 'Template 4' } })
      .add_template({ initialMetadata: { name: 'Template 5' }, maxMint: 5 })
      .add_template({ initialMetadata: { name: 'Template 6' }, maxMint: 10 })
      .do(checkContextDead)
      .do(checkSkippedTransactions(3))
      .do(checkSuccessfulTransactions(0))
      .wait()
    await q.nfts.x
      .set({ setId: 0 })
      .info.info()
      .then(
        assertScriptValue(
          ({ locked, metadataLocked, metadata, numTemplates }) =>
            locked &&
            !metadataLocked &&
            metadata['name'] === 'Set 1' &&
            numTemplates == 3,
        ),
      )

    // Let's take a look at the first two templates
    await q.nfts.x
      .set({ setId: 0 })
      .template({ templateId: 0 })
      .info.info()
      .then(
        assertScriptValue(
          ({ locked, metadataLocked, metadata, maxMint, minted }) =>
            !locked &&
            !metadataLocked &&
            metadata['name'] === 'Template 1' &&
            maxMint == undefined &&
            minted == 0,
        ),
      )
    await q.nfts.x
      .set({ setId: 0 })
      .template({ templateId: 1 })
      .info.info()
      .then(
        assertScriptValue(
          ({ locked, metadataLocked, metadata, maxMint, minted }) =>
            !locked &&
            !metadataLocked &&
            metadata['name'] === 'Template 2' &&
            maxMint == 5 &&
            minted == 0,
        ),
      )

    // Bob will try modifying the metadata of the first template using
    // various methods
    await bob
      .set({ setId: 0 })
      .template({ templateId: 0 })
      .admin.set_field({ key: 'key1', value: 'value1' })
      .set_field({ key: 'key2', value: 'value2' })
      .set_field({ key: 'key3', value: 'value3' })
      .delete_field({ key: 'key2' })
      .do(checkSuccessfulTransactions(4))
      .wait()
    await q.nfts.x
      .set({ setId: 0 })
      .template({ templateId: 0 })
      .info.info()
      .then(
        assertScriptValue(
          ({ metadata }) =>
            isSubset({ key1: 'value1', key3: 'value3' }, metadata) &&
            !isSubset({ key2: 'value2' }, metadata),
        ),
      )
    await bob
      .set({ setId: 0 })
      .template({ templateId: 0 })
      .admin.replace_metadata({
        metadata: {
          KEY1: 'VALUE1',
          KEY2: 'VALUE2',
          KEY3: 'VALUE3',
        },
      })
      .delete_field({ key: 'KEY2' })
      .do(checkSuccessfulTransactions(2))
      .wait()
    await q.nfts.x
      .set({ setId: 0 })
      .template({ templateId: 0 })
      .info.info()
      .then(
        assertScriptValue(
          ({ metadata }) =>
            isSubset({ KEY1: 'VALUE1', KEY3: 'VALUE3' }, metadata) &&
            !isSubset({ KEY2: 'VALUE2' }, metadata),
        ),
      )

    // Bob should not be able to modify the metadata any more
    // after trying to lock the set.
    await bob
      .set({ setId: 0 })
      .template({ templateId: 0 })
      .admin.lock_metadata()
      .set_field({ key: 'key1', value: 'value1' })
      .do(checkContextDead)
      .do(checkSkippedTransactions(1))
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x
      .set({ setId: 0 })
      .template({ templateId: 0 })
      .info.info()
      .then(
        assertScriptValue(
          ({ metadataLocked, metadata }) =>
            metadataLocked && !isSubset({ key1: 'value1' }, metadata),
        ),
      )

    // Carol and Charlie will initialize their NFT Collections.
    // They should have zero NFTs to start with
    await carol.collector.initialize().do(checkSuccessfulTransactions(1)).wait()
    await charlie.collector
      .initialize()
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.info()
      .then(
        checkScriptValue({
          numNfts: 0,
          nftIds: new Set<number>([]),
        }),
      )
    await q.nfts.x
      .collection({ collectorAddress: addressBook.charlie })
      .info.info()
      .then(
        checkScriptValue({
          numNfts: 0,
          nftIds: new Set<number>([]),
        }),
      )

    // Bob will mint 50 NFTs for the first template to Carol, and 10 to Charlie.
    await bob.setManagerAdmin
      .mint({
        setId: 0,
        templateId: 0,
        collector: addressBook.carol,
        collectionPath: 'ExampleNFT_collection',
      })
      .mint({
        setId: 0,
        templateId: 0,
        collector: addressBook.carol,
        collectionPath: 'ExampleNFT_collection',
      })
      .do(checkSuccessfulTransactions(2))
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.info()
      .then(
        checkScriptValue({
          numNfts: 2,
          nftIds: new Set([0, 1]),
        }),
      )

    await bob.setManagerAdmin
      .mint_bulk({
        setId: 0,
        templateId: 0,
        collector: addressBook.carol,
        collectionPath: 'ExampleNFT_collection',
        numToMint: 10,
      })
      .mint({
        setId: 0,
        templateId: 0,
        collector: addressBook.charlie,
        collectionPath: 'ExampleNFT_collection',
      })
      .mint({
        setId: 0,
        templateId: 0,
        collector: addressBook.carol,
        collectionPath: 'ExampleNFT_collection',
      })
      .mint_bulk({
        setId: 0,
        templateId: 0,
        collector: addressBook.charlie,
        collectionPath: 'ExampleNFT_collection',
        numToMint: 9,
      })
      .mint_bulk({
        setId: 0,
        templateId: 0,
        collector: addressBook.carol,
        collectionPath: 'ExampleNFT_collection',
        numToMint: 19,
      })
      .mint_bulk({
        setId: 0,
        templateId: 0,
        collector: addressBook.carol,
        collectionPath: 'ExampleNFT_collection',
        numToMint: 18,
      })
      .do(checkContextAlive)
      .do(checkSuccessfulTransactions(6))
      .log()
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.info()
      .then(
        assertScriptValue(
          (actual) => actual.numNfts == 50 && actual.nftIds.has(59),
        ),
      )
    await q.nfts.x
      .collection({ collectorAddress: addressBook.charlie })
      .info.info()
      .then(
        checkScriptValue({
          numNfts: 10,
          nftIds: new Set([12, 14, 15, 16, 17, 18, 19, 20, 21, 22]),
        }),
      )
    await q.nfts.x
      .set({ setId: 0 })
      .template({ templateId: 0 })
      .info.info()
      .then(
        assertScriptValue(
          ({ locked, maxMint, minted }) =>
            !locked && maxMint == undefined && minted == 60,
        ),
      )

    // Bob will lock first template and should not be able to mint any more
    await bob
      .set({ setId: 0 })
      .template({ templateId: 0 })
      .admin.lock_template()
      .do(checkSuccessfulTransactions(1))
      .wait()
    await bob.setManagerAdmin
      .mint({
        setId: 0,
        templateId: 0,
        collector: addressBook.charlie,
        collectionPath: 'ExampleNFT_collection',
      })
      .do(checkContextDead)
      .wait()
    await q.nfts.x
      .set({ setId: 0 })
      .template({ templateId: 0 })
      .info.info()
      .then(assertScriptValue(({ locked, minted }) => locked && minted == 60))

    // Bob will now try to mint 6 NFTs for the second template. The first
    // five should be minted successfully, but the sixth should fail because
    // the limit will have been reached.
    await bob.setManagerAdmin
      .mint_bulk({
        setId: 0,
        templateId: 1,
        collector: addressBook.carol,
        collectionPath: 'ExampleNFT_collection',
        numToMint: 5,
      })
      .do(checkSuccessfulTransactions(1))
      .wait()
    await bob.setManagerAdmin
      .mint({
        setId: 0,
        templateId: 1,
        collector: addressBook.carol,
        collectionPath: 'ExampleNFT_collection',
      })
      .do(checkContextDead)
      .wait()
    await q.nfts.x
      .set({ setId: 0 })
      .template({ templateId: 1 })
      .info.info()
      .then(
        assertScriptValue(
          ({ locked, maxMint, minted }) =>
            !locked && maxMint == 5 && minted == 5,
        ),
      )

    // Bob will now try to mint 5 NFTs for the third template and lock it.
    // Even though the limit hasn't been reached, he should not be able
    // to mint from it anymore.
    await bob.setManagerAdmin
      .mint_bulk({
        setId: 0,
        templateId: 2,
        collector: addressBook.carol,
        collectionPath: 'ExampleNFT_collection',
        numToMint: 5,
      })
      .do(checkSuccessfulTransactions(1))
      .wait()
    await bob
      .set({ setId: 0 })
      .template({ templateId: 2 })
      .admin.lock_template()
      .do(checkSuccessfulTransactions(1))
      .wait()
    await bob.setManagerAdmin
      .mint({
        setId: 0,
        templateId: 2,
        collector: addressBook.carol,
        collectionPath: 'ExampleNFT_collection',
      })
      .do(checkContextDead)
      .wait()
    await q.nfts.x
      .set({ setId: 0 })
      .template({ templateId: 2 })
      .info.info()
      .then(
        assertScriptValue(
          ({ locked, maxMint, minted }) =>
            locked && maxMint == 10 && minted == 5,
        ),
      )

    // Carol will transfer 10 NFTs to Charlie.
    await carol.collector
      .transfer({
        recipient: addressBook.charlie,
        collectionPath: 'ExampleNFT_collection',
        ids: [30, 31, 32, 33, 34, 35, 36, 37, 38, 39],
      })
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.charlie })
      .info.info()
      .then(assertScriptValue((collection) => collection.numNfts == 20))

    // Carol can't transfer what she doesn't have
    await carol.collector
      .transfer({
        recipient: addressBook.charlie,
        collectionPath: 'ExampleNFT_collection',
        ids: [30],
      })
      .do(checkContextDead)
      .wait()

    // Let's inspect one of Carol's NFTs for template 2,
    // before and after Bob changes the metadata for it.
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.nft(60)
      .then(
        checkScriptValue({
          id: 60,
          serial: 1,
          setId: 0,
          templateId: 1,
          metadata: { name: 'Template 2' } as { [key: string]: string },
          setMetadata: { name: 'Set 1' } as { [key: string]: string },
          views: [] as string[],
        }),
      )
    await bob
      .set({ setId: 0 })
      .template({ templateId: 1 })
      .admin.set_field({ key: 'key', value: 'value' })
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.nft(60)
      .then(
        checkScriptValue({
          id: 60,
          serial: 1,
          setId: 0,
          templateId: 1,
          metadata: { name: 'Template 2', key: 'value' } as {
            [key: string]: string
          },
          setMetadata: { name: 'Set 1' } as { [key: string]: string },
          views: [] as string[],
        }),
      )

    // For the below section, we will look at the MetadataViews standard
    // metadata interface. Bob will configure generic resolvers for
    // his brand. In the below section, for each resolver, we will inspect
    // each resolver before and after Bob adds it. We will inspect it once
    // more after Bob removes it.

    // Royalty resolver should be null to start with
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.royalty(60)
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
      .info.royalty(60)
      .then(
        checkScriptValue({
          token: 'A.0ae53cb6e3f42a79.FlowToken.Vault',
          receiverPath: '/public/ExampleNFT_collection',
          cut: 0.05,
          description: 'royalty for xx',
        }),
      )

    // Remove the royalty resolver
    await bob.metadataViewsAdmin
      .remove_royalty_resolver({})
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.royalty(60)
      .then(checkScriptFailed)

    // Display resolver should be null to start with
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.display(60)
      .then(checkScriptFailed)

    // Configure a display resolver
    await bob.metadataViewsAdmin
      .set_ipfs_display_resolver({
        titleField: 'nam',
        descriptionField: 'description',
        ipfsImageField: 'ipfsImage',
        defaultTitle: 'defaultTitle',
        defaultDescription: 'defaultDescription',
        defaultIpfsImage: 'defaultIpfsImage',
      })
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.display(60)
      .then(
        checkScriptValue({
          name: 'defaultTitle',
          description: 'defaultDescription',
          thumbnail: 'defaultIpfsImage',
        }),
      )

    // There was a typo in the titleField. Let's fix it.
    await bob.metadataViewsAdmin
      .set_ipfs_display_resolver({
        titleField: 'name',
        descriptionField: 'description',
        ipfsImageField: 'ipfsImage',
        defaultTitle: 'defaultTitle',
        defaultDescription: 'defaultDescription',
        defaultIpfsImage: 'defaultIpfsImage',
      })
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.display(60)
      .then(
        checkScriptValue({
          name: 'Template 2',
          description: 'defaultDescription',
          thumbnail: 'defaultIpfsImage',
        }),
      )

    // Remove the display resolver
    await bob.metadataViewsAdmin
      .remove_ipfs_display_resolver({})
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.display(60)
      .then(checkScriptFailed)

    // NFT Collection Data resolver should be null to start with
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.collection_data(60)
      .then(checkScriptFailed)

    // Configure a collection data resolver
    await bob.metadataViewsAdmin.set_collection_data_resolver({}).wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.collection_data(60)
      .then(
        checkScriptValue({
          storagePath: '/storage/ExampleNFT_collection',
          publicPath: '/public/ExampleNFT_collection',
          providerPath: '/private/ExampleNFT_collection',
        }),
      )

    // Remove the collection data resolver
    await bob.metadataViewsAdmin
      .remove_collection_data_resolver({})
      .do(checkSuccessfulTransactions(1))
      .wait()
    await q.nfts.x
      .collection({ collectorAddress: addressBook.carol })
      .info.collection_data(60)
      .then(checkScriptFailed)
  })
})
