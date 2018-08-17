pragma solidity ^0.4.24;
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */

contract Ownable {
    address public owner;
    address public creater;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function Ownable(address _owner) public {
        creater = msg.sender;
        if (_owner != 0) {
            owner = _owner;

        }
        else {
            owner = creater;
        }

    }
    /**
    * @dev Throws if called by any account other than the owner.
    */

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier isCreator() {
        require(msg.sender == creater);
        _;
    }

   

}
