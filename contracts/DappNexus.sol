// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DappNexus Token (DAPNEX)
 * @dev ERC20 token with owner minting and a referral reward mechanism
 */
contract DappNexus is ERC20, Ownable {
    // Referral reward percentage (e.g., 5%)
    uint256 public referralRewardPercent = 5;

    // Mapping to track if address has claimed referral reward
    mapping(address => bool) public hasClaimedReferral;

    event ReferralRewarded(address indexed referrer, address indexed referee, uint256 rewardAmount);
    event ReferralRewardPercentUpdated(uint256 newPercent);

    constructor(uint256 initialSupply) ERC20("DappNexus", "DAPNEX") {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Mint tokens to an address (owner only)
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Users claiming rewards through referrals.
     * The referee must not have claimed before.
     * The referrer receives a referral reward in tokens minted on-demand.
     * @param referrer Address of the user who referred the caller
     */
    function claimReferral(address referrer) external {
        require(referrer != address(0), "Invalid referrer");
        require(referrer != msg.sender, "Self-referral not allowed");
        require(!hasClaimedReferral[msg.sender], "Referral already claimed");

        hasClaimedReferral[msg.sender] = true;

        // Calculate referral reward: percentage of referee's reward base (fixed here as 100 tokens)
        uint256 baseReward = 100 * 10**decimals();
        uint256 rewardAmount = (baseReward * referralRewardPercent) / 100;

        _mint(referrer, rewardAmount);

        emit ReferralRewarded(referrer, msg.sender, rewardAmount);
    }

    /**
     * @dev Update referral reward percent (owner only)
     */
    function updateReferralRewardPercent(uint256 newPercent) external onlyOwner {
        require(newPercent <= 20, "Referral percent too high");
        referralRewardPercent = newPercent;
        emit ReferralRewardPercentUpdated(newPercent);
    }
}
