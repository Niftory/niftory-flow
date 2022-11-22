import * as FlowTesting from 'flow-js-testing'

type AccountInit = {
  name: string
  flow: string
}

type Address = string

const initializeAccount = async ({
  name,
  flow,
}: AccountInit): Promise<Address> =>
  (FlowTesting.getAccountAddress(name) as Promise<Address>).then((account) => {
    FlowTesting.mintFlow(account, flow)
    return account
  })

const initializeAccounts = async (
  accountNames: string[],
  flow: string,
): Promise<Record<string, Address>> =>
  Promise.all(
    accountNames.map(async (name) => {
      const address = await initializeAccount({ name, flow })
      return { name, address }
    }),
  ).then((addresses) =>
    Object.fromEntries(addresses.map(({ name, address }) => [name, address])),
  )

export { initializeAccount, initializeAccounts }
export type { AccountInit }
