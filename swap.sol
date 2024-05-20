// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router02 {
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

contract Swap {
    IUniswapV2Router02 public immutable uniswapV2Router;
    address private constant WETH = 0xDE39C89e7A8E3Fc73e1e7f8b2edecD4c7FE62b66;

    constructor(address _router){
        uniswapV2Router = IUniswapV2Router02(_router);
    }

    function swapETHForExactTokens(uint amountOut, address token, address to, uint deadline) external payable {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = token;

        uniswapV2Router.swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);

        // Refund leftover ETH to sender
        uint leftover = address(this).balance;
        if (leftover > 0) {
            payable(msg.sender).transfer(leftover);
        }
    }

    // Fallback function to receive ETH
    receive() external payable {}
}
