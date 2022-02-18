// SPDX-License-Identifier: Apache-2.0

pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


interface MetaDexSwap {
    /*
    * @dev Calculate the fee ratio
    * @param  fromAmount     Amount of a token to sell NOTE：calculated with decimals，For example 1ETH = 10**18
    * @param  projectId      The id of the project that has been cooperated with
    * @return newFromAmount_ From amount after handling fee
    */
    function _getHandlingFee(uint256 fromAmount, string calldata projectId, address fromToken) external returns (uint256 newFromAmount_);
}


contract DODOApiEncapsulation {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    MetaDexSwap public metaDexSwap;

    receive() external payable {}
    constructor(MetaDexSwap _metaDexSwap){
        metaDexSwap = _metaDexSwap;
    }

    /*
    * @notice Users use DODO API to trade
    * @dev Compatible with ETH=>ERC20, ERC20=>ETH
    * @param fromToken     Contract address of a token to sell ETH(BNB or Matic) 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    * @param toToken       Contract address of a token to buy ETH(BNB or Matic) 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    * @param fromAmount    Amount of a token to sell NOTE：calculated with decimals，For example 1ETH = 10**18
    * @param newFromAmount New amount of a token to sell NOTE：calculated with decimals，For example 1ETH = 10**18
    * @param projectId     The id of the project that has been cooperated with
    * @param dodoApprove   User need give sell Token's authority to this contract  before swaping. if sell Token equals to ETH (BNB or HT). the param will be empty.
    * @param dodoProxy     DODOV2Proxy or DODORouteProxy's address
    * @param dodoApiData   ABI Data,Use directly
    */
    function useDodoApiData(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 newFromAmount,
        string calldata projectId,
        address dodoApprove,
        address dodoProxy,
        bytes memory dodoApiData
    ) external payable {
        require(address(metaDexSwap) != address(0), "MS:f5");
        require(fromToken != address(0) && toToken != address(0), "MS:f1");
        uint256 newFromAmount_ = metaDexSwap._getHandlingFee(fromAmount, projectId, fromToken);

        require(newFromAmount == newFromAmount_, "MS:f2");
        if (fromToken != _ETH_ADDRESS_) {
            IERC20(fromToken).transferFrom(msg.sender, address(this), fromAmount);
            _generalApproveMax(fromToken, dodoApprove, fromAmount);
        } else {
            require(fromAmount == msg.value,"MS:f6");
        }
        _generalTransfer(fromToken, address(metaDexSwap),fromAmount.sub(newFromAmount) );
        (bool success,) = dodoProxy.call{value : fromToken == _ETH_ADDRESS_ ? fromAmount : 0}(dodoApiData);
        require(success, "MS:f3");

        uint256 returnAmount = _generalBalanceOf(toToken, address(this));

        _generalTransfer(toToken, msg.sender, returnAmount);
    }


    function _generalApproveMax(
        address token,
        address to,
        uint256 amount
    ) internal {
        uint256 allowance = IERC20(token).allowance(address(this), to);
        if (allowance < amount) {
            if (allowance > 0) {
                IERC20(token).safeApprove(to, 0);
            }
            IERC20(token).safeApprove(to, ~uint256(0));
        }
    }

    function _generalTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        if (amount > 0) {
            if (token == _ETH_ADDRESS_) {
                payable(to).transfer(amount);
            } else {
                IERC20(token).safeTransfer(to, amount);
            }
        }
    }

    function _generalBalanceOf(
        address token,
        address who
    ) internal view returns (uint256) {
        if (token == _ETH_ADDRESS_) {
            return who.balance;
        } else {
            return IERC20(token).balanceOf(who);
        }
    }

}