// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserDevice {
    // Role definitions
    uint8 constant ROLE_NONE = 0;
    uint8 constant ROLE_DEFAULT = 1;
    uint8 constant ROLE_SERVICE = 2;
    uint8 constant ROLE_ADMIN = 3;

    struct AccessInfo {
        uint8 role;
        bool hasPhysicalAccess;
        bool hasDigitalAccess;
        bool hasAdminRoomAccess;
        uint256 accessExpiration; // 0 means no expiration
    }
    
    mapping(address => AccessInfo) public accessList;
    address[] public accessArray;
    address public owner;
    address public doorAccount;
    
    event AccessGranted(address indexed user, uint8 role, bool physical, bool digital);
    event AccessRevoked(address indexed user);
    event DoorOpened(address indexed user, uint256 doorId);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == owner || 
                (accessList[msg.sender].role == ROLE_ADMIN && 
                 (accessList[msg.sender].accessExpiration == 0 || block.timestamp < accessList[msg.sender].accessExpiration)), 
                "Only admin can perform this action");
        _;
    }
    
    modifier onlyDoor() {
        require(msg.sender == doorAccount, "Only the door can sign this action");
        _;
    }
    
    constructor(address _doorAccount) {
        owner = msg.sender;
        doorAccount = _doorAccount;
        
        // Give owner admin rights
        accessList[msg.sender] = AccessInfo({
            role: ROLE_ADMIN,
            hasPhysicalAccess: true,
            hasDigitalAccess: true,
            hasAdminRoomAccess: true,
            accessExpiration: 0
        });

        accessArray.push(msg.sender);
    }
    
    function grantAccess(
        address _user, 
        uint8 _role, 
        bool _physical, 
        bool _digital, 
        bool _adminRoom, 
        uint256 _expiration
    ) public onlyAdmin {
        require(_role > ROLE_NONE && _role <= ROLE_ADMIN, "Invalid role");
        if (_role == ROLE_ADMIN && msg.sender != owner) {
            revert("Only owner can grant admin role");
        }

        if (accessList[_user].role == ROLE_NONE) {
            accessArray.push(_user);
        }

        accessList[_user] = AccessInfo({
            role: _role,
            hasPhysicalAccess: _physical,
            hasDigitalAccess: _digital,
            hasAdminRoomAccess: _adminRoom,
            accessExpiration: _expiration
        });

        emit AccessGranted(_user, _role, _physical, _digital);
    }
    
    function revokeAccess(address _user) public onlyAdmin {
        // Can't revoke owner's access
        require(_user != owner, "Cannot revoke owner access");
        
        // If admin trying to revoke another admin, only owner can do that
        if (accessList[_user].role == ROLE_ADMIN && msg.sender != owner) {
            revert("Only owner can revoke admin access");
        }
        
        // Remove from array
        for (uint i = 0; i < accessArray.length; i++) {
            if (accessArray[i] == _user) {
                accessArray[i] = accessArray[accessArray.length - 1];
                accessArray.pop();
                break;
            }
        }
        
        delete accessList[_user];
        emit AccessRevoked(_user);
    }
    
    function getAccessList() public view onlyAdmin returns (address[] memory) {
        return accessArray;
    }
    
    function canOpenPhysicalDoor(address _user) public view returns (bool) {
        AccessInfo memory info = accessList[_user];
        return info.hasPhysicalAccess && 
               info.role > ROLE_NONE && 
               (info.accessExpiration == 0 || block.timestamp < info.accessExpiration);
    }
    
    function canOpenDigitalDoor(address _user) public view returns (bool) {
        AccessInfo memory info = accessList[_user];
        return info.hasDigitalAccess && 
               info.role > ROLE_NONE && 
               (info.accessExpiration == 0 || block.timestamp < info.accessExpiration);
    }

    function openDoor(address _user, uint256 doorId) public onlyDoor {
        AccessInfo memory info = accessList[_user];

        // You may want to check access based on door type, which you can map off-chain or with another mapping
        require(
            info.role > ROLE_NONE &&
            (info.accessExpiration == 0 || block.timestamp < info.accessExpiration),
            "Access Denied"
        );

        emit DoorOpened(_user, doorId);
    }
    
    function canEnterAdminRoom(address _user) public view returns (bool) {
        AccessInfo memory info = accessList[_user];
        return info.hasAdminRoomAccess && 
               info.role > ROLE_NONE &&
               (info.accessExpiration == 0 || block.timestamp < info.accessExpiration);
    }
}
