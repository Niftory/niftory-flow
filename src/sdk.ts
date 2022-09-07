import { AnyActor, newContext } from './actor'
import { execute, numberDecoder } from './script'

const context = newContext()
const noArg =
  <F>(fn: (_empty: {}) => F) =>
  () =>
    fn({})

// =============================================================================

type ContractAccountConfig = {}

class ContractAccount extends AnyActor<ContractAccountConfig, ContractAccount> {
  getThis = (_) => new ContractAccount(_)
  deployNonFungibleToken = noArg(this.deploy('NonFungibleToken'))
  deployMetadataViews = noArg(this.deploy('MetadataViews'))

  deployMutableMetadata = noArg(this.deploy('MutableMetadata'))
  deployMutableMetadataTemplate = noArg(this.deploy('MutableMetadataTemplate'))
  deployMutableMetadataSet = noArg(this.deploy('MutableMetadataSet'))
  deployMutableMetadataSetManager = noArg(
    this.deploy('MutableMetadataSetManager'),
  )

  deployMetadataViewsManager = noArg(this.deploy('MetadataViewsManager'))
  deployNiftoryNonFungibleToken = noArg(this.deploy('NiftoryNonFungibleToken'))
  deployNiftoryMetadataViewsResolvers = noArg(
    this.deploy('NiftoryMetadataViewsResolvers'),
  )
}

const contractAccount = (name: string): ContractAccount =>
  new ContractAccount({ name, context, config: {} })

// =============================================================================

type BrandManagerConfig = {}

class BrandManager extends AnyActor<BrandManagerConfig, BrandManager> {
  getThis = (_) => new BrandManager(_)
  deployNFTContract = noArg(this.deploy('NiftoryTemplate'))
}

const brandManager = (name: string): BrandManager =>
  new BrandManager({ name, context, config: {} })

// =============================================================================

type NiftoryAdminConfig = {}

class NiftoryAdmin extends AnyActor<NiftoryAdminConfig, NiftoryAdmin> {
  getThis = (_) => new NiftoryAdmin(_)
  deployNFTRegistry = noArg(this.deploy('NiftoryNFTRegistry'))
  initialize = this.send<{}>('niftory_admin/initialize')
  register_brand = this.send<{ brand: string; contractAddress: string }>(
    'niftory_admin/register_brand',
    (_) => [_.contractAddress, _.brand],
  )
  deregister_brand = this.send<{ brand: string }>(
    'niftory_admin/deregister_brand',
    (_) => [_.brand],
  )
}

const niftoryAdmin = (name: string): NiftoryAdmin =>
  new NiftoryAdmin({ name, context, config: {} })

// =============================================================================

type SetManagerAdminConfig = {
  registryAddress: string
  brand: string
}

class SetManagerAdmin extends AnyActor<SetManagerAdminConfig, SetManagerAdmin> {
  getThis = (_) => new SetManagerAdmin(_)
  initialize = this.send<{ name: string; description: string }>(
    'set_manager_admin/initialize',
    (_) => [_.registryAddress, _.brand, _.name, _.description],
  )
  set_name = this.send<{ name: string }>('set_manager_admin/set_name', (_) => [
    _.registryAddress,
    _.brand,
    _.name,
  ])
  set_description = this.send<{ description: string }>(
    'set_manager_admin/set_description',
    (_) => [_.registryAddress, _.brand, _.description],
  )
  add_set = this.send<{
    initialMetadata: { [key: string]: string }
  }>('set_manager_admin/add_set', (_) => [
    _.registryAddress,
    _.brand,
    _.initialMetadata,
  ])
  mint = this.send<{
    setId: number
    templateId: number
    collectorAddress: string
  }>('template_admin/mint', (_) => [
    _.registryAddress,
    _.brand,
    _.setId,
    _.templateId,
    _.collectorAddress,
  ])
  mint_bulk = this.send<{
    setId: number
    templateId: number
    collectorAddress: string
    numToMint: number
  }>('template_admin/mint_bulk', (_) => [
    _.registryAddress,
    _.brand,
    _.setId,
    _.templateId,
    _.collectorAddress,
    _.numToMint,
  ])
}

const setManagerAdmin = (
  name: string,
  registryAddress: string,
  brand: string,
): SetManagerAdmin =>
  new SetManagerAdmin({ name, context, config: { registryAddress, brand } })

// =============================================================================

type MetadataViewsManagerAdminConfig = {
  registryAddress: string
  brand: string
}

class MetadataViewsManagerAdmin extends AnyActor<
  MetadataViewsManagerAdminConfig,
  MetadataViewsManagerAdmin
> {
  getThis = (_) => new MetadataViewsManagerAdmin(_)
  set_royalty_resolver = this.send<{
    receiverAddress: string
    receiverPath: string
    cut: string
    description: string
  }>('metadataviews_manager_admin/royalties/set', (_) => [
    _.registryAddress,
    _.brand,
    _.receiverAddress,
    _.receiverPath,
    _.cut,
    _.description,
  ])
  set_ipfs_display_resolver = this.send<{
    nameField: string
    defaultName: string
    descriptionField: string
    defaultDescription: string
    imageField: string
    defaultImagePrefix: string
    defaultImage: string
  }>('metadataviews_manager_admin/ipfs_display/set', (_) => [
    _.registryAddress,
    _.brand,
    _.nameField,
    _.defaultName,
    _.descriptionField,
    _.defaultDescription,
    _.imageField,
    _.defaultImagePrefix,
    _.defaultImage,
  ])
  set_collection_data_resolver = this.send<{}>(
    'metadataviews_manager_admin/collection_data/set',
    (_) => [_.registryAddress, _.brand],
  )
  remove_collection_data_resolver = this.send<{}>(
    'metadataviews_manager_admin/collection_data/remove',
    (_) => [_.registryAddress, _.brand],
  )
  remove_ipfs_display_resolver = this.send<{}>(
    'metadataviews_manager_admin/ipfs_display/remove',

    (_) => [_.registryAddress, _.brand],
  )
  remove_royalty_resolver = this.send<{}>(
    'metadataviews_manager_admin/royalties/remove',
    (_) => [_.registryAddress, _.brand],
  )
}

const metadataViewsManagerAdmin = (
  name: string,
  registryAddress: string,
  brand: string,
): MetadataViewsManagerAdmin =>
  new MetadataViewsManagerAdmin({
    name,
    context,
    config: { registryAddress, brand },
  })

// =============================================================================

type SetAdminConfig = {
  registryAddress: string
  brand: string
  setId: number
}

class SetAdmin extends AnyActor<SetAdminConfig, SetAdmin> {
  getThis = (_) => new SetAdmin(_)
  add_template = this.send<{
    initialMetadata: { [key: string]: string }
    maxMint?: number
  }>('set_admin/add_template', (_) => [
    _.registryAddress,
    _.brand,
    _.setId,
    _.initialMetadata,
    _.maxMint,
  ])

  lock = noArg(
    this.send('set_admin/lock', (_) => [_.registryAddress, _.brand, _.setId]),
  )
}

const setAdmin = (
  name: string,
  registryAddress: string,
  brand: string,
  setId: number,
): SetAdmin =>
  new SetAdmin({ name, context, config: { registryAddress, brand, setId } })

// =============================================================================

type TemplateAdminConfig = {
  registryAddress: string
  brand: string
  setId: number
  templateId: number
}

class TemplateAdmin extends AnyActor<TemplateAdminConfig, TemplateAdmin> {
  getThis = (_) => new TemplateAdmin(_)
  lock_template = noArg(
    this.send('template_admin/lock', (_) => [
      _.registryAddress,
      _.brand,
      _.setId,
      _.templateId,
    ]),
  )
  lock_metadata = noArg(
    this.send('metadata_admin/lock', (_) => [
      _.registryAddress,
      _.brand,
      _.setId,
      _.templateId,
    ]),
  )
  delete_field = this.send<{ key: string }>(
    'metadata_admin/delete_field',
    (_) => [_.registryAddress, _.brand, _.setId, _.templateId, _.key],
  )
  set_field = this.send<{ key: string; value: string }>(
    'metadata_admin/set_field',
    (_) => [_.registryAddress, _.brand, _.setId, _.templateId, _.key, _.value],
  )
  replace_metadata = this.send<{ metadata: { [key: string]: string } }>(
    'metadata_admin/replace_metadata',
    (_) => [_.registryAddress, _.brand, _.setId, _.templateId, _.metadata],
  )
}

const templateAdmin = (
  name: string,
  registryAddress: string,
  brand: string,
  setId: number,
  templateId: number,
): TemplateAdmin =>
  new TemplateAdmin({
    name,
    context,
    config: { registryAddress, brand, setId, templateId },
  })

// =============================================================================

type CollectorConfig = {
  registryAddress: string
  brand: string
}

class Collector extends AnyActor<CollectorConfig, Collector> {
  getThis = (_) => new Collector(_)
  initialize = this.send<{}>('collector/initialize', (_) => [
    _.registryAddress,
    _.brand,
  ])
  transfer = this.send<{
    recipientAddress: string
    id: number
  }>('collector/transfer', (_) => [
    _.registryAddress,
    _.brand,
    _.recipientAddress,
    _.id,
  ])
  transfer_bulk = this.send<{
    recipientAddress: string
    ids: number[]
  }>('collector/transfer_bulk', (_) => [
    _.registryAddress,
    _.brand,
    _.recipientAddress,
    _.ids,
  ])
}

const collector = (
  name: string,
  registryAddress: string,
  brand: string,
): Collector =>
  new Collector({ name, context, config: { registryAddress, brand } })

// =============================================================================

const flow = () => ({
  get_supply: () =>
    execute({
      codePath: 'flow/get_supply',
      decoder: numberDecoder,
    }),
  get_balance: (address: string) =>
    execute({
      codePath: 'flow/get_balance',
      args: [address],
      decoder: numberDecoder,
    }),
})

const niftory = (address: string) => ({
  brands: () =>
    execute({
      codePath: 'niftory/brands',
      args: [address],
      decoder: (data: any) => data,
    }),
})

const mutable_set_manager = (registryAddress: string, brand: string) => ({
  info: () =>
    execute({
      codePath: 'mutable_set_manager/info',
      args: [registryAddress, brand],
      decoder: (data: any) => ({
        name: data.name as string,
        description: data.description as string,
        numSets: Number(data.numSets),
      }),
    }),
})

const mutable_set = (
  registryAddress: string,
  brand: string,
  setId: number,
) => ({
  info: () =>
    execute({
      codePath: 'mutable_set/info',
      args: [registryAddress, brand, setId],
      decoder: (data: any) => ({
        locked: Boolean(data.locked),
        metadataLocked: Boolean(data.metadataLocked),
        numTemplates: Number(data.numTemplates),
        metadata: data.metadata as { [key: string]: string },
      }),
    }),
})

const mutable_metadata = (
  registryAddress: string,
  brand: string,
  setId: number,
  templateId: number,
) => ({
  info: () =>
    execute({
      codePath: 'mutable_metadata/info',
      args: [registryAddress, brand, setId, templateId],
      decoder: (data: any) => ({
        locked: Boolean(data.locked),
        metadataLocked: Boolean(data.metadataLocked),
        metadata: data.metadata as { [key: string]: string },
        maxMint: data.maxMint ? Number(data.maxMint) : undefined,
        minted: Number(data.minted),
      }),
    }),
})

const collection = (
  registryAddress: string,
  brand: string,
  collectionAddress: string,
) => ({
  info: () =>
    execute({
      codePath: 'collection/info',
      args: [registryAddress, brand, collectionAddress],
      decoder: (data: any) => ({
        numNfts: Number(data.numNfts),
        nftIds: new Set<number>(data.nftIds),
      }),
    }),
  nft: (id: number) =>
    execute({
      codePath: 'collection/nft',
      args: [registryAddress, brand, collectionAddress, id],
      decoder: (data: any) => ({
        id: Number(data.id),
        serial: Number(data.serial),
        setId: Number(data.setId),
        templateId: Number(data.templateId),
        metadata: data.metadata as { [key: string]: string },
        setMetadata: data.setMetadata as { [key: string]: string },
        views: data.views as string[],
      }),
    }),
  royalty: (id: number) =>
    execute({
      codePath: 'collection/metadata_views/royalty',
      args: [registryAddress, brand, collectionAddress, id],
      decoder: (data: any) => ({
        token: data.token as string,
        cut: Number(data.cut),
        description: data.description as string,
      }),
    }),
  display: (id: number) =>
    execute({
      codePath: 'collection/metadata_views/display',
      args: [registryAddress, brand, collectionAddress, id],
      decoder: (data: any) => ({
        name: data.name as string,
        description: data.description as string,
        thumbnail: data.thumbnail as string,
      }),
    }),
  collection_data: (id: number) =>
    execute({
      codePath: 'collection/metadata_views/collection_data',
      args: [registryAddress, brand, collectionAddress, id],
      decoder: (data: any) => ({
        storagePath: data.storagePath as string,
        publicPath: data.publicPath as string,
        providerPath: data.providerPath as string,
      }),
    }),
})

export {
  niftoryAdmin,
  contractAccount,
  brandManager,
  setManagerAdmin,
  setAdmin,
  templateAdmin,
  niftory,
  collector,
  metadataViewsManagerAdmin,
  flow,
  mutable_set_manager,
  mutable_set,
  mutable_metadata,
  collection,
}
