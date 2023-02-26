pragma solidity ^0.8.0;

contract ModifiableProxy {
    address private _logic;
    address private _owner;
    uint256 private _version;
    bytes32 private _hash;

    constructor(address logic_, bytes32 hash_) {
        _logic = logic_;
        _owner = msg.sender;
        _version = 1;
        _hash = hash_;
    }

    function upgrade(address newLogic, bytes32 newHash) public {
        require(msg.sender == _owner, "ModifiableProxy: sender must be the owner");
        require(newLogic != address(0), "ModifiableProxy: new logic address is zero");
        require(newHash != bytes32(0), "ModifiableProxy: new hash is zero");

        // Update version and hash
        _version++;
        _hash = newHash;

        // Call implementation migration function
        (bool success, ) = newLogic.delegatecall(abi.encodeWithSignature("migration()"));
        require(success, "ModifiableProxy: migration failed");

        // Update logic address
        _logic = newLogic;

        emit Upgraded(newLogic, _version, newHash);
    }

    function getLogic() public view returns (address) {
        return _logic;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    function getVersion() public view returns (uint256) {
        return _version;
    }

    function getHash() public view returns (bytes32) {
        return _hash;
    }

		function checkHashAndVersion(bytes32 expectedHash, uint expectedVersion) public view returns(bool) {
		    bytes32 actualHash = keccak256(abi.encodePacked(logicContract));
		    return (actualHash == expectedHash && version == expectedVersion);
		}

    event Upgraded(address indexed newLogic, uint256 indexed version, bytes32 indexed newHash);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

contract DelegationProxy is ModifiableProxy {
    mapping(address => bool) private _delegates;

    constructor(address logic_, bytes32 hash_) ModifiableProxy(logic_, hash_) {}

    function addDelegate(address delegate) public {
        require(msg.sender == getOwner(), "DelegationProxy: sender must be the owner");
        require(delegate != address(0), "DelegationProxy: delegate address is zero");
        _delegates[delegate] = true;
    }

    function removeDelegate(address delegate) public {
        require(msg.sender == getOwner(), "DelegationProxy: sender must be the owner");
        require(delegate != address(0), "DelegationProxy: delegate address is zero");
        _delegates[delegate] = false;
    }

    function isDelegate(address delegate) public view returns (bool) {
        return _delegates[delegate];
    }
}

contract OwnershipProxy is ModifiableProxy {
    constructor(address logic_, bytes32 hash_) ModifiableProxy(logic_, hash_) {}

    function transferOwnership(address newOwner) public {
        require(msg.sender == getOwner(), "OwnershipProxy: sender must be the owner");
        require(newOwner != address(0), "OwnershipProxy: new owner address is zero");
        emit OwnershipTransferred(getOwner(), newOwner);
        _owner = newOwner;
    }
}

contract PublicProxy is ModifiableProxy {
    uint256 public voteStartTime;
    uint256 public voteEndTime;
    uint256 public quorumPercent;
    mapping(address => bool) public voted;
    uint256 public yesVotes;
    uint256 public noVotes;

    constructor(
        address _logic,
        address _admin,
        uint256 _voteStartTime,
        uint256 _voteEndTime,
        uint256 _quorumPercent
    ) ModifiableProxy(_logic, _admin) {
        require(_voteStartTime < _voteEndTime, "Invalid vote time");
        voteStartTime = _voteStartTime;
        voteEndTime = _voteEndTime;
        quorumPercent = _quorumPercent;
    }

    function vote(bool _vote) public {
        require(msg.sender != admin, "Admin cannot vote");
        require(block.timestamp >= voteStartTime, "Voting not yet started");
        require(block.timestamp <= voteEndTime, "Voting has ended");
        require(!voted[msg.sender], "Already voted");
        voted[msg.sender] = true;

        if (_vote) {
            yesVotes += 1;
        } else {
            noVotes += 1;
        }
    }

    function tallyVotes() public view returns (bool) {
        require(block.timestamp > voteEndTime, "Voting still in progress");

        uint256 totalVotes = yesVotes + noVotes;
        uint256 quorum = (totalVotes * quorumPercent) / 100;
        if (totalVotes < quorum) {
            return false;
        }

        if (yesVotes > noVotes) {
            return true;
        } else {
            return false;
        }
    }
}