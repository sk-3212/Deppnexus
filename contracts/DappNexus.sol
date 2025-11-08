Referral reward percentage (e.g., 5%)
    uint256 public referralRewardPercent = 5;

    Calculate referral reward: percentage of referee's reward base (fixed here as 100 tokens)
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
// 
End
// 
