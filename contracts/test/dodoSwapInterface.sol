//// SPDX-License-Identifier: Apache-2.0
//
//pragma solidity 0.8.9;
//pragma experimental ABIEncoderV2;
//
//import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
//
//
//// @title IDodoMultiSwap
//interface IDodoMultiSwap {
//
//    function mixSwap(
//        address fromToken,
//        address toToken,
//        uint256 fromTokenAmount,
//        uint256 minReturnAmount,
//        address[] calldata mixAdapters,
//        address[] calldata mixPairs,
//        address[] calldata assetTo,
//        uint256 directions,
//        bytes[] calldata moreInfos,
//        uint256 deadLine
//    ) external returns (uint256 returnAmount);
//}
//
//// @title IDODOV2Proxy01
//interface IDODOV2Proxy01 {
//
//    function dodoSwapV2ETHToToken(
//        address toToken,
//        uint256 minReturnAmount,
//        address[] memory dodoPairs,
//        uint256 directions,
//        bool isIncentive,
//        uint256 deadLine
//    ) external payable returns (uint256 returnAmount);
//
//    function dodoSwapV2TokenToETH(
//        address fromToken,
//        uint256 fromTokenAmount,
//        uint256 minReturnAmount,
//        address[] memory dodoPairs,
//        uint256 directions,
//        bool isIncentive,
//        uint256 deadLine
//    ) external returns (uint256 returnAmount);
//
//    function dodoSwapV2TokenToToken(
//        address fromToken,
//        address toToken,
//        uint256 fromTokenAmount,
//        uint256 minReturnAmount,
//        address[] memory dodoPairs,
//        uint256 directions,
//        bool isIncentive,
//        uint256 deadLine
//    ) external returns (uint256 returnAmount);
//
//    function createDODOVendingMachine(
//        address baseToken,
//        address quoteToken,
//        uint256 baseInAmount,
//        uint256 quoteInAmount,
//        uint256 lpFeeRate,
//        uint256 i,
//        uint256 k,
//        bool isOpenTWAP,
//        uint256 deadLine
//    ) external payable returns (address newVendingMachine, uint256 shares);
//
//    function addDVMLiquidity(
//        address dvmAddress,
//        uint256 baseInAmount,
//        uint256 quoteInAmount,
//        uint256 baseMinAmount,
//        uint256 quoteMinAmount,
//        uint8 flag, //  0 - ERC20, 1 - baseInETH, 2 - quoteInETH
//        uint256 deadLine
//    )
//    external
//    payable
//    returns (
//        uint256 shares,
//        uint256 baseAdjustedInAmount,
//        uint256 quoteAdjustedInAmount
//    );
//
//    function createDODOPrivatePool(
//        address baseToken,
//        address quoteToken,
//        uint256 baseInAmount,
//        uint256 quoteInAmount,
//        uint256 lpFeeRate,
//        uint256 i,
//        uint256 k,
//        bool isOpenTwap,
//        uint256 deadLine
//    ) external payable returns (address newPrivatePool);
//
//    function resetDODOPrivatePool(
//        address dppAddress,
//        uint256[] memory paramList, //0 - newLpFeeRate, 1 - newI, 2 - newK
//        uint256[] memory amountList, //0 - baseInAmount, 1 - quoteInAmount, 2 - baseOutAmount, 3 - quoteOutAmount
//        uint8 flag, // 0 - ERC20, 1 - baseInETH, 2 - quoteInETH, 3 - baseOutETH, 4 - quoteOutETH
//        uint256 minBaseReserve,
//        uint256 minQuoteReserve,
//        uint256 deadLine
//    ) external payable;
//
//    function createCrowdPooling(
//        address baseToken,
//        address quoteToken,
//        uint256 baseInAmount,
//        uint256[] memory timeLine,
//        uint256[] memory valueList,
//        bool isOpenTWAP,
//        uint256 deadLine
//    ) external payable returns (address payable newCrowdPooling);
//
//    function bid(
//        address cpAddress,
//        uint256 quoteAmount,
//        uint8 flag, // 0 - ERC20, 1 - quoteInETH
//        uint256 deadLine
//    ) external payable;
//
//    function addLiquidityToV1(
//        address pair,
//        uint256 baseAmount,
//        uint256 quoteAmount,
//        uint256 baseMinShares,
//        uint256 quoteMinShares,
//        uint8 flag, // 0 erc20 Out  1 baseInETH  2 quoteInETH
//        uint256 deadLine
//    ) external payable returns (uint256, uint256);
//
//    function dodoSwapV1(
//        address fromToken,
//        address toToken,
//        uint256 fromTokenAmount,
//        uint256 minReturnAmount,
//        address[] memory dodoPairs,
//        uint256 directions,
//        bool isIncentive,
//        uint256 deadLine
//    ) external payable returns (uint256 returnAmount);
//
//    function externalSwap(
//        address fromToken,
//        address toToken,
//        address approveTarget,
//        address to,
//        uint256 fromTokenAmount,
//        uint256 minReturnAmount,
//        bytes memory callDataConcat,
//        bool isIncentive,
//        uint256 deadLine
//    ) external payable returns (uint256 returnAmount);
//
//    function mixSwap(
//        address fromToken,
//        address toToken,
//        uint256 fromTokenAmount,
//        uint256 minReturnAmount,
//        address[] memory mixAdapters,
//        address[] memory mixPairs,
//        address[] memory assetTo,
//        uint256 directions,
//        bool isIncentive,
//        uint256 deadLine
//    ) external payable returns (uint256 returnAmount);
//
//}
//
//// @title dodoSwapInterface
//contract dodoSwapInterface is OwnableUpgradeable {
//    using SafeMath for uint256;
//    using SafeERC20 for IERC20;
//
//    address public _ETH_ADDRESS_;
//
//
//    function initialize(
//    ) public initializer {
//        __Ownable_init();
//        _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
//    }
//
//    receive() external payable {}
//
//    function setMetaDexSwapAddr(address _metaDexSwapAddr) public onlyOwner {
//        metaDexSwapAddr = MetaDexSwap(_metaDexSwapAddr);
//    }
//
//    /**
//    * @notice Use IDodoMultiSwap interface mixSwap function
//    * @dev  dodo api data return
//    * @param addrList 0.approveAddr 1.toAddr 2.fromToken 3.toToken
//    */
//    function dodoMixSwapOne(
//        string memory projectId,
//        address[] memory addrList,
//        uint256 fromTokenAmount,
//        address[] memory mixAdapters,
//        address[] memory mixPairs,
//        address[] memory assetTo,
//        uint256 directions,
//        bytes[] memory moreInfos
//    ) external payable {
//
//        tokensTransferFrom(projectId, addrList[2], fromTokenAmount, addrList[0]);
//
//        IDodoMultiSwap(addrList[1]).mixSwap(
//            addrList[2],
//            addrList[3],
//            _generalBalanceOf(addrList[2], address(this)),
//            1,
//            mixAdapters,
//            mixPairs,
//            assetTo,
//            directions,
//            moreInfos,
//            block.timestamp + 60 * 10
//        );
//
//        //refund(projectId, addrList[3]);
//        //_generalTransfer(addrList[3], _msgSender(), _generalBalanceOf(addrList[3], address(this)));
//
//    }
//
//    /**
//    * @notice Use IDODOV2Proxy01 interface mixSwap function
//    * @dev  dodo api data return
//    * @param addrList 0.approveAddr 1.toAddr 2.fromToken 3.toToken
//    */
//    function dodoMixSwapTwo(
//        string memory projectId,
//        address[] memory addrList,
//        uint256 fromTokenAmount,
//        address[] memory mixAdapters,
//        address[] memory mixPairs,
//        address[] memory assetTo,
//        uint256 directions,
//        bool isIncentive
//    ) external payable {
//
//        tokensTransferFrom(projectId, addrList[2], fromTokenAmount, addrList[0]);
//
//        IDODOV2Proxy01(addrList[1]).mixSwap(
//            addrList[2],
//            addrList[3],
//            _generalBalanceOf(addrList[2], address(this)),
//            1,
//            mixAdapters,
//            mixPairs,
//            assetTo,
//            directions,
//            isIncentive,
//            block.timestamp + 60 * 10
//        );
//
//        refund(projectId, addrList[3]);
//
//    }
//
//
//    /**
//    * @notice Use IDODOV2Proxy01 interface dodoSwapV2TokenToToken function
//    * @dev dodo api data return
//    * @param addrList 0.approveAddr 1.toAddr 2.fromToken 3.toToken
//    */
//    function dodoSwapV2TokenToToken(
//        string memory projectId,
//        address[] memory addrList,
//        uint256 fromTokenAmount,
//        address[] memory dodoPairs,
//        uint256 directions,
//        bool isIncentive,
//        uint256 deadLine
//    ) external payable {
//
//        tokensTransferFrom(projectId, addrList[2], fromTokenAmount, addrList[0]);
//
//        IDODOV2Proxy01(addrList[1]).dodoSwapV2TokenToToken(
//            addrList[2],
//            addrList[3],
//            _generalBalanceOf(addrList[2], address(this)),
//            1,
//            dodoPairs,
//            directions,
//            isIncentive,
//            deadLine
//        );
//
//        refund(projectId, addrList[3]);
//
//    }
//
//    /**
//    * @notice Use IDODOV2Proxy01 interface externalSwap function
//    * @dev  dodo api data return
//    * @param addrList 0.approveAddr 1.toAddr 2.fromToken 3.toToken
//    */
//    function externalSwap(
//        string calldata projectId,
//        address[] memory addrList,
//        address approveTarget,
//        address to,
//        uint256 fromTokenAmount,
//        bytes calldata callDataConcat,
//        bool isIncentive
//    ) external payable {
//
//        tokensTransferFrom(projectId, addrList[2], fromTokenAmount, addrList[0]);
//
//
//        IDODOV2Proxy01(addrList[1]).externalSwap(
//            addrList[2],
//            addrList[3],
//            approveTarget,
//            to,
//            _generalBalanceOf(addrList[2], address(this)),
//            1,
//            callDataConcat,
//            isIncentive,
//            block.timestamp + 60 * 10
//        );
//
//        refund(projectId, addrList[3]);
//
//    }
//
//
//    /**
//    * @notice Collect user tokens (support ETH or BNB)
//    * @param fromToken Receive the user's token address
//    * @param fromTokenAmount The amount of tokens charged to the user
//    * @param approveAddr "targetApproveAddr" returned by dodo api
//    */
//    function tokensTransferFrom(
//        string memory projectId,
//        address fromToken,
//        uint256 fromTokenAmount,
//        address approveAddr
//    ) public payable {
//        if (fromToken != _ETH_ADDRESS_) {
//            IERC20(fromToken).safeTransferFrom(_msgSender(), address(this), fromTokenAmount);
//            _generalApproveMax(fromToken, approveAddr, fromTokenAmount);
//        } else {
//            require(fromTokenAmount == msg.value, "MS:f2");
//        }
//        uint256 returnAmount = _generalBalanceOf(fromToken, address(this));
//        uint256 newFromAmount_ = metaDexSwapAddr._getHandlingFee(returnAmount, projectId, fromToken);
//        _generalTransfer(fromToken, address(metaDexSwapAddr), returnAmount.sub(newFromAmount_));
//    }
//
//    /*
//    * @dev Max Approve of user's sold tokens
//    * @param token  Approve token address
//    * @param to     Approve address
//    * @param amount Number of transactions
//    */
//    function _generalApproveMax(
//        address token,
//        address to,
//        uint256 amount
//    ) internal {
//        uint256 allowance = IERC20(token).allowance(address(this), to);
//        if (allowance < amount) {
//            IERC20(token).safeApprove(to, ~uint256(0));
//        }
//    }
//
//    /*
//    * @dev Send the tokens exchanged by the user to the user
//    * @param token  Send token address
//    * @param to     Payment address
//    * @param amount Amount of tokens sent
//    */
//    function _generalTransfer(
//        address token,
//        address to,
//        uint256 amount
//    ) internal {
//        if (amount > 0) {
//            if (token == _ETH_ADDRESS_) {
//                payable(to).transfer(amount);
//            } else {
//                IERC20(token).safeTransfer(to, amount);
//            }
//        }
//    }
//
//    /*
//    * @dev Query the token balance in an address
//    * @param token Query token address
//    * @param who   The queried address
//    */
//    function _generalBalanceOf(
//        address token,
//        address who
//    ) internal view returns (uint256) {
//        if (token == _ETH_ADDRESS_) {
//            return who.balance;
//        } else {
//            return IERC20(token).balanceOf(who);
//        }
//    }
//
//    event test(uint256, uint256, uint256);
//
//    function refund(
//        string memory projectId,
//        address toToken
//    ) public {
//        uint256 returnAmount = _generalBalanceOf(toToken, address(this));
//        uint256 newFromAmount_ = metaDexSwapAddr._getHandlingFee(returnAmount, projectId, toToken);
//        _generalTransfer(toToken, address(metaDexSwapAddr), returnAmount.sub(newFromAmount_));
//        _generalTransfer(toToken, _msgSender(), _generalBalanceOf(toToken, address(this)));
//        emit test(returnAmount, newFromAmount_, returnAmount.sub(newFromAmount_));
//    }
//
//}