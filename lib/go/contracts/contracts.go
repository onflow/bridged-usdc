package contracts

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../contracts -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../contracts/...

import (
	"regexp"

	"github.com/onflow/bridged-usdc/lib/go/contracts/internal/assets"

	_ "github.com/kevinburke/go-bindata"
)

var (
	placeholderFungibleToken    = regexp.MustCompile(`"FungibleToken"`)
	placeholderMetadataViews    = regexp.MustCompile(`"MetadataViews"`)
	placeholderFTMetadataViews  = regexp.MustCompile(`"FungibleTokenMetadataViews"`)
	placeholderViewResolver     = regexp.MustCompile(`"ViewResolver"`)
	placeholderBurner           = regexp.MustCompile(`"Burner"`)
	placeholderBridgeInterfaces = regexp.MustCompile(`"FlowEVMBridgeHandlerInterfaces"`)
	metadataViewsImport         = "MetadataViews from "
	ftMetadataViewsImport       = "FungibleTokenMetadataViews from "
	burnerImport                = "Burner from "
	fungibleTokenImport         = "FungibleToken from "
	viewResolverImport          = "ViewResolver from "
	bridgeInterfacesImport      = "FlowEVMBridgeHandlerInterfaces from "
)

const (
	filenameUSDCFlow      = "USDCFlow.cdc"
	filenameUSDCFlowBasic = "utility/USDCFlowBasic.cdc"
)

// USDCFlow returns the USDCFlow contract.
func USDCFlow(
	ftAddr,
	metadataAddr,
	ftMetadataAddr,
	viewResolverAddr,
	burnerAddr,
	bridgeInterfacesAddr string) []byte {

	code := assets.MustAssetString(filenameUSDCFlow)

	code = placeholderFungibleToken.ReplaceAllString(code, fungibleTokenImport+"0x"+ftAddr)
	code = placeholderMetadataViews.ReplaceAllString(code, metadataViewsImport+"0x"+metadataAddr)
	code = placeholderFTMetadataViews.ReplaceAllString(code, ftMetadataViewsImport+"0x"+ftMetadataAddr)
	code = placeholderViewResolver.ReplaceAllString(code, viewResolverImport+"0x"+viewResolverAddr)
	code = placeholderBurner.ReplaceAllString(code, burnerImport+"0x"+burnerAddr)
	code = placeholderBridgeInterfaces.ReplaceAllString(code, bridgeInterfacesImport+"0x"+bridgeInterfacesAddr)

	return []byte(code)
}

// USDCFlowBasic returns the USDCFlowBasic contract.
func USDCFlowBasic(ftAddr, metadataAddr, ftMetadataAddr, viewResolverAddr, burnerAddr string) []byte {
	code := assets.MustAssetString(filenameUSDCFlowBasic)

	code = placeholderFungibleToken.ReplaceAllString(code, fungibleTokenImport+"0x"+ftAddr)
	code = placeholderMetadataViews.ReplaceAllString(code, metadataViewsImport+"0x"+metadataAddr)
	code = placeholderFTMetadataViews.ReplaceAllString(code, ftMetadataViewsImport+"0x"+ftMetadataAddr)
	code = placeholderViewResolver.ReplaceAllString(code, viewResolverImport+"0x"+viewResolverAddr)
	code = placeholderBurner.ReplaceAllString(code, burnerImport+"0x"+burnerAddr)

	return []byte(code)
}
