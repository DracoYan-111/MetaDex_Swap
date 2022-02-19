
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IDODOV1Helper {
    function querySellQuoteToken(address dodoV1Pool, uint256 quoteAmount) external view returns (uint256 receivedBaseAmount);

    function querySellBaseToken(address dodoV1Pool, uint256 baseAmount) external view returns (uint256 receivedQuoteAmount);
}

interface IDODOV2 {
    function querySellBase(
        address trader,
        uint256 payBaseAmount
    ) external view returns (uint256 receiveQuoteAmount, uint256 mtFee);

    function querySellQuote(
        address trader,
        uint256 payQuoteAmount
    ) external view returns (uint256 receiveBaseAmount, uint256 mtFee);
}


interface IDODOProxy {
    function dodoSwapV1(
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool,
        uint256 deadLine
    ) external payable returns (uint256 returnAmount);

    function dodoSwapV2TokenToToken(
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive,
        uint256 deadLine
    ) external returns (uint256 returnAmount);
}

contract DODOProxyIntegrate {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /*
        Note: The code example assumes user wanting to use the specify DODOV2 pool for swaping
    */
    function useDodoSwapV2() public {
        address dodoV2Pool = 0xD534fAE679f7F02364D177E9D44F1D15963c0Dd7;
        //BSC DODO - WBNB (DODO as BaseToken, WBNB as QuoteToken)
        address fromToken = 0xc748673057861a797275CD8A068AbB95A902e8de;
        //BSC DODO
        address toToken = 0x55d398326f99059fF775485246999027B3197955;
        //BSC WBNB
        uint256 fromTokenAmount = 1e10;
        //sellBaseAmount
        uint256 slippage = 20;

        /*
            Note: (only used for DODOV2 pool)
            Users can estimate prices before spending gas. Include two situations
            Sell baseToken and estimate received quoteToken 
            Sell quoteToken and estimate received baseToken
            DODOV2 Pool contract provides two view functions. Users can use directly.
            function querySellBase(address trader, uint256 payBaseAmount) external view  returns (uint256 receiveQuoteAmount,uint256 mtFee);
            function querySellQuote(address trader, uint256 payQuoteAmount) external view  returns (uint256 receiveBaseAmount,uint256 mtFee);
        */

        IERC20(fromToken).transferFrom(msg.sender, address(this), fromTokenAmount);
        (uint256 receivedQuoteAmount,) = IDODOV2(dodoV2Pool).querySellBase(msg.sender, fromTokenAmount);
        uint256 minReturnAmount = receivedQuoteAmount.mul(100 - slippage).div(100);

        address[] memory dodoPairs = new address[](1);
        //one-hop
        dodoPairs[0] = dodoV2Pool;

        /*
            Note: Differentiate sellBaseToken or sellQuoteToken. If sellBaseToken represents 0, sellQuoteToken represents 1. 
            At the same time, dodoSwapV1 supports multi-hop linear routing, so here we use 0,1 combination to represent the multi-hop directions to save gas consumption
            For example: 
                A - B - C (A - B sellBase and  B - C sellQuote)  Binary: 10, Decimal 2 (directions = 2)
                D - E - F (D - E sellQuote and E - F sellBase) Binary: 01, Decimal 1 (directions = 1) 
        */

        uint256 directions = 0;
        uint256 deadline = block.timestamp + 60 * 10;

        /*
            Note: Users need to authorize their sellToken to DODOApprove contract before executing the trade.
            ETH DODOApprove: 0xCB859eA579b28e02B87A1FDE08d087ab9dbE5149
            BSC DODOApprove: 0xa128Ba44B2738A558A1fdC06d6303d52D3Cef8c1
            Polygon DODOApprove: 0x6D310348d5c12009854DFCf72e0DF9027e8cb4f4
            Heco DODOApprove: 0x68b6c06Ac8Aa359868393724d25D871921E97293
            Arbitrum DODOApprove: 0xA867241cDC8d3b0C07C85cC06F25a0cD3b5474d8
        */
        address dodoApprove = 0xa128Ba44B2738A558A1fdC06d6303d52D3Cef8c1;
        _generalApproveMax(fromToken, dodoApprove, fromTokenAmount);

        /*
            ETH DODOV2Proxy: 0xa356867fDCEa8e71AEaF87805808803806231FdC
            BSC DODOV2Proxy: 0x8F8Dd7DB1bDA5eD3da8C9daf3bfa471c12d58486
            Polygon DODOV2Proxy: 0xa222e6a71D1A1Dd5F279805fbe38d5329C1d0e70
            Heco DODOV2Proxy: 0xAc7cC7d2374492De2D1ce21e2FEcA26EB0d113e7
            Arbitrum DODOV2Proxy: 0x88CBf433471A0CD8240D2a12354362988b4593E5
        */
        address dodoProxy = 0x8F8Dd7DB1bDA5eD3da8C9daf3bfa471c12d58486;

        uint256 returnAmount = IDODOProxy(dodoProxy).dodoSwapV2TokenToToken(
            fromToken,
            toToken,
            fromTokenAmount,
            1,
            dodoPairs,
            directions,
            false,
            deadline
        );

        IERC20(toToken).safeTransfer(msg.sender, returnAmount);
    }


    /*
        Note:For externalSwap or mixSwap functions need complex off-chain calculations or network requests. We recommended users to use DODO API (https://dodoex.github.io/docs/docs/tradeApi) directly. 
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
            IERC20(token).safeApprove(to, ~uint256(0));
        }
    }
}