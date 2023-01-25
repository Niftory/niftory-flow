import { Client } from "./client"

const ACCOUNT = "7ec1f607f0872a9e"

const main = async () => {
  const client = Client.mainnet()
  const account = await client.account({ address: ACCOUNT })
  console.log(account)
  console.log(account.body.keys)

  const contracts = await client.contracts({ address: ACCOUNT })
  console.log(contracts.body.balance)
  console.log(Object.keys(contracts.body.contracts))
}

main()
