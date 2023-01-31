import { Emulator } from "./emulator"

const main = async () => {
  console.log(BigInt(101))

  const emulator1 = await Emulator.create({
    httpPort: 8081,
  })

  const emulator2 = await Emulator.create({
    httpPort: 8082,
    grpcPort: 8083,
    adminApiPort: 8084,
  })

  const emulator3 = await Emulator.create({
    httpPort: 8085,
    grpcPort: 8086,
    adminApiPort: 8087,
  })

  const account1 = await emulator1.client.account({
    address: "0x0000000000000001",
  })
  console.log(account1.body.keys)

  const account2 = await emulator2.client.account({
    address: "0x0000000000000001",
  })
  console.log(account2.body.keys)

  const account3 = await emulator3.client.account({
    address: "0x0000000000000001",
  })
  console.log(account3.body.keys)

  await emulator1.kill()
  await emulator2.kill()
  await emulator3.kill()
}

main()
