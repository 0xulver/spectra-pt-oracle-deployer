// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IPrincipalToken} from "./interfaces/IPrincipalToken.sol";
import {ISpectraPriceOracleFactory} from "./interfaces/ISpectraPriceOracleFactory.sol";
import {ISpectraPriceOracle} from "./interfaces/ISpectraPriceOracle.sol";

contract SpectraOracleDeployerTest is Test {
    IPrincipalToken public principalToken;
    ISpectraPriceOracleFactory public factory;
    uint256 public fork;
    address constant FACTORY_ADDRESS = 0xAA055F599f698E5334078F4921600Bd16CceD561;
    address constant ZCB_MODEL = 0xf0DB3482c20Fc6E124D5B5C60BdF30BD13EC87aE;
    address constant PT_FUSDC = 0x95590E979A72B6b04D829806E8F29aa909eD3a86;
    address constant PT_CUSDO = 0x1155d1731B495BF22f016e13cAfb6aFA53BD8a28;

    function setUp() public {
        // Create and select a fork of Base
        fork = vm.createFork(vm.envString("BASE_RPC_URL"));
        vm.selectFork(fork);
        
        // Initialize PT contract interface
        principalToken = IPrincipalToken(PT_CUSDO);
        factory = ISpectraPriceOracleFactory(FACTORY_ADDRESS);
    }

    function test_DeployOracle() public {
        // Initial APY of 5%
        uint256 initialAPY = 0.05e18;
        
        // Deploy oracle
        address oracle = factory.createOracle(
            address(principalToken),
            ZCB_MODEL,
            initialAPY,
            address(this) // Set test contract as owner
        );
        
        console.log("Oracle deployed at:", oracle);
        
        // Verify oracle was created correctly
        ISpectraPriceOracle deployedOracle = ISpectraPriceOracle(oracle);
        
        // Check oracle parameters
        assertEq(deployedOracle.PT(), address(principalToken), "Wrong PT address");
        assertEq(deployedOracle.discountModel(), ZCB_MODEL, "Wrong discount model");
        assertEq(deployedOracle.initialImpliedAPY(), initialAPY, "Wrong initial APY");
        
        // Get first price reading
        (,int256 price,,,) = deployedOracle.latestRoundData();
        console.log("Initial oracle price:", uint256(price));
        assertTrue(price > 0, "Price should be greater than 0");
    }

    function test_VerifyPT() public view {
        // Get and log the IBT address
        address ibt = principalToken.getIBT();
        console.log("IBT address:", ibt);
        
        // Get and log the underlying token address through IBT
        address underlying = IERC4626(ibt).asset();
        console.log("Underlying token address:", underlying);
        
        // Get and log maturity timestamp
        uint256 maturityTimestamp = principalToken.maturity();
        console.log("PT maturity timestamp:", maturityTimestamp);
        
        // Get and log PT symbol
        string memory symbol = principalToken.symbol();
        console.log("PT symbol:", symbol);

        // Verify this is a real PT by checking it has an IBT
        assertTrue(ibt != address(0), "Should have valid IBT address");
        // Verify this is a real IBT by checking it has an underlying
        assertTrue(underlying != address(0), "Should have valid underlying address");
        // Verify maturity is in the future
        assertTrue(maturityTimestamp > block.timestamp, "Should have future maturity");
    }

    function test_ChainID() public view {
        assertEq(block.chainid, 8453); // Base mainnet chain ID
    }
}
