import { promises as fs } from 'fs'

type RawFragment = {
  _tag: 'RawFragment'
  code: string
}

type ImportFragment = {
  _tag: 'ImportFragment'
  identifier: string
}

type ExtraTokenFragment = {
  _tag: 'ExtraTokenFragment'
  identifier: string
}

type CodeFragment = RawFragment | ImportFragment | ExtraTokenFragment

const rawFragment = (code: string): CodeFragment => ({
  _tag: 'RawFragment',
  code,
})

const importFragment = (identifier: string): CodeFragment => ({
  _tag: 'ImportFragment',
  identifier,
})

const extraTokenFragment = (identifier: string): CodeFragment => ({
  _tag: 'ExtraTokenFragment',
  identifier,
})

type TemplateReplacementToken = {
  matchRegex: RegExp
  identifier: string
}

const trt = (
  matchRegex: RegExp,
  identifier: string,
): TemplateReplacementToken => ({
  matchRegex,
  identifier,
})

const IMPORT_REPLACEMENT_TOKENS: TemplateReplacementToken[] = [
  trt(/\/NonFungibleToken.cdc/, 'nonFungibleTokenAddress'),
  trt(/\/MetadataViews.cdc/, 'nonFungibleTokenAddress'),
  trt(/\/MutableMetadata.cdc/, 'niftoryContractAddress'),
  trt(/\/MutableMetadataTemplate.cdc/, 'niftoryContractAddress'),
  trt(/\/MutableMetadataSet.cdc/, 'niftoryContractAddress'),
  trt(/\/MutableMetadataSetManager.cdc/, 'niftoryContractAddress'),
  trt(/\/MetadataViewsManager.cdc/, 'niftoryContractAddress'),
  trt(/\/NiftoryNonFungibleToken.cdc/, 'niftoryContractAddress'),
  trt(/\/NiftoryNFTRegistry.cdc/, 'niftoryContractAddress'),
]

const ADDITIONAL_REPLACEMENT_TOKENS: TemplateReplacementToken[] = [
  trt(/NiftoryTemplate/, 'contractName'),
]

const DEPLOYER_CONTRACT_NAME = 'NiftoryNFTDeployer'
const CDC_FILE_REGEX = /"[^"]*\.cdc"/g
const INPUT_FILE = 'cadence/contracts/NiftoryTemplate.cdc'
const OUTPUT_FILE = `cadence/contracts/${DEPLOYER_CONTRACT_NAME}.cdc`

const utf8ToHex = (utf8: string) => Buffer.from(utf8, 'utf8').toString('hex')

const CONTRACT_HEADER = (contractName: string) =>
  `
pub contract ${contractName} {

  pub fun generateContractCode(
`.slice(1, -1)

const IMPORT_ARGUMENT = (identifier: string) =>
  `
    ${identifier}: Address,
`.slice(1)

const EXTRA_ARGUMENT = (identifier: string) =>
  `
    ${identifier}: String,
`.slice(1)

const BODY_HEADER = `
  ): [UInt8] {
    let code: [UInt8] = []
`.slice(1)

const RAW_CODE_APPEND = (fragment: number) =>
  `
    code.appendAll(self._FRAGMENT_${fragment}())
`.slice(1)

const IMPORT_CODE_APPEND = (identifier: string) =>
  `
    code.appendAll(${identifier}.toString().utf8)
`.slice(1)

const EXTRA_CODE_APPEND = (identifier: string) =>
  `
    code.appendAll(${identifier}.utf8)
`.slice(1)

const BODY_FOOTER = `
    return code
  }
`.slice(1)

const RAW_FRAGMENT = (fragment: number, code: string) => `
  access(self) fun _FRAGMENT_${fragment}(): [UInt8] {
    return "${utf8ToHex(code)}"
      .decodeHex()
  }
`

const CONTRACT_FOOTER = `
}
`.slice(1)

