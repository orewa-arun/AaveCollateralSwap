//SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@aave/protocol-v2/contracts/flashloan/interfaces/IFlashLoanReceiver.sol";
import "@aave/protocol-v2/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import "../interfaces/IERC20.sol";

import "../interfaces/Iuniswap.sol";
import "../interfaces/IERC20.sol";

contract ColSwap is FlashLoanReceiverBase {
    using SafeMath for uint256;

    // We have assumed we have locked 200 aave tokens as collateral
    address private aaveAddress = 0x5010abCF8A1fbE56c096DCE9Bb2D29d63e141361;
    uint256 private aaveCollateralAmount = 200 ether;

    // We have chosen BAT tokens as example
    address private swapToken = 0x89a17D292Fd94ecB467A863e724C7E8a2BD995E1;

    // We are swapping tokens in uniswap
    address private UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    constructor(ILendingPoolAddressesProvider _addressProvider)
        public
        FlashLoanReceiverBase(_addressProvider)
    {}

    // We are borrowing DAI because we have assumed that previously we have borrowed DAI with aave tokens as collateral
    function executeFlashLoan(
        address dai,
        uint256 amountDai,
    ) public onlyOwner {
        address[] assets = new address[](1);
        assets[0] = asset;

        uint256[] amounts = new address[](1);
        amounts[0] = amount;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        address onBehalfOf = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;

        LENDING_POOL.flashloan(
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    /* 
        assets[0] = dai
        // flashSwapLogic
    */

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        address lendingPoolAddress = ADDRESSES_PROVIDER.getLendingPool();

        // Approval for lendingPool
        IERC20(assets[0]).approve(lendingPoolAddr, amounts[0]);
            
        // Repay the existing DAI Loan and release AAVE collateralised tokens 
        LENDING_POOL.repay(
            assets[0], 
            amounts[0], 
            1,
            address(this)
        );

        // Withdraw the released Aave
        LENDING_POOL.withdraw(aaveAddress,aaveCollateralAmount,address(this));

        //Swap AAVE tokens for BAT tokens in uniswap
        address batAddress = swapToken;
        swap(aaveAddress,batAddress,aaveCollateralAmount,1,address(this));

        // Deposit BAT tokens and get DAI back
        uint256 batAmount = IERC20(batAddress).balanceOf(address(this));
        IERC20(batAddress).approve(batAddress,batAmount);
        LENDING_POOL.deposit(batAddress,batAmount,address(this), uint16(0));

        // Borrow DAI with BAT tokens as collateral
        LENDING_POOL.borrow(
            assets[0],
            amounts[0],
            1,
            uint16(0),
            address(this)
        );

        // Pays back the DAI used up in flash loan along with the premium fee
        for (uint i = 0; i < assets.length; i++) {
            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL),amountOwing);
        }

        return true;

    }

    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) internal{
        IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

        address[] memory path;
        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;

        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }
}
