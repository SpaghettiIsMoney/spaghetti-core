pragma solidity ^0.5.12;

import "ds-test/test.sol";

import "./SpaghettiCore.sol";

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract Hevm {
    function warp(uint256) public;
    function store(address,bytes32,bytes32) public;
}

contract SpaghettiCoreTest is DSTest {
    SpaghettiFactory core;
    SpaghettiToken token;
    PASTAPool mkrPool;
    PASTAPool wbtcPool;
    PASTAPool compPool;
    PASTAPool lendPool;
    PASTAPool snxPool;
    PASTAPool wethPool;
    PASTAPool linkPool;
    PASTAPool yfiPool;
    PASTAPool uniswapPool;

    IERC20 maker = IERC20(0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2);
    IERC20 wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20 comp = IERC20(0xc00e94Cb662C3520282E6f5717214004A7f26888);
    IERC20 lend = IERC20(0x80fB784B7eD66730e8b1DBd9820aFD29931aab03);
    IERC20 snx = IERC20(0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F);
    IERC20 weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 link = IERC20(0x29E240CFD7946BA20895a7a02eDb25C210f9f324);
    IERC20 yfi = IERC20(0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e);
    IERC20 yycrv = IERC20(0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c);
    IERC20 univ2;

    IUniswapV2Router01 router = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

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
        univ2 = IERC20(core.uniswap());
        token = core.spaghetti();
        mkrPool = core.mkrPool();
        wbtcPool = core.wbtcPool();
        compPool = core.compPool();
        lendPool = core.lendPool();
        snxPool = core.snxPool();
        wethPool = core.wethPool();
        linkPool = core.linkPool();
        yfiPool = core.yfiPool();
        uniswapPool = core.uniswapPool();
    }

    function test_mkr() public {
        hevm.store(
            address(maker),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(999999999999 ether))
        );
        hevm.warp(now + 24 hours);
        maker.approve(address(mkrPool), uint256(-1));
        mkrPool.stake(1 ether);
        hevm.warp(now + 10 days);
        mkrPool.exit();
        assertEq(token.balanceOf(address(this)),  980099999999999999543808);
        assertEq(maker.balanceOf(address(this)), 999999999999 ether);
    }

    function testFail_mkr_too_early() public {
        hevm.store(
            address(maker),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(999999999999 ether))
        );
        maker.approve(address(mkrPool), uint256(-1));
        mkrPool.stake(1 ether);
    }

    // want to make sure I test this one cause it is new
    function test_wbtc() public {
        hevm.store(
            address(wbtc),
            keccak256(abi.encode(address(this), uint256(0))),
            bytes32(uint256(999999999999 ether))
        );
        assertEq(wbtc.balanceOf(address(this)), 999999999999 ether);

        hevm.warp(now + 24 hours);
        wbtc.approve(address(wbtcPool), uint256(-1));
        wbtcPool.stake(1 ether);
        hevm.warp(now + 10 days);
        wbtcPool.exit();
        assertEq(token.balanceOf(address(this)),  980099999999999999543808);
        assertEq(wbtc.balanceOf(address(this)), 999999999999 ether);
    }

    function testFail_wbtc_too_early() public {
        hevm.store(
            address(wbtc),
            keccak256(abi.encode(address(this), uint256(0))),
            bytes32(uint256(999999999999 ether))
        );
        wbtc.approve(address(wbtcPool), uint256(-1));
        wbtcPool.stake(1 ether);
    }

    function test_uni() public {
        hevm.store(
            address(yycrv),
            keccak256(abi.encode(address(this), uint256(0))),
            bytes32(uint256(999999 ether))
        );
        assertEq(yycrv.balanceOf(address(this)), 999999 ether);
        hevm.store(
            address(token),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(999999 ether))
        );
        assertEq(token.balanceOf(address(this)), 999999 ether);
        yycrv.approve(address(router), uint(-1));
        token.approve(address(router), uint(-1));

        uint exp = block.timestamp + 1 days;
        router.addLiquidity(address(yycrv), address(token), 999999 ether, 999999 ether, 999999 ether, 999999 ether, address(this), exp);

        assertEq(univ2.balanceOf(address(this)), 994986442119182848113525);

        hevm.warp(now + 48 hours);
        univ2.approve(address(uniswapPool), uint256(-1));
        uniswapPool.stake(1 ether);
        hevm.warp(now + 26 days);
        uniswapPool.exit();
        assertEq(token.balanceOf(address(this)),  6860699999999999999201664);
        assertEq(univ2.balanceOf(address(this)), 994986442119182848113525);

        univ2.approve(address(router), uint(-1));
        exp = block.timestamp + 1 days;
        router.removeLiquidity(address(yycrv), address(token), univ2.balanceOf(address(this)), 0, 0, address(this), exp);
    }

}
