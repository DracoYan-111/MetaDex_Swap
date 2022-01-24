// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Storage {

  mapping(uint256 => uint256) public projectFee;
  mapping(uint256 => uint256) public treasuryFee;


  address constant _ETH_ADDRESS_;

}
