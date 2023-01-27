import { CadenceParser } from "@onflow/cadence-parser"
import * as fcl from "@onflow/fcl"
import { promises as fs } from "fs"

const CODE_ONE = `
import Blah from "./Blah.cdc"

pub struct Thing {
  priv let a: UInt64
  priv let b: UInt64
  init() {
    self.a = 1
    self.b = 2
  }
}

// Func
pub fun main(thing: Thing): Blah.Foo {
  return thing
}
`

const CODE_TWO = `
pub struct THING {}
pub fun main(): FOO.THING.YO.BLAH {}
`

const CODE_THREE = `
import FungibleToken from 0xee82856bf20e2aa6

pub fun main(): AnyStruct {
  return Type<FungibleToken.Vault>()
}
`

const main = async () => {
  fcl.config().put("accessNode.api", "http://127.0.0.1:8888")

  const response = await fcl.query({
    cadence: `
      pub struct Thing {
        priv let a: UInt64
        priv let b: UInt64
        init() {
          self.a = 1
          self.b = 2
        }
      }

      pub fun main(thing: Thing): AnyStruct {
        return thing
      }
    `,
    args: (arg: any, t: any) => [
      arg(
        {
          fields: [
            { name: "a", value: "5" },
            { name: "b", value: "6" },
          ],
        },
        t.Struct(
          "s.0450233b4f5b6c3c515d9288594891f6cea9c36edf3520e050aa1a455bf3bf77.Thing",
          [
            { name: "a", value: t.UInt64 },
            { name: "b", value: t.UInt64 },
          ],
        ),
      ),
    ],
  })

  console.log(response)
}

const main3 = async () => {
  const parserBinary = await fs.readFile("cadence-parser.wasm")
  const parser = await CadenceParser.create(parserBinary)

  const ast = parser.parse(CODE_TWO)

  console.log(JSON.stringify(ast, null, 2))
}

main3()

// import { Client } from "./client"
// const ACCOUNT = "7ec1f607f0872a9e"

// const main = async () => {
//   const client = Client.mainnet()
//   const account = await client.account({ address: ACCOUNT })
//   console.log(account)
//   console.log(account.body.keys)

//   const contracts = await client.contracts({ address: ACCOUNT })
//   console.log(contracts.body.balance)
//   console.log(Object.keys(contracts.body.contracts))
// }
