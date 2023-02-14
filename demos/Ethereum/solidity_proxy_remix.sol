// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Proxy {
    address private target;
    address private owner;

    constructor(address _target) {
        target = _target;
        owner = msg.sender;
    }

    fallback() external payable {
        console.log("Proxy called");
        (bool success, bytes memory data) = target.call(msg.data);
        console.log("Delegation successful?", success);

    }
    // increase(): e8927fbc
    // decrease(): d732d955

    function changeTarget(address newTarget) public {
        require(msg.sender == owner, "Only the owner can change the target contract");
        target = newTarget;
    }
}

contract RealContract1 {
    uint public num;

    constructor() {
        num = 0;
    }

    function increase() public {
        num = num + 1;
        console.log("RealContract1 increase called, new num: ", num);
    }
    function decrease() public {
        num = num - 1;
        console.log("RealContract1 decrease called, new num: ", num);
    }
}

contract RealContract2 {
    uint public num;
    uint public step;

    constructor(uint _num, uint _step) {
        num = _num;
        step = _step;
    }

    function increase() public {
        num = num + step;
        console.log("RealContract2 increase called, new num: ", num);
    }
    function decrease() public {
        num = num - step;
        console.log("RealContract2 decrease called, new num: ", num);
    }
    function changeStep(uint _step) public {
        step = _step;
        console.log("RealContract2 changeStep called, new step: ", step);
    }
}

contract RealContract3 {
    string public somethingDifferent;
    
    constructor(string memory _test) {
        somethingDifferent = _test;
    }

    function anotherFunction(string memory _new) public {
        somethingDifferent = _new;
        console.log("RealContract3 anotherFunction called, new str: ", somethingDifferent);
    }

}
