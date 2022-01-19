//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.10;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";

import { Vesting } from "./Vesting.sol";

/**
 * @title OtcEscrow
 * @author Badger DAO (modified by Galleon)
 * 
 * A simple OTC swap contract allowing two users to set the parameters of an OTC
 * deal in the constructor arguments, and deposits the sold tokens into a vesting
 * contract when a swap is completed.
 */
contract OtcEscrow {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== Events =========== */

    event VestingDeployed(address vesting);
    
    /* ====== Modifiers ======== */

    /**
     * Throws if the sender is not Dbl Gov
     */
    modifier onlyDblGov() {
        require(msg.sender == dblGov, "unauthorized");
        _;
    }

    /**
     * Throws if run more than once
     */
    modifier onlyOnce() {
        require(!hasRun, "swap already executed");
        hasRun = true;
        _;
    }

    /* ======== State Variables ======= */

    address public usdc;
    address public dbl;

    address public dblGov;
    address public beneficiary;

    uint256 public vestingStart;
    uint256 public vestingEnd;
    uint256 public vestingCliff;

    uint256 public usdcAmount;
    uint256 public dblAmount;

    bool hasRun;



    /* ====== Constructor ======== */

    /**
     * Sets the state variables that encode the terms of the OTC sale
     *
     * @param _beneficiary  Address that will purchase DBL
     * @param _dblGov     Address that will receive USDC
     * @param _vestingStart Timestamp of vesting start
     * @param _vestingCliff Timestamp of vesting cliff
     * @param _vestingEnd   Timestamp of vesting end
     * @param _usdcAmount   Amount of USDC swapped for the sale
     * @param _dblAmount  Amount of DBL swapped for the sale
     * @param _usdcAddress  Address of the USDC token
     * @param _dblAddress Address of the Doubloon token
     */
    constructor(
        address _beneficiary,
        address _dblGov,
        uint256 _vestingStart,
        uint256 _vestingCliff,
        uint256 _vestingEnd,
        uint256 _usdcAmount,
        uint256 _dblAmount,
        address _usdcAddress,
        address _dblAddress
    ) public {
        beneficiary = _beneficiary;
        dblGov =  _dblGov;

        vestingStart = _vestingStart;
        vestingCliff = _vestingCliff;
        vestingEnd = _vestingEnd;

        usdcAmount = _usdcAmount;
        dblAmount = _dblAmount;

        usdc = _usdcAddress;
        dbl = _dblAddress;
        hasRun = false;
    }
    
    /* ======= External Functions ======= */

    /**
     * Executes the OTC deal. Sends the USDC from the beneficiary to Doubloon Governance, and
     * locks the DBL in the vesting contract. Can only be called once.
     */
    function swap() external onlyOnce {

        require(IERC20(dbl).balanceOf(address(this)) >= dblAmount, "insufficient DBL");

        // Transfer expected USDC from beneficiary
        IERC20(usdc).safeTransferFrom(beneficiary, address(this), usdcAmount);

        // Create Vesting contract
        Vesting vesting = new Vesting(dbl, beneficiary, dblAmount, vestingStart, vestingCliff, vestingEnd);

        // Transfer dbl to vesting contract
        IERC20(dbl).safeTransfer(address(vesting), dblAmount);

        // Transfer USDC to dbl governance
        IERC20(usdc).safeTransfer(dblGov, usdcAmount);

        emit VestingDeployed(address(vesting));
    }

    /**
     * Return DBL to Doubloon Governance to revoke the deal
     */
    function revoke() external onlyDblGov {
        uint256 indexBalance = IERC20(dbl).balanceOf(address(this));
        IERC20(dbl).safeTransfer(dblGov, indexBalance);
    }

    /**
     * Recovers USDC accidentally sent to the contract
     */
    function recoverUsdc() external {
        uint256 usdcBalance = IERC20(usdc).balanceOf(address(this));
        IERC20(usdc).safeTransfer(beneficiary, usdcBalance);
    }
}