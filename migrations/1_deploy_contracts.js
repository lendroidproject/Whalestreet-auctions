var MockPacemaker = artifacts.require("MockPacemaker");
var Mock$HRIMP = artifacts.require("Mock$HRIMP");
var AuctionToken = artifacts.require("AuctionToken");
var LinearCurveWithNegativeSlope = artifacts.require("LinearCurveWithNegativeSlope");
var DefaultKeyMinter = artifacts.require("DefaultKeyMinter");
var MockVRFAuctions = artifacts.require("MockVRFAuctions");

module.exports = function(deployer) {
    deployer.deploy(MockPacemaker)
        .then(function() {
            return deployer.deploy(Mock$HRIMP);
        })
        .then(function() {
            return deployer.deploy(LinearCurveWithNegativeSlope);
        })
        .then(function() {
            return deployer.deploy(AuctionToken);
        })
        .then(function() {
            return deployer.deploy(DefaultKeyMinter, AuctionToken.address);
        })
        .then(function() {
            return deployer.deploy(MockVRFAuctions,
                LinearCurveWithNegativeSlope.address, Mock$HRIMP.address, DefaultKeyMinter.address,
                0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B,// VRF Coordinator
                0x01BE23585060835E02B77ef475b0Cc51aA1e0709,// LINK Token
                0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311,// keyHash
                0.1 * 10 ** 18// 0.1 LINK
            );
        });
};
