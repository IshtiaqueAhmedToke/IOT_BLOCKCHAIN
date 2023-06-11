// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AgricultureDApp {
    struct Participant {
        uint256 id;
        uint256 balance;
        uint256 ranking;
        address sensorAddress;
    }

    struct MoistureReading {
        uint256 timestamp;
        uint256 moisturePercentage;
    }

    mapping(address => Participant) public participants;
    mapping(address => MoistureReading[]) public moistureReadings;
    mapping(address => string) public ipfsHashes; // Mapping to store IPFS hashes
    address[] public rankedSensors;

    event Reward(address indexed participant, uint256 amount);
    event Punishment(address indexed participant, uint256 amount);

    constructor() {
        // Initialize participants and their initial balances
        participants[msg.sender] = Participant(1, 0, 0, msg.sender);
        rankedSensors.push(msg.sender);
    }

    modifier onlyParticipant() {
        require(participants[msg.sender].id != 0, "Only participants can call this function");
        _;
    }

    function addMoistureReading(uint256 _timestamp, uint256[] calldata _moisturePercentages) external onlyParticipant {
        require(_moisturePercentages.length == 3, "Invalid moisture reading");

        // Store the moisture readings for each sensor
        MoistureReading[] storage readings = moistureReadings[msg.sender];
        for (uint256 i = 0; i < _moisturePercentages.length; i++) {
            readings.push(MoistureReading(_timestamp, _moisturePercentages[i]));
        }

        // Store the IPFS hash associated with the readings
        ipfsHashes[msg.sender] = "QmehRink16TsE1SVyfDTxByhBFezWsGNo4cdfk1mfNrygf";

        // Check if the moisture percentage is less than 30% for more than a day
        if (checkMoistureThreshold(msg.sender)) {
            // Penalize participant and emit Punishment event
            uint256 punishmentAmount = 100; // Set the punishment amount (adjust accordingly)
            participants[msg.sender].balance -= punishmentAmount;
            emit Punishment(msg.sender, punishmentAmount);
        } else {
            // Reward participant and emit Reward event
            uint256 rewardAmount = 100; // Set the reward amount (adjust accordingly)
            participants[msg.sender].balance += rewardAmount;
            emit Reward(msg.sender, rewardAmount);
        }

        updateRankings();
    }

    function updateRankings() internal {
        for (uint256 i = rankedSensors.length - 1; i > 0; i--) {
            address currentSensor = rankedSensors[i];
            address previousSensor = rankedSensors[i - 1];

            if (participants[currentSensor].balance > participants[previousSensor].balance) {
                rankedSensors[i] = previousSensor;
                rankedSensors[i - 1] = currentSensor;
            } else {
                break;
            }
        }

        // Update rankings in Participant struct
        for (uint256 i = 0; i < rankedSensors.length; i++) {
            participants[rankedSensors[i]].ranking = i + 1;
        }
    }

    function checkMoistureThreshold(address _sensorAddress) internal view returns (bool) {
        MoistureReading[] storage readings = moistureReadings[_sensorAddress];
        uint256 currentTime = block.timestamp;
        uint256 count = 0;

        for (uint256 i = 0; i < readings.length; i++) {
            if (currentTime - readings[i].timestamp <= 1 days && readings[i].moisturePercentage < 35) {
                count++;
                if (count >= 3) {
                    return true;
                }
            } else {
                count = 0;
            }
        }

        return false;
    }
}