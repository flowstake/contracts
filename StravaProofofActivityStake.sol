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
