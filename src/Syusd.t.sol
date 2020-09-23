pragma solidity ^0.5.16;

import "ds-test/test.sol";

import "./syUSD.sol";

contract Hevm {
    function warp(uint256) public;
    function store(address,bytes32,bytes32) public;
}

contract transferFromTester {
    IERC20 syUSD;

    constructor (address _syUSD) public {
        syUSD = IERC20(_syUSD);
    }

    function trasnferFromTest(address sender, address recipeint, uint256 amount) public {
        syUSD.transferFrom(sender, recipeint, amount);
    }
}

contract syUSDTest is DSTest {
    Hevm hevm;
    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE = bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    syUSD syusd;
    transferFromTester tester;

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));
        syusd = new syUSD();
        tester = new transferFromTester(address(syusd));
    }

    // technical this test fails due to math dust but thats ok
    function test_mint_and_burn() public {
        syusd.yUSD().approve(address(syusd), uint(-1));
        syusd.mint(10000000000000000000);
        assertEq(syusd.balanceOfUnderlying(address(this)), 10000000000000000000);
        assertEq(syusd.balanceOf(address(this)), (10000000000000000000 * syusd.scalingFactor())/1000000000000000000);
        syusd.transfer(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D, (1000000000000000000 * syusd.scalingFactor())/1000000000000000000);
        assertEq(syusd.balanceOf(address(this)), (9000000000000000000 * syusd.scalingFactor())/1000000000000000000);

        syusd.approve(address(tester), (1000000000000000000 * syusd.scalingFactor())/1000000000000000000);
        assertEq(syusd.allowance(address(this), address(tester)), (1000000000000000000 * syusd.scalingFactor())/1000000000000000000);
        tester.trasnferFromTest(address(this), address(tester), (500000000000000000 * syusd.scalingFactor())/1000000000000000000);
        assertEq(syusd.allowance(address(this), address(tester)), (500000000000000000 * syusd.scalingFactor())/1000000000000000000);
        assertEq(syusd.balanceOf(address(this)), (8500000000000000000 * syusd.scalingFactor())/1000000000000000000);

        syusd.approve(address(syusd), uint(-1));
        assertEq(syusd.allowance(address(this), address(syusd)), uint(-1));

        uint256 balance = syusd.yUSD().balanceOf(address(this));
        syusd.burn(8500000000000000000);
        assertEq(balance + 8500000000000000000, syusd.yUSD().balanceOf(address(this)));

        assertEq(syusd.totalSupplyUnderlying(), syusd.yUSD().balanceOf(address(syusd)));
    }
}
