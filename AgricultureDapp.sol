// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract SensorRanking {
    struct Sensor {
        string sensorId;
        int totalWeight;
    }

    Sensor[] public sensors;
    mapping(string => uint) public sensorIndex;
    uint public centralWeightPool = 50000;

    constructor() {
        addSensorReading("Sensor1", 3600, 600);
        addSensorReading("Sensor1", 3500, 650);
        addSensorReading("Sensor1", 3700, 550);

        addSensorReading("Sensor2", 4000, 700);
        addSensorReading("Sensor2", 3900, 600);
        addSensorReading("Sensor2", 4100, 550);

        addSensorReading("Sensor3", 3100, 500);
        addSensorReading("Sensor3", 3000, 600);
        addSensorReading("Sensor3", 3200, 550);
    }

    function calculateWeight(int moisture, int ph) private pure returns (int) {
        int moistureWeight = (3000 <= moisture && moisture <= 10000) ? int(100) : int(-100);
        int phWeight = (5500 <= ph && ph <= 6500) ? int(50) : int(-50);
        return moistureWeight + phWeight;
    }

    function addSensorReading(string memory sensorId, int moisture, int ph) public {
        int weight = calculateWeight(moisture, ph);

        if (sensorIndex[sensorId] > 0) {
            sensors[sensorIndex[sensorId] - 1].totalWeight += weight;
        } else {
            sensors.push(Sensor(sensorId, weight));
            sensorIndex[sensorId] = sensors.length;
        }

        if (weight > 0) {
            centralWeightPool -= uint(weight);
        } else {
            centralWeightPool += uint(-weight);
        }
    }

    function sortSensors() public {
        uint n = sensors.length;
        for(uint i = 0; i < n; i++) {
            for(uint j = 0; j < n - i - 1; j++) {
                if(sensors[j].totalWeight < sensors[j + 1].totalWeight) {
                    Sensor memory temp = sensors[j];
                    sensors[j] = sensors[j + 1];
                    sensors[j + 1] = temp;
                }
            }
        }
    }

    function getSensorCount() public view returns (uint) {
        return sensors.length;
    }

    function getSensor(uint index) public view returns (string memory, int) {
        return (sensors[index].sensorId, sensors[index].totalWeight);
    }
    
    function getSortedSensors() public view returns (string[] memory) {
        string[] memory sensorIds = new string[](sensors.length);
        for (uint i = 0; i < sensors.length; i++) {
            sensorIds[i] = sensors[i].sensorId;
        }
        return sensorIds;
    }

    function getCentralWeightPool() public view returns (uint) {
        return centralWeightPool;
    }
}
