package contracts_test

import (
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/onflow/bridged-usdc/lib/go/contracts"
)

const addrA = "0A"

func TestUSDCFlowContract(t *testing.T) {
	contract := contracts.USDCFlow(addrA, addrA, addrA, addrA, addrA, addrA)
	assert.NotNil(t, contract)
}

func TestUSDCFlowBasicContract(t *testing.T) {
	contract := contracts.USDCFlowBasic(addrA, addrA, addrA, addrA, addrA)
	assert.NotNil(t, contract)
}
