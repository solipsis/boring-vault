// SPDX-License-Identifier: SEL-1.0
// Copyright © 2025 Veda Tech Labs
// Derived from Boring Vault Software © 2025 Veda Tech Labs (TEST ONLY – NO COMMERCIAL USE)
// Licensed under Software Evaluation License, Version 1.0
pragma solidity 0.8.21;

import {Deployer} from "src/helper/Deployer.sol";
import {RolesAuthority, Authority} from "@solmate/auth/authorities/RolesAuthority.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MainnetAddresses} from "test/resources/MainnetAddresses.sol";
import {MockERC20} from "src/helper/MockERC20.sol";
import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "forge-std/Test.sol";

/**
 *  forge script script/DeployDeployer.s.sol:DeployDeployerScript --broadcast --verify
 *
 * @dev Optionally can change `--with-gas-price` to something more reasonable
 */
contract DeployGnosisSafeScript is Script, ContractNames, Test {
    uint256 public privateKey;

    GnosisSafeProxyFactory gnosisSafeProxyFactory = GnosisSafeProxyFactory(0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2);
    address singleton = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;
    address public expectedSafe = 0x3e6577E643c3D1E42cD504F96C345E85557e7C6E;

    function setUp() external {
        privateKey = vm.envUint("BORING_DEVELOPER");
        //vm.createSelectFork("mainnet");
        // privateKey = vm.envUint("DEPLOYER_KEY");
        vm.createSelectFork("plasma");
    }

    function run() external {
        vm.startBroadcast(privateKey);

        bytes memory initializer =
            hex"b63e800d00000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e0000000000000000000000000f48f2b2d2a534e402487b3ee7c18c33aec0fe5e4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005afe7a11e70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000735d32bd90d5d44cdba5a87921ce48789885aca9000000000000000000000000d1f948bd94722ecc44078dad71867cfd31bf159200000000000000000000000057fa7fde3fe15c3319a1d0698803c5bdbd29e4d2000000000000000000000000d1e6384710a0ebe1360c36fe85fd47eef979874c0000000000000000000000005d43a84067d72e91805426d7de24c7b951ab835500000000000000000000000011122d46c77daa7972aeff0349eda531ab5fbe540000000000000000000000000000000000000000000000000000000000000000";

        uint256 saltNonce = 0;

        address safe = gnosisSafeProxyFactory.createProxyWithNonce(singleton, initializer, saltNonce);

        require(safe == expectedSafe, "Safe does not equal expected safe!");
        vm.stopBroadcast();
    }
}

interface GnosisSafeProxyFactory {
    function createProxyWithNonce(address _singleton, bytes memory initializer, uint256 saltNonce)
        external
        returns (address proxy);
}
