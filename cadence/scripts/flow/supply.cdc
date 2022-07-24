import FlowToken from "../../contracts/FlowToken.cdc"

pub fun main(): UFix64 {
    return FlowToken.totalSupply
}