pragma solidity ^0.5.12;

import "ds-test/test.sol";

import "./SpaghettiToken.sol";
import "./PASTAPool.sol";

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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract Hevm {
    function warp(uint256) public;
    function store(address,bytes32,bytes32) public;
}

contract SpaghettiCoreTest is DSTest {
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

    IERC20 mkr = IERC20(0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2);
    IERC20 wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20 comp = IERC20(0xc00e94Cb662C3520282E6f5717214004A7f26888);
    IERC20 link = IERC20(0x29E240CFD7946BA20895a7a02eDb25C210f9f324);
    IERC20 yfi = IERC20(0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e);
    IERC20 lend = IERC20(0x80fB784B7eD66730e8b1DBd9820aFD29931aab03);
    IERC20 snx = IERC20(0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F);
    IERC20 weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 yycrv = IERC20(0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c);
    address univ2;

    IUniswapV2Factory uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);    
    IUniswapV2Router01 router = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    Hevm hevm;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE = bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));
        token = new SpaghettiToken(address(this));
        mkrPool = new PASTAPool(address(token), address(mkr));
        token.transfer(address(mkrPool), 1000000000000000000000000);
        mkrPool.setRewardDistribution(address(this));
        mkrPool.notifyRewardAmount(990000000000000000000000);
        mkrPool.setRewardDistribution(address(0));
        mkrPool.renounceOwnership();

        wbtcPool = new PASTAPool(address(token), address(wbtc));
        token.transfer(address(wbtcPool), 1000000000000000000000000);
        wbtcPool.setRewardDistribution(address(this));
        wbtcPool.notifyRewardAmount(990000000000000000000000);
        wbtcPool.setRewardDistribution(address(0));
        wbtcPool.renounceOwnership();

        compPool = new PASTAPool(address(token), address(comp));
        token.transfer(address(compPool), 1000000000000000000000000);
        compPool.setRewardDistribution(address(this));
        compPool.notifyRewardAmount(990000000000000000000000);
        compPool.setRewardDistribution(address(0));
        compPool.renounceOwnership();

        lendPool = new PASTAPool(address(token), address(lend));
        token.transfer(address(lendPool), 1000000000000000000000000);
        lendPool.setRewardDistribution(address(this));
        lendPool.notifyRewardAmount(990000000000000000000000);
        lendPool.setRewardDistribution(address(0));
        lendPool.renounceOwnership();

        snxPool = new PASTAPool(address(token), address(snx));
        token.transfer(address(snxPool), 1000000000000000000000000);
        snxPool.setRewardDistribution(address(this));
        snxPool.notifyRewardAmount(990000000000000000000000);
        snxPool.setRewardDistribution(address(0));
        snxPool.renounceOwnership();

        wethPool = new PASTAPool(address(token), address(weth));
        token.transfer(address(wethPool), 1000000000000000000000000);
        wethPool.setRewardDistribution(address(this));
        wethPool.notifyRewardAmount(990000000000000000000000);
        wethPool.setRewardDistribution(address(0));
        wethPool.renounceOwnership();

        linkPool = new PASTAPool(address(token), address(link));
        token.transfer(address(linkPool), 1000000000000000000000000);
        linkPool.setRewardDistribution(address(this));
        linkPool.notifyRewardAmount(990000000000000000000000);
        linkPool.setRewardDistribution(address(0));
        linkPool.renounceOwnership();

        yfiPool = new PASTAPool(address(token), address(yfi));
        token.transfer(address(yfiPool), 1000000000000000000000000);
        yfiPool.setRewardDistribution(address(this));
        yfiPool.notifyRewardAmount(990000000000000000000000);
        yfiPool.setRewardDistribution(address(0));
        yfiPool.renounceOwnership();

        univ2 = uniswapFactory.createPair(0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c, address(token));
        uniswapPool = new PASTAPool(address(token), univ2);
        uniswapPool.setRewardDistribution(address(this));
        token.transfer(address(uniswapPool), 7000000000000000000000000);
        uniswapPool.notifyRewardAmount(6930000000000000000000000);
        uniswapPool.setRewardDistribution(address(0));
        uniswapPool.renounceOwnership();
    }

    function test_mkr() public {
        hevm.store(
            address(mkr),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(999999999999 ether))
        );
        hevm.warp(1597777200);
        mkr.approve(address(mkrPool), uint256(-1));
        mkrPool.stake(1 ether);
        hevm.warp(now + 10 days);
        mkrPool.exit();
        assertEq(token.balanceOf(address(this)),  980099999999999999543808);
        assertEq(mkr.balanceOf(address(this)), 999999999999 ether);
    }

    function testFail_mkr_too_early() public {
        hevm.store(
            address(mkr),
            keccak256(abi.encode(address(this), uint256(1))),
            bytes32(uint256(999999999999 ether))
        );
        mkr.approve(address(mkrPool), uint256(-1));
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

        hevm.warp(1597777200);
        wbtc.approve(address(wbtcPool), uint256(-1));
        wbtcPool.stake(1 ether);
        hevm.warp(now + 10 days);
        wbtcPool.exit();
        assertEq(token.balanceOf(address(this)),  980099999999999999543808);
        assertEq(wbtc.balanceOf(address(this)), 999999999999 ether);
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

        assertEq(IERC20(univ2).balanceOf(address(this)), 994986442119182848113525);

        hevm.warp(1597777200);
        IERC20(univ2).approve(address(uniswapPool), uint256(-1));
        uniswapPool.stake(1 ether);
        hevm.warp(now + 26 days);
        uniswapPool.exit();
        assertEq(token.balanceOf(address(this)),  6860699999999999999800416);
        assertEq(IERC20(univ2).balanceOf(address(this)), 994986442119182848113525);

        IERC20(univ2).approve(address(router), uint(-1));
        exp = block.timestamp + 1 days;
        router.removeLiquidity(address(yycrv), address(token), IERC20(univ2).balanceOf(address(this)), 0, 0, address(this), exp);
    }

}
