// This script reads the total supply field
// of the USDCFlow smart contract

import USDCFlow from "USDCFlow"

pub fun main(): UFix64 {
    return USDCFlow.totalSupply
}