// Build the contract
const buildContract = (fragments: CodeFragment[]) => {
  const imports = [
    ...new Set(
      fragments.flatMap((fragment) =>
        fragment._tag === 'ImportFragment' ? [fragment.identifier] : [],
      ),
    ),
  ]
  const extraTokens = [
    ...new Set(
      fragments.flatMap((fragment) =>
        fragment._tag === 'ExtraTokenFragment' ? [fragment.identifier] : [],
      ),
    ),
  ]
  const hasArgs = imports.length + extraTokens.length > 0

  const contract = [
    CONTRACT_HEADER(DEPLOYER_CONTRACT_NAME),
    hasArgs ? '\n' : '',
    ...imports.map(IMPORT_ARGUMENT),
    ...extraTokens.map(EXTRA_ARGUMENT),
    BODY_HEADER,
    ...fragments.map((fragment, index) =>
      fragment._tag === 'RawFragment'
        ? RAW_CODE_APPEND(index)
        : fragment._tag === 'ImportFragment'
        ? IMPORT_CODE_APPEND(fragment.identifier)
        : EXTRA_CODE_APPEND(fragment.identifier),
    ),
    BODY_FOOTER,
    ...fragments.map((fragment, index) =>
      fragment._tag === 'RawFragment' ? RAW_FRAGMENT(index, fragment.code) : '',
    ),
    CONTRACT_FOOTER,
  ].join('')

  return contract
}

// Delete a file if it exists
const deleteFile = async (path: string) => fs.unlink(path).catch(() => {})

// Load a file from a path into a string
const loadFile = (path: string) => fs.readFile(path, 'utf8')

// Save a string to a path
const saveFile = (path: string, content: string) => fs.writeFile(path, content)

// Splice an element in between each element of an array
const spliceArray = <T>(array: T[], newElement: T) =>
  array.flatMap((element) => [element, newElement]).slice(0, -1)

// Find all imports in a file
const findImports = (content: string) => content.match(CDC_FILE_REGEX) || []

// Find all ImportFragments in CodeFragments
const processImportFragments = (
  codeFragments: CodeFragment[],
  token: string,
  replacements: TemplateReplacementToken[],
): CodeFragment[] => {
  return codeFragments.flatMap((fragment) =>
    fragment._tag === 'RawFragment'
      ? spliceArray(
          fragment.code.split(token).map(rawFragment),
          importFragment(
            (
              replacements.find((possibleReplacement) =>
                possibleReplacement.matchRegex.test(token),
              ) ?? trt(/./, 'unknown')
            ).identifier,
          ),
        )
      : [fragment],
  )
}

// Find additional tokens in CodeFragments
const processExtraTokens = (
  codeFragments: CodeFragment[],
  replacements: TemplateReplacementToken[],
): CodeFragment[] =>
  replacements.reduce<CodeFragment[]>(
    (fragments, nextToken) =>
      fragments.flatMap((fragment) =>
        fragment._tag === 'RawFragment'
          ? spliceArray(
              fragment.code.split(nextToken.matchRegex).map(rawFragment),
              extraTokenFragment(nextToken.identifier),
            )
          : [fragment],
      ),
    codeFragments,
  )

///// MAIN /////

const main = async () => {
  await deleteFile(OUTPUT_FILE)
  const content = await loadFile(INPUT_FILE)
  const imports = findImports(content)
  const withImportsParsed = imports.reduce<CodeFragment[]>(
    (fragments, nextImport) =>
      processImportFragments(fragments, nextImport, IMPORT_REPLACEMENT_TOKENS),
    [rawFragment(content)],
  )
  const parsed = processExtraTokens(
    withImportsParsed,
    ADDITIONAL_REPLACEMENT_TOKENS,
  )
  const contract = buildContract(parsed)
  await saveFile(OUTPUT_FILE, contract)
}

main().catch((err) => {
  console.error(err)
})
