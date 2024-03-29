// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./storage/Storage.sol";
import "./storage/Events.sol";
import "./storage/Managers.sol";


contract MetaDexSwap is AccessControlEnumerableUpgradeable, Storage, Events, Managers {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    /*
    * @notice Initialization method 0xaFd190a14847a16B7Bbed3A655E42133d439c037
    * @dev Initialization method, can only be used once,
    *      And set project default administrator
    */
    function initialize(
    ) public initializer {
        _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        _precision = 100;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        globalState = true;
    }

    receive() external payable {}

    /*
   * @dev Send the tokens exchanged by the user to the user
    * @param token  Send token address
    * @param to     Payment address
    * @param amount Amount of tokens sent
    */
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

    /*
    * @notice Set swap contract address
    * @dev PROJECT_ADMINISTRATORS use
    * @param _swapContract Swap contract address
    */
    function setSwapContract(
        address _swapContract
    ) external onlyRole(PROJECT_ADMINISTRATORS) {
        swapContract = _swapContract;
    }

    /*
    * @dev Calculate the fee ratio,swapContract use
    * @param  fromAmount     Amount of a token to sell NOTE：calculated with decimals，For example 1ETH = 10**18
    * @param  projectId      The id of the project that has been cooperated with
    * @return newFromAmount_ From amount after handling fee
    */
    function _getHandlingFee(
        uint256 fromAmount,
        string calldata projectId,
        address fromToken
    ) public returns (uint256 newFromAmount_){
        require(_msgSender() == swapContract, "MS:f4");
        (, uint256 treasuryBounty_) = (fromAmount.mul(treasuryFee)).tryDiv(_precision);
        (, uint256 projectBounty_) = ((fromAmount.sub(treasuryBounty_)).mul(projectFee[projectId])).tryDiv(_precision);
        (, uint256 projectTreasuryBounty_) = (projectBounty_.mul(projectTreasuryFee[projectId])).tryDiv(_precision);
        newFromAmount_ = fromAmount.sub(projectBounty_);

        if (projectFeeAddress[projectId][fromToken] == 0) projectAddress[projectId].push(fromToken);
        projectFeeAddress[projectId][fromToken] += projectBounty_.sub(projectTreasuryBounty_);

        if (treasuryFeeAddress[fromToken] == 0) treasuryAddress.push(fromToken);
        treasuryFeeAddress[fromToken] += treasuryBounty_.add(projectTreasuryBounty_);

        return newFromAmount_;
    }

    /*
    * @notice Project method to receive tokens
    * @dev Support individual collection and batch collection,Project administrators use
    * @param state     Pick up individually or in bulk
    * @param token     Token address received separately
    * @param to        Payment address
    * @param projectId The id of the project that has been cooperated with
    */
    function claimTokens(
        bool state,
        address token,
        address to,
        string calldata projectId
    ) external projectManager(projectId) projectSuspended(projectId) {
        if (state) {
            for (uint256 i = 0; i < projectAddress[projectId].length; i++) {
                address tokenAddress = projectAddress[projectId][i];
                _generalTransfer(tokenAddress, to, projectFeeAddress[projectId][token]);
                projectFeeAddress[projectId][token] = 0;
            }
        } else {
            _generalTransfer(token, to, projectFeeAddress[projectId][token]);
            projectFeeAddress[projectId][token] = 0;
        }
    }

    /*
    * @notice The project party transfers financial administrator privileges
    * @dev Project administrators use,Support for giving up management rights (transfer to 0 address)
    * @param projectId         The id of the project that has been cooperated with
    * @param newProjectManager New administrator address
    */
    function transferManagement(
        string calldata projectId,
        address newProjectManager
    ) external projectManager(projectId) {
        address oldProjectManager = _projectManager[projectId];
        _projectManager[projectId] = newProjectManager;
        emit setNewProjectManager(block.timestamp, oldProjectManager, newProjectManager, projectId);
    }

    //==========================================================

    /*
    * @notice Upload a new collaborative project ID
    * @dev PROJECT_ADMINISTRATORS use
    * @param projectId       New project id
    * @param project         The percentage of fees charged by the project
    * @param projectTreasury The proportion of the fee charged by the treasury for the project
    */
    function uploadProjectParty(
        string calldata projectId,
        uint256 project,
        uint256 projectTreasury
    ) external onlyRole(PROJECT_ADMINISTRATORS) {
        projectFee[projectId] = project;
        projectTreasuryFee[projectId] = projectTreasury;
        _projectState[projectId] = true;
    }

    //==========================================================
    /*
    * @notice Modify the fee ratio
    * @dev PROJECT_ADMINISTRATORS use
    * @param projectId                  The id of the project that has been cooperated with
    * @param newProjectManager          New project administrator address
    * @param projectProportion          Proportion of fees charged by the project party
    * @param projectTreasuryProportion  Proportion of the fee charged by the treasury to the project party
    */
    function setProjectFee(
        string calldata projectId,
        address newProjectManager,
        uint256 projectProportion,
        uint256 projectTreasuryProportion
    ) external onlyRole(PROJECT_ADMINISTRATORS) {
        projectFee[projectId] = projectProportion;
        emit setProjectFeeRatio(block.timestamp, projectId, projectProportion);
        projectTreasuryFee[projectId] = projectTreasuryProportion;
        emit setProjectTreasuryFeeRatio(block.timestamp, projectId, projectTreasuryProportion);
        _projectManager[projectId] = newProjectManager;
        emit setNewProjectManager(block.timestamp, address(0), newProjectManager, projectId);
    }

    /*
    * @notice Revised treasury fee
    * @dev PROJECT_ADMINISTRATORS use
    * @param proportion The percentage of the fee that the treasury must charge
    */
    function setTreasuryFee(
        uint256 proportion
    ) external onlyRole(PROJECT_ADMINISTRATORS) {
        treasuryFee = proportion;
        emit setTreasuryFeeRatio(block.timestamp, proportion);
    }

    /*
    * @notice Revised precision
    * @dev PROJECT_ADMINISTRATORS use
    * @param proportion The percentage of the fee that the treasury must charge
    */
    function setPrecision(
        uint256 proportion
    ) external onlyRole(PROJECT_ADMINISTRATORS) {
        _precision = proportion;
    }

    /*
    * @notice Treasurer takes tokens
    * @dev FINANCIAL_ADMINISTRATOR use
    * @param token  Send token address
    * @param to     Payment address
    */
    function withdrawMoney(
        address token,
        address to
    ) external onlyRole(FINANCIAL_ADMINISTRATOR) {
        _generalTransfer(token, to, treasuryFeeAddress[fromToken]);
        treasuryFeeAddress[fromToken] = 0;
    }

    /*
    * @notice Pause all projects or specified projects
    * @dev PROJECT_ADMINISTRATORS use
    * @param state  All project status
    * @param projectId     Item number to pause
    * @param projectState_ Project status to pause
    */
    function projectState(
        bool state,
        string calldata projectId,
        bool projectState_
    ) external onlyRole(PROJECT_ADMINISTRATORS) {
        globalState = state;
        _projectState[projectId] = projectState_;
    }
    //==========================================================
    //Are you a project administrator
    modifier projectManager(string calldata projectId){
        require(_msgSender() == _projectManager[projectId], "MS:f4");
        _;
    }

    //Determine whether the specified item or all items are suspended
    modifier projectSuspended(string calldata projectId){
        if (globalState && _projectState[projectId]) {
            _;
        } else {
            require(false, "MS:f5");
        }
    }
}
