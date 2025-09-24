// SPDX-License-Identifier: SEL-1.0
// Copyright © 2025 Veda Tech Labs
// Derived from Boring Vault Software © 2025 Veda Tech Labs (TEST ONLY – NO COMMERCIAL USE)
// Licensed under Software Evaluation License, Version 1.0
pragma solidity 0.8.21;

import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {ERC4626} from "@solmate/tokens/ERC4626.sol";
import {MerkleTreeHelper} from "test/resources/MerkleTreeHelper/MerkleTreeHelper.sol";
import "forge-std/Script.sol";

/**
 *  source .env && forge script script/MerkleRootCreation/Mainnet/CreateDancingPenguinMerkleRoot.s.sol --rpc-url $MAINNET_RPC_URL --gas-limit 1000000000000000000
 */
contract CreateDancingPenguinMerkleRoot is Script, MerkleTreeHelper {
    using FixedPointMathLib for uint256;

    //standard
    address public boringVault = 0xdfC83880203522d19D32dddC0B982ab5bfcF6411;
    address public rawDataDecoderAndSanitizer = 0x0acCa7989219eB630a5dAf8929f6081D345d38Fa;
    address public managerAddress = 0x503CEFFDd0ecB412f0Bd51f1A396567Fea562e87;
    address public accountantAddress = 0x754B6235345178c460690174Ea6935421b26aE18;

    function setUp() external {}

    /**
     * @notice Uncomment which script you want to run.
     */
    function run() external {
        generateStrategistMerkleRoot();
    }

    function generateStrategistMerkleRoot() public {
        setSourceChainName(mainnet);
        setAddress(false, mainnet, "boringVault", boringVault);
        setAddress(false, mainnet, "managerAddress", managerAddress);
        setAddress(false, mainnet, "accountantAddress", accountantAddress);
        setAddress(false, mainnet, "rawDataDecoderAndSanitizer", rawDataDecoderAndSanitizer);

        ManageLeaf[] memory leafs = new ManageLeaf[](64);

        // ========================== Aave V3 ==========================
        ERC20[] memory supplyAssets = new ERC20[](3);
        supplyAssets[0] = getERC20(sourceChain, "WETH");
        supplyAssets[1] = getERC20(sourceChain, "WEETH");
        supplyAssets[2] = getERC20(sourceChain, "WSTETH");
        ERC20[] memory borrowAssets = new ERC20[](3);
        borrowAssets[0] = getERC20(sourceChain, "WETH");
        borrowAssets[1] = getERC20(sourceChain, "WEETH");
        borrowAssets[2] = getERC20(sourceChain, "WSTETH");
        _addAaveV3Leafs(leafs, supplyAssets, borrowAssets);

        // ========================== Morpho ==========================
        _addMorphoBlueSupplyLeafs(leafs, 0x698fe98247a40c5771537b5786b2f3f9d78eb487b4ce4d75533cd0e94d88a115);
        _addMorphoBlueCollateralLeafs(leafs, 0x698fe98247a40c5771537b5786b2f3f9d78eb487b4ce4d75533cd0e94d88a115);
        _addMorphoBlueSupplyLeafs(leafs, getBytes32(sourceChain, "WEETH_WETH_915"));
        _addMorphoBlueCollateralLeafs(leafs, getBytes32(sourceChain, "WEETH_WETH_915"));

        // ========================== Morpho Rewards ==========================
        _addMorphoRewardMerkleClaimerLeafs(leafs, getAddress(sourceChain, "universalRewardsDistributor"));

        // ========================== Meta Morpho ==========================
        _addERC4626Leafs(leafs, ERC4626(getAddress(sourceChain, "gauntletWETHPrime")));
        _addERC4626Leafs(leafs, ERC4626(getAddress(sourceChain, "gauntletWETHCore")));
        _addERC4626Leafs(leafs, ERC4626(getAddress(sourceChain, "mevCapitalwWeth")));
        _addERC4626Leafs(leafs, ERC4626(getAddress(sourceChain, "Re7WETH")));
        

        // ========================== 1inch ==========================
        address[] memory assets = new address[](3);
        SwapKind[] memory kind = new SwapKind[](3);
        assets[0] = getAddress(sourceChain, "WETH");
        kind[0] = SwapKind.BuyAndSell;
        assets[1] = getAddress(sourceChain, "WEETH");
        kind[1] = SwapKind.BuyAndSell;
        assets[2] = getAddress(sourceChain, "WSTETH");
        kind[2] = SwapKind.BuyAndSell;

        _addLeafsFor1InchGeneralSwapping(leafs, assets, kind);

        // ========================== Verify ==========================
        _verifyDecoderImplementsLeafsFunctionSelectors(leafs);

        bytes32[][] memory manageTree = _generateMerkleTree(leafs);

        string memory filePath = "./leafs/Mainnet/DancingPenguinStrategistLeafs.json";

        _generateLeafs(filePath, leafs, manageTree[manageTree.length - 1][0], manageTree);
    }
}
