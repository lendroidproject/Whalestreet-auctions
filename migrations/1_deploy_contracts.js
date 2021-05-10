var MockPacemaker = artifacts.require("MockPacemaker");
var Mock$HRIMP = artifacts.require("Mock$HRIMP");
var LinearCurveWithNegativeSlope = artifacts.require("LinearCurveWithNegativeSlope");
var DefaultKeyMinter = artifacts.require("DefaultKeyMinter");
var MockKovanWhaleSwapAuctionRegistry = artifacts.require("MockKovanWhaleSwapAuctionRegistry");

module.exports = function(deployer) {
    deployer.deploy(MockPacemaker)
        .then(function() {
            return deployer.deploy(Mock$HRIMP);
        })
        .then(function() {
            return deployer.deploy(LinearCurveWithNegativeSlope);
        })
        .then(function() {
            return deployer.deploy(UNIV2SHRIMPPool, Mock$HRIMP.address, MockLSTWETHUNIV2.address);
        })
        .then(function() {
            return deployer.deploy(MockAuctionTokenProbabilityDistribution);
        })
        .then(function() {
            return deployer.deploy(MockKovanWhaleSwapAuctionRegistry,
                Mock$HRIMP.address, WhaleSwapToken.address, MockAuctionTokenProbabilityDistribution.address
            );
        });
};
