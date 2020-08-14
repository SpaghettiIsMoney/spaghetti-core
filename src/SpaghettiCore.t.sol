pragma solidity ^0.5.12;

import "ds-test/test.sol";

import "./SpaghettiCore.sol";

contract Hevm {
    function warp(uint256) public;
    function store(address,bytes32,bytes32) public;
}

contract SpaghettiCoreTest is DSTest {
    SpaghettiFactory core;
    SpaghettiToken token;
    PASTAPool mkrPool;
    IERC20 maker = IERC20(0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2);

    Hevm hevm;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE = bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));
        core = new SpaghettiFactory();
        core.initMKR();
        core.initCOMP();
        core.initLINK();
        core.initSNX();
        core.initYFI();
        core.initLEND();
        core.initWETH();
        core.initWBTC();
        core.initUNI();
        token = core.spaghetti();
        mkrPool = core.mkrPool();
    }

    function test_mkr() public {
        hevm.store(
            address(0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(999999999999 ether))
        );
        hevm.warp(now + 3 hours);
        maker.approve(address(mkrPool), uint256(-1));
        mkrPool.stake(1 ether);
        hevm.warp(now + 10 days);
        mkrPool.exit();
        assertEq(token.balanceOf(address(this)),  980099999999999999543808);
        assertEq(maker.balanceOf(address(this)), 999999999999 ether);
    }

    function testFail_mkr_too_early() public {
        hevm.store(
            address(0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(999999999999 ether))
        );
        maker.approve(address(mkrPool), uint256(-1));
        mkrPool.stake(1 ether);
    }

}
