// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Deployer} from "src/helper/Deployer.sol";
import {RolesAuthority, Authority, Auth} from "@solmate/auth/authorities/RolesAuthority.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MainnetAddresses} from "test/resources/MainnetAddresses.sol";
import {BoringSolver} from "src/base/Roles/BoringQueue/BoringSolver.sol";
import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "forge-std/Test.sol";

/**
 *  source .env && forge script script/ConfigureSkeleton.s.sol:ConfigureSkeleton --broadcast --verify
 *
 * @dev Optionally can change `--with-gas-price` to something more reasonable
 */
contract ConfigureSkeleton is Script, ContractNames, Test {
    uint256 public privateKey;

    Deployer deployer = Deployer(0x47Cec90FACc9364D7C21A8ab5e2aD9F1f75D740C);
    RolesAuthority authority = RolesAuthority(0xe2C7E397b35fF40962eBc205217B6795520Fb264);

    function setUp() external {
        privateKey = vm.envUint("BORING_DEVELOPER");
        vm.createSelectFork("mainnet");
    }

    function run() external {
        vm.startBroadcast(privateKey);

        address[] memory auths = new address[](4);
        auths[0] = 0xa487C41A29d56E9C1eb5E47dacb535A45abA6960; //accountant
        auths[1] = 0x78142F3d9e437076823B0F162cb11De1a9fDc8ed; //teller
        auths[2] = 0x31d4b7e3f6057d032CE93D4502B5DBd10A44e496; //queue
        auths[3] = 0xCbFB24dc29dB786aF0a897F761bf61be5f75C93B; //solver

        Deployer.Tx[] memory txs = new Deployer.Tx[](8);

        for (uint256 i = 0; i < 4; i++) {
            // First transaction: setAuthority
            txs[i * 2] = Deployer.Tx({
                target: auths[i],
                data: abi.encodeWithSelector(Auth.setAuthority.selector, authority),
                value: 0
            });

            // Second transaction: transferOwnership
            txs[i * 2 + 1] = Deployer.Tx({
                target: auths[i],
                data: abi.encodeWithSelector(Auth.transferOwnership.selector, address(0)),
                value: 0
            });
        }

        deployer.bundleTxs(txs);

        vm.stopBroadcast();
    }
}
