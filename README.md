# Creating a Self-Staking Solidity Smart Contract

Creating a self-staking Solidity smart contract connected to the data output of a completed Strava activity with the title "Proof of Activity as a Stake" and including P2P attestation with a photo of the activity involves several components. The contract needs to handle data input from Strava, verify the proof of activity, and manage staking logic. This example will focus on the core functionalities:

## Core Functionalities

### Tracking Activity Completion
The contract will store the proof of activity from Strava.

### P2P Attestation
Users can attest to the activity by submitting photos.

### Staking Logic
Users can stake tokens based on their activities.

Here's a simplified version of such a contract:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProofOfActivityStake {
    // Struct to store activity details
    struct Activity {
        string stravaId;        // Unique identifier for the Strava activity
        address user;           // Address of the user who completed the activity
        string activityData;    // Data of the activity (e.g., distance, duration)
        bool isCompleted;       // Flag indicating if the activity is completed
        uint256 stakedAmount;   // Amount of tokens staked on the activity
        string photoHash;       // Hash of the photo for P2P attestation
    }

    // Mapping from Strava ID to Activity details
    mapping(string => Activity) public activities;
    // Mapping from user address to their staked token amount
    mapping(address => uint256) public stakes;

    // Event emitted when an activity is completed
    event ActivityCompleted(string indexed stravaId, address indexed user, string activityData);
    // Event emitted when an activity is attested with a photo
    event ActivityAttested(string indexed stravaId, address indexed user, string photoHash);
    // Event emitted when tokens are staked on an activity
    event TokensStaked(address indexed user, uint256 amount);

    // Function to mark an activity as completed
    function completeActivity(string memory stravaId, string memory activityData) public {
        require(bytes(activityData).length > 0, "Activity data cannot be empty");

        // Store the activity details in the mapping
        activities[stravaId] = Activity({
            stravaId: stravaId,
            user: msg.sender,
            activityData: activityData,
            isCompleted: true,
            stakedAmount: 0,
            photoHash: ""
        });

        // Emit an event for activity completion
        emit ActivityCompleted(stravaId, msg.sender, activityData);
    }

    // Function for users to attest to their activity with a photo
    function attestActivity(string memory stravaId, string memory photoHash) public {
        Activity storage activity = activities[stravaId];
        require(activity.isCompleted, "Activity not completed");
        require(activity.user == msg.sender, "Only the user who completed the activity can attest");

        // Store the photo hash for attestation
        activity.photoHash = photoHash;

        // Emit an event for activity attestation
        emit ActivityAttested(stravaId, msg.sender, photoHash);
    }

    // Function for users to stake tokens on their completed activity
    function stakeTokens(string memory stravaId, uint256 amount) public {
        Activity storage activity = activities[stravaId];
        require(activity.isCompleted, "Activity not completed");
        require(activity.user == msg.sender, "Only the user who completed the activity can stake tokens");

        // Update the user's staked token amount and the activity's staked amount
        stakes[msg.sender] += amount;
        activity.stakedAmount += amount;

        // Emit an event for token staking
        emit TokensStaked(msg.sender, amount);
    }
}
```
