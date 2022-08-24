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
  register_brand = this.send<{ brand: string }>(
    'niftory_admin/register_brand',
    (_) => [_.brand],
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
  path: string
}

class SetManagerAdmin extends AnyActor<SetManagerAdminConfig, SetManagerAdmin> {
  getThis = (_) => new SetManagerAdmin(_)
  initialize = this.send<{ name: string; description: string }>(
    'set_manager_admin/initialize',
    (_) => [_.path, _.name, _.description],
  )
  set_name = this.send<{ name: string }>('set_manager_admin/set_name', (_) => [
    _.path,
    _.name,
  ])
  set_description = this.send<{ description: string }>(
    'set_manager_admin/set_description',
    (_) => [_.path, _.description],
  )
  add_set = this.send<{
    initialMetadata: { [key: string]: string }
  }>('set_manager_admin/add_set', (_) => [_.path, _.initialMetadata])
  mint = this.send<{
    setId: number
    templateId: number
    collector: string
    collectionPath: string
  }>('set_manager_admin/mint', (_) => [
    _.setId,
    _.templateId,
    _.collector,
    _.collectionPath,
  ])
  mint_bulk = this.send<{
    setId: number
    templateId: number
    collector: string
    collectionPath: string
    numToMint: number
  }>('set_manager_admin/mint_bulk', (_) => [
    _.setId,
    _.templateId,
    _.collector,
    _.collectionPath,
    _.numToMint,
  ])
}

const setManagerAdmin = (name: string, path: string): SetManagerAdmin =>
  new SetManagerAdmin({ name, context, config: { path } })

// =============================================================================

type MetadataViewsManagerAdminConfig = {
  path: string
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
  }>('metadataviews_manager_admin/set_royalty_resolver', (_) => [
    _.path,
    _.receiverAddress,
    _.receiverPath,
    _.cut,
    _.description,
  ])
  set_ipfs_display_resolver = this.send<{
    titleField: string
    descriptionField: string
    ipfsImageField: string
    defaultTitle: string
    defaultDescription: string
    defaultIpfsImage: string
  }>('metadataviews_manager_admin/set_ipfs_display_resolver', (_) => [
    _.path,
    _.titleField,
    _.descriptionField,
    _.ipfsImageField,
    _.defaultTitle,
    _.defaultDescription,
    _.defaultIpfsImage,
  ])
  set_collection_data_resolver = this.send<{}>(
    'metadataviews_manager_admin/set_collection_data_resolver',
    (_) => [_.path],
  )
  remove_collection_data_resolver = this.send<{}>(
    'metadataviews_manager_admin/remove_collection_data_resolver',
    (_) => [_.path],
  )
  remove_ipfs_display_resolver = this.send<{}>(
    'metadataviews_manager_admin/remove_ipfs_display_resolver',
    (_) => [_.path],
  )
  remove_royalty_resolver = this.send<{}>(
    'metadataviews_manager_admin/remove_royalty_resolver',
    (_) => [_.path],
  )
}

const metadataViewsManagerAdmin = (
  name: string,
  path: string,
): MetadataViewsManagerAdmin =>
  new MetadataViewsManagerAdmin({ name, context, config: { path } })

// =============================================================================

type SetAdminConfig = {
  path: string
  setId: number
}

class SetAdmin extends AnyActor<SetAdminConfig, SetAdmin> {
  getThis = (_) => new SetAdmin(_)
  add_template = this.send<{
    initialMetadata: { [key: string]: string }
    maxMint?: number
  }>('set_admin/add_template', (_) => [
    _.path,
    _.setId,
    _.initialMetadata,
    _.maxMint,
  ])

  lock = noArg(this.send('set_admin/lock', (_) => [_.path, _.setId]))
}

const setAdmin = (name: string, path: string, setId: number): SetAdmin =>
  new SetAdmin({ name, context, config: { path, setId } })

// =============================================================================

type TemplateAdminConfig = {
  path: string
  setId: number
  templateId: number
}

class TemplateAdmin extends AnyActor<TemplateAdminConfig, TemplateAdmin> {
  getThis = (_) => new TemplateAdmin(_)
  lock_template = noArg(
    this.send('template_admin/lock_template', (_) => [
      _.path,
      _.setId,
      _.templateId,
    ]),
  )
  lock_metadata = noArg(
    this.send('template_admin/lock_metadata', (_) => [
      _.path,
      _.setId,
      _.templateId,
    ]),
  )
  delete_field = this.send<{ key: string }>(
    'template_admin/delete_field',
    (_) => [_.path, _.setId, _.templateId, _.key],
  )
  set_field = this.send<{ key: string; value: string }>(
    'template_admin/set_field',
    (_) => [_.path, _.setId, _.templateId, _.key, _.value],
  )
  replace_metadata = this.send<{ metadata: { [key: string]: string } }>(
    'template_admin/replace_metadata',
    (_) => [_.path, _.setId, _.templateId, _.metadata],
  )
}

const templateAdmin = (
  name: string,
  path: string,
  setId: number,
  templateId: number,
): TemplateAdmin =>
  new TemplateAdmin({ name, context, config: { path, setId, templateId } })

// =============================================================================

type CollectorConfig = {}

class Collector extends AnyActor<CollectorConfig, Collector> {
  getThis = (_) => new Collector(_)
  initialize = noArg(this.send('collector/initialize'))
  transfer = this.send<{
    recipient: string
    collectionPath: string
    ids: number[]
  }>('collector/transfer', (_) => [_.recipient, _.collectionPath, _.ids])
}

const collector = (name: string): Collector =>
  new Collector({ name, context, config: {} })

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

const mutable_set = (address: string, path: string, setId: number) => ({
  info: () =>
    execute({
      codePath: 'mutable_set/info',
      args: [address, path, setId],
      decoder: (data: any) => ({
        locked: Boolean(data.locked),
        metadataLocked: Boolean(data.metadataLocked),
        numTemplates: Number(data.numTemplates),
        metadata: data.metadata as { [key: string]: string },
      }),
    }),
})

const mutable_metadata = (
  address: string,
  path: string,
  setId: number,
  templateId: number,
) => ({
  info: () =>
    execute({
      codePath: 'mutable_metadata/info',
      args: [address, path, setId, templateId],
      decoder: (data: any) => ({
        locked: Boolean(data.locked),
        metadataLocked: Boolean(data.metadataLocked),
        metadata: data.metadata as { [key: string]: string },
        maxMint: data.maxMint ? Number(data.maxMint) : undefined,
        minted: Number(data.minted),
      }),
    }),
})

const collection = (address: string, path: string) => ({
  info: () =>
    execute({
      codePath: 'collection/info',
      args: [address, path],
      decoder: (data: any) => ({
        numNfts: Number(data.numNfts),
        nftIds: new Set<number>(data.nftIds),
      }),
    }),
  nft: (id: number) =>
    execute({
      codePath: 'collection/nft',
      args: [address, path, id],
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
      codePath: 'collection/royalty',
      args: [address, path, id],
      decoder: (data: any) => ({
        token: data.token as string,
        receiverPath: data.receiverPath as string,
        cut: Number(data.cut),
        description: data.description as string,
      }),
    }),
  display: (id: number) =>
    execute({
      codePath: 'collection/display',
      args: [address, path, id],
      decoder: (data: any) => ({
        name: data.name as string,
        description: data.description as string,
        thumbnail: data.thumbnail as string,
      }),
    }),
  collection_data: (id: number) =>
    execute({
      codePath: 'collection/collection_data',
      args: [address, path, id],
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
