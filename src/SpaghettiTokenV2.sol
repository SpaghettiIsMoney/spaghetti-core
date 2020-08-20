pragma solidity ^0.5.0;

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transferFrom(address, address, uint256) external returns (bool);
}

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

// token.sol -- ERC20 implementation with minting and burning

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

contract SpaghettiTokenV2 is DSMath {
    uint256                                           public  totalSupply;
    mapping (address => uint256)                      public  balanceOf;
    mapping (address => mapping (address => uint256)) public  allowance;
    bytes32                                           public  symbol = "PASTA";
    uint256                                           public  decimals = 18;
    bytes32                                           public  name = "Spaghetti";
    ERC20                                             public  pastav1 = ERC20(0x08A2E41FB99A7599725190B9C970Ad3893fa33CF);
    address                                           public  foodbank = 0x8f951903C9360345B4e1b536c7F5ae8f88A64e79; //Giveth multisig
    address                                           public  governance = address(0); //Doesn't exist right now

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event Mint(address indexed guy, uint wad);
    event Burn(uint wad);

    function approve(address guy) external returns (bool) {
        return approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }

    function transfer(address dst, uint wad) external returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "ds-token-insufficient-approval");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }

        require(balanceOf[src] >= wad, "ds-token-insufficient-balance");
        balanceOf[src] = sub(balanceOf[src], wad);
        uint one = wad / 100;
        uint half = one / 2;
        uint ninetynine = sub(wad, one);
        balanceOf[dst] = add(balanceOf[dst], ninetynine);
        balanceOf[foodbank] = add(balanceOf[foodbank], half);
        burn(half);

        emit Transfer(src, dst, wad);

        return true;
    }

    function mint() public returns(bool) {
        uint v1Balance = pastav1.balanceOf(msg.sender);
        require(v1Balance > 0, "mint:no-tokens");
        require(pastav1.transferFrom(msg.sender, address(0), v1Balace), "mint:transferFrom-fail");
        balanceOf[msg.sender] = v1Balance;
        emit Mint(msg.sender, v1Balance);
    }

    function burn(uint wad) internal {
        totalSupply = sub(totalSupply, wad);
        emit Burn(wad);
    }

    function setFoodbank(address _foodbank) public {
        require(msg.sender == governance, "setFoodbank:not-gov");
        foodbank = _foodbank;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "setGovernance:not-gov");
        governance = _governance;
    }

}