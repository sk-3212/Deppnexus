// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title DappNexus
 * @dev Registry for dApps and their on-chain metadata
 * @notice Developers can register dApps, update metadata, and toggle active status
 */
contract DappNexus {
    address public owner;

    struct Dapp {
        uint256 id;
        address developer;
        string  name;
        string  description;
        string  url;          // landing page or docs URL
        string  metadataURI;  // extended metadata (IPFS/json/etc.)
        string  category;     // e.g. "defi", "nft", "infra"
        uint256 createdAt;
        uint256 updatedAt;
        bool    isActive;
    }

    uint256 public nextDappId;

    // dappId => Dapp
    mapping(uint256 => Dapp) public dapps;

    // developer => dappIds
    mapping(address => uint256[]) public dappsOf;

    event DappRegistered(
        uint256 indexed id,
        address indexed developer,
        string name,
        string category,
        uint256 timestamp
    );

    event DappUpdated(
        uint256 indexed id,
        string name,
        string description,
        string url,
        string metadataURI,
        string category,
        uint256 timestamp
    );

    event DappStatusUpdated(
        uint256 indexed id,
        bool isActive,
        uint256 timestamp
    );

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier dappExists(uint256 id) {
        require(dapps[id].developer != address(0), "Dapp not found");
        _;
    }

    modifier onlyDeveloper(uint256 id) {
        require(dapps[id].developer == msg.sender, "Not developer");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Register a new dApp in the nexus
     */
    function registerDapp(
        string calldata name,
        string calldata description,
        string calldata url,
        string calldata metadataURI,
        string calldata category
    ) external returns (uint256 id) {
        id = nextDappId++;
        Dapp storage d = dapps[id];

        d.id = id;
        d.developer = msg.sender;
        d.name = name;
        d.description = description;
        d.url = url;
        d.metadataURI = metadataURI;
        d.category = category;
        d.createdAt = block.timestamp;
        d.updatedAt = block.timestamp;
        d.isActive = true;

        dappsOf[msg.sender].push(id);

        emit DappRegistered(id, msg.sender, name, category, block.timestamp);
        emit DappUpdated(id, name, description, url, metadataURI, category, block.timestamp);
    }

    /**
     * @dev Update dApp metadata
     */
    function updateDapp(
        uint256 id,
        string calldata name,
        string calldata description,
        string calldata url,
        string calldata metadataURI,
        string calldata category
    )
        external
        dappExists(id)
        onlyDeveloper(id)
    {
        Dapp storage d = dapps[id];

        d.name = name;
        d.description = description;
        d.url = url;
        d.metadataURI = metadataURI;
        d.category = category;
        d.updatedAt = block.timestamp;

        emit DappUpdated(id, name, description, url, metadataURI, category, block.timestamp);
    }

    /**
     * @dev Toggle dApp active status
     */
    function setDappActive(uint256 id, bool active)
        external
        dappExists(id)
        onlyDeveloper(id)
    {
        dapps[id].isActive = active;
        emit DappStatusUpdated(id, active, block.timestamp);
    }

    /**
     * @dev Get all dApp IDs registered by a developer
     */
    function getDappsOf(address developer)
        external
        view
        returns (uint256[] memory)
    {
        return dappsOf[developer];
    }

    /**
     * @dev Transfer registry ownership
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address prev = owner;
        owner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }
}
