// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DeviceDevice {
    address public sensor;
    address public fan;
    int256 public temperature;

    constructor(address _sensor, address _fan) {
        sensor = _sensor;
        fan = _fan;
    }

    modifier onlySensor() {
        require(msg.sender == sensor, "Only sensor can update");
        _;
    }

    function updateTemperature(int256 _temp) public onlySensor {
        temperature = _temp;
    }

    function getTemperature() public view returns (int256) {
        return temperature;
    }
}