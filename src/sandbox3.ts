import { Emulator } from "./emulator"

const main = async () => {
  console.log(BigInt(101))

  const emulator = await Emulator.create({
    httpPort: 8081,
  })

  const client = emulator.client

  const account = await client.account({ address: "0x0000000000000001" })
  console.log(account.body.keys)

  await client
    .blocksBetweenHeights({ start: 0, end: 10 })
    .then((blocks) => {
      console.log(blocks)
    })
    .catch((e) => {
      console.error(e)
    })

  const account2 = await client.account({ address: "0x0000000000000001" })
  console.log(account2.body.keys)

  console.log(await client.contracts({ address: "0x0000000000000001" }))

  await emulator.kill()
}

main()
