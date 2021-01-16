pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Seasons Epoch Manager
/// @author Chainvisions
/// @notice this contract manages epochs on Seasons and determines the state of the epoch.
/// @dev Despite being in production, this code does not guarantee any form of safety, I have
/// taken steps to ensure this contract is bug-free but cannot guarantee anything.

contract EpochManager is Ownable {
    using SafeMath for uint256;

    struct Epoch {
        uint256 epochNo;
        uint256 burnPeriodTime;
        uint256 emissionPeriodStartTime;
        uint256 emissionPeriodEndTime;
        bool seedBurnEnabled;
    }

    // Variable for initializing an epoch.
    bool public managerInitialied;
    // SEED supply threshold for the epoch to advance.
    uint256 public supplyThreshold;
    // Duration of burn period.
    uint256 public burnPeriodDuration;
    // Duration of emission period.
    uin256 public emissionPeriodDuration;
    // Epoch variable
    Epoch public epochs;

    // Events for monitoring epoch advancements, BERRY burns and SEED burns.
    event SeedsBurned(uint256 indexed burned, address indexed burner);
    event BerryBurned(uint256 indexed burned, address indexed burner);
    event EpochAdvanced(uint256 indexed previousEpoch, uint256 indexed newEpoch, address indexed caller);

    // @notice Initializes the Epoch Manager
    function initializeEpoch() public onlyOwner {

    }

    /// @notice Advance to the next epoch.
    /// @dev This triggers a new epoch cycle.
    function advanceEpoch() public {
        require(SEEDS.totalSupply() <= supplyThreshold, "Epoch Manager: Supply threshold must be met to advance the epoch");

        // Increment the counter
        Epoch storage epoch = epochs;
        uint256 prevEpoch = epoch.epochNo;
        uint256 newEpoch = prevEpoch.add(1);
        epoch.epochNo = newEpoch;

        // Set burn period time
        uint256 burnTime = now.add(burnPeriodDuration);
        epoch.burnPeriodTime = burnTime;

        // Set the emission start time
        uint256 startTime = burnTime.add(86400); // 1 day after the burn period ends.
        epoch.emissionPeriodStartTime = startTime;

        // Set the emission end time
        uint256 endTime = startTime.add(emissionPeriodDuration);
        epoch.emissionPeriodEndTime = endTime;
        
        emit EpochAdvanced(prevEpoch, newEpoch, msg.sender);
    }

    /// @notice Burns BERRY for SEEDS
    function burnForSeeds(uint256 _amount) public {
        Epoch storage epoch = epochs;
        require(now <= epoch.burnPeriodTime, "Epoch Manager: BERRY burn period over.");
        emit BerryBurned(_amount, msg.sender);
    }

    /// @notice Burns SEEDS for BERRY
    function burnForBerry(uint256 _amount) public {
        Epoch storage epoch = epochs;
        require(now >= epoch.emissionPeriodEndTime, "Epoch Manager: SEEDS emission is still on-going.");
        emit SeedsBurned(_amount, msg.sender);
    }

    function adjustSupplyThreshold(uint256 _threshold) public onlyOwner {
        supplyThreshold = _threshold;
    }

    function adjustBurnPeriod(uint256 _burnPeriodDuration) public onlyOwner {
        burnPeriodDuration = _burnPeriodDuration;
    }

}