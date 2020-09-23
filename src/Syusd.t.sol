pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./Syusd.sol";

contract SyusdTest is DSTest {
    Syusd syusd;

    function setUp() public {
        syusd = new Syusd();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
