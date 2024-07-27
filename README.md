# Creating a Self-Staking Solidity Smart Contract (Strava data Oracle)

Creating a self-staking Solidity smart contract connected to the data output of a completed Strava activity with the title "Proof of Activity as a Stake" and including P2P attestation with a photo of the activity involves several components. The contract needs to handle data input from Strava, verify the proof of activity, and manage staking logic. This example will focus on the core functionalities:

## Core Functionalities

### Tracking Activity Completion
The contract will store the proof of activity from Strava.

### P2P Attestation
Users can attest to the activity by submitting photos.

### Staking Logic
Users can stake tokens based on their activities.

Here's a version of such a contract:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProofOfActivityStake {
    // Struct to store activity details
    struct Activity {
        string stravaActivityId;  // Unique identifier for the Strava activity
        address user;             // Address of the user who completed the activity
        string activityData;      // Data of the activity (e.g., distance, duration)
        bool isCompleted;         // Flag indicating if the activity is completed
        uint256 stakedAmount;     // Amount of tokens staked on the activity
        string photoHash;         // Hash of the photo for P2P attestation
    }

    // Mapping from Strava activity ID to Activity details
    mapping(string => Activity) public activities;
    // Mapping from user address to their staked token amount
    mapping(address => uint256) public stakes;

    // Event emitted when an activity is completed
    event ActivityCompleted(string indexed stravaActivityId, address indexed user, string activityData);
    // Event emitted when an activity is attested with a photo
    event ActivityAttested(string indexed stravaActivityId, address indexed user, string photoHash);
    // Event emitted when tokens are staked on an activity
    event TokensStaked(address indexed user, uint256 amount);

    // Function to mark an activity as completed
    function completeActivity(string memory stravaActivityId, string memory activityData) public {
        require(bytes(activityData).length > 0, "Activity data cannot be empty");

        // Store the activity details in the mapping
        activities[stravaActivityId] = Activity({
            stravaActivityId: stravaActivityId,
            user: msg.sender,
            activityData: activityData,
            isCompleted: true,
            stakedAmount: 0,
            photoHash: ""
        });

        // Emit an event for activity completion
        emit ActivityCompleted(stravaActivityId, msg.sender, activityData);
    }

    // Function for users to attest to their activity with a photo
    function attestActivity(string memory stravaActivityId, string memory photoHash) public {
        Activity storage activity = activities[stravaActivityId];
        require(activity.isCompleted, "Activity not completed");
        require(activity.user == msg.sender, "Only the user who completed the activity can attest");

        // Store the photo hash for attestation
        activity.photoHash = photoHash;

        // Emit an event for activity attestation
        emit ActivityAttested(stravaActivityId, msg.sender, photoHash);
    }

    // Function for users to stake tokens on their completed activity
    function stakeTokens(string memory stravaActivityId, uint256 amount) public {
        Activity storage activity = activities[stravaActivityId];
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

# Key Functionalities of the ProofOfActivityStake Contract

## Overview
The `ProofOfActivityStake` contract is designed to integrate with Strava activities, enabling users to:
1. Record and verify their activities.
2. Provide peer-to-peer (P2P) attestations with photos.
3. Stake tokens based on their completed activities.

## Core Functionalities

### Tracking Activity Completion

#### Function: `completeActivity`
- **Purpose:** To record the completion of an activity from Strava.
- **Inputs:**
  - `stravaActivityId`: A unique identifier for the Strava activity.
  - `activityData`: Details about the activity (e.g., distance, duration).
- **Behavior:**
  - Validates that the activity data is not empty.
  - Creates an `Activity` struct with the provided details and stores it in the `activities` mapping.
  - Sets `isCompleted` to `true` to indicate the activity is completed.
  - Emits the `ActivityCompleted` event.

### P2P Attestation

#### Function: `attestActivity`
- **Purpose:** To allow users to attest to their activity by submitting a photo.
- **Inputs:**
  - `stravaActivityId`: The unique identifier for the Strava activity.
  - `photoHash`: The hash of the photo for attestation.
- **Behavior:**
  - Ensures the activity is completed and that the user submitting the attestation is the same user who completed the activity.
  - Stores the photo hash in the corresponding `Activity` struct.
  - Emits the `ActivityAttested` event.

### Staking Logic

#### Function: `stakeTokens`
- **Purpose:** To enable users to stake tokens based on their completed activities.
- **Inputs:**
  - `stravaActivityId`: The unique identifier for the Strava activity.
  - `amount`: The amount of tokens to be staked.
- **Behavior:**
  - Ensures the activity is completed and that the user staking tokens is the same user who completed the activity.
  - Updates the user's total staked tokens and the activity's staked amount.
  - Emits the `TokensStaked` event.

## Events
- `ActivityCompleted`: Emitted when an activity is marked as completed.
- `ActivityAttested`: Emitted when an activity is attested with a photo.
- `TokensStaked`: Emitted when tokens are staked on an activity.

## Mappings
- `activities`: Stores the details of each activity, indexed by `stravaActivityId`.
- `stakes`: Tracks the total amount of tokens staked by each user.

By utilizing these functionalities, the `ProofOfActivityStake` contract ensures a comprehensive system for recording, verifying, and staking on Strava activities, enhancing user engagement and accountability.

