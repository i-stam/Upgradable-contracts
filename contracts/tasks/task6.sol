pragma solidity ^0.5.0;

// import Ownable library straight from github
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol";

contract ProxyStorage {
    address public implementation;
}

contract Proxy is ProxyStorage, Ownable {

    constructor(address _impl) public {
        implementation = _impl;
    }

    function setImplementation(address _impl) onlyOwner public {
        implementation = _impl;
    }

    function () external payable {

        if (isOwner()){
            address localImpl = implementation;
            assembly {
                let ptr := mload(0x40)
                calldatacopy(ptr, 0, calldatasize)
                let result := delegatecall(gas, localImpl, ptr, calldatasize, 0, 0)
                let size := returndatasize
                returndatacopy(ptr, 0, size)

                switch result
                case 0 { revert(ptr, size) }
                default { return(ptr, size) }
            }
        }
    }

}


contract ScoreStorage {
    uint public score;
}

contract Score is ProxyStorage, Ownable, ScoreStorage {
    function setScore(uint _score) public {
        score = _score;
    }

    function () external payable {
    }
}

contract ScoreV2 is ProxyStorage, Ownable, ScoreStorage {
    function setScore(uint _score) public {
        score = _score + 1;
    }

    function () external payable {
    }
}
