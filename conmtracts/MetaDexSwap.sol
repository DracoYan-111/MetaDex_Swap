// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./storage/Storage.sol";
import "./storage/Events.sol";
import "./storage/Managers.sol";


contract MetaDexSwap is AccessControlEnumerableUpgradeable, ReentrancyGuardUpgradeable, Storage, Events, Managers {
    using SafeERC20 for IERC20;

    /*
    * @notice Initialization method
    * @dev Initialization method, can only be used once,
    *      And set project default administrator
    */
    function initialize(
    ) public initializer {
        _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        __ReentrancyGuard_init_unchained();
    }

    receive() external payable {}

    /*
    * @notice Users use DODOAPI to trade
    * @dev Compatible with ETH=>ERC20, ERC20=>ETH
    * @param  fromToken     Contract address of a token to sell ETH(BNB or Matic) 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    * @param  toToken       Contract address of a token to buy ETH(BNB or Matic) 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    * @param  fromAmount    Amount of a token to sell NOTE：calculated with decimals，For example 1ETH = 10**18
    * @param  newFromAmount New amount of a token to sell NOTE：calculated with decimals，For example 1ETH = 10**18
    * @param  projectId     The id of the project that has been cooperated with
    * @param  dodoApprove   User need give sell Token's authority to this contract  before swaping. if sell Token equals to ETH (BNB or HT). the param will be empty.
    * @param  dodoProxy     DODOV2Proxy or DODORouteProxy's address
    * @param  dodoApiData   ABI Data,Use directly
    */
    function useDodoApiData(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 newFromAmount,
        uint256 projectId,
        address dodoApprove,
        address dodoProxy,
        bytes memory dodoApiData
    ) external payable {
        require();
        if (fromToken != _ETH_ADDRESS_) {
            IERC20(fromToken).transferFrom(_msgSender(), address(this), fromAmount);
            _generalApproveMax(fromToken, dodoApprove, *fromAmount);
        } else {
            require(fromAmount == msg.value);
        }

        (bool success,) = dodoProxy.call{value : fromToken == _ETH_ADDRESS_ ? fromAmount : 0}(dodoApiData);
        require(success, "API_SWAP_FAILED");

        uint256 returnAmount = _generalBalanceOf(toToken, address(this));

        _generalTransfer(toToken, _msgSender(), returnAmount);
    }

    /*
    * @dev Max Approve of user's sold tokens
    * @param token  Approve token address
    * @param to     Approve address
    * @param amount Number of transactions
    */
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
            IERC20(token).safeApprove(to, uint256(- 1));
        }
    }

    /*
    * @dev Send the tokens exchanged by the user to the user
    * @param token  Send token address
    * @param to     Payment address
    * @param amount Amount of tokens sent
    */
    function _generalTransfer(
        address token,
        address payable to,
        uint256 amount
    ) internal {
        if (amount > 0) {
            if (token == _ETH_ADDRESS_) {
                to.transfer(amount);
            } else {
                IERC20(token).safeTransfer(to, amount);
            }
        }
    }

    /*
    * @dev Query the token balance in an address
    * @parm token Query token address
    * @parm who   The queried address
    */
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

    /*
    * @dev Calculate the fee ratio
    *
    *
    *
    */
    function _getHandlingFee(

    ) external view returns (uint256, uint256, uint256){
        return (0, 0, 0);
    }
}
