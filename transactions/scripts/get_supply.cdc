// This script reads the total supply field
// of the WrappedFiatToken smart contract

import WrappedFiatToken from "WrappedFiatToken"

pub fun main(): UFix64 {
    return WrappedFiatToken.totalSupply
}
