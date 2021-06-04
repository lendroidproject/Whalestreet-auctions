var MockPacemaker = artifacts.require("MockPacemaker");
var Mock$HRIMP = artifacts.require("Mock$HRIMP");
var MockLinearCurveWithNegativeSlope = artifacts.require("MockLinearCurveWithNegativeSlope");
var AuctionToken = artifacts.require("AuctionToken");
var DefaultKeyMinter = artifacts.require("DefaultKeyMinter");
var MockVRFAuctions = artifacts.require("MockVRFAuctions");

module.exports = function (deployer, network, accounts) {
    console.log(network, accounts[0]);
    deployer.deploy(MockPacemaker)
        .then(function () {
            return deployer.deploy(Mock$HRIMP);
        })
        .then(function () {
            return deployer.deploy(MockLinearCurveWithNegativeSlope);
        })
        .then(function () {
            return deployer.deploy(AuctionToken, "Test Auction", "TNFT");
        })
        .then(function () {
            return deployer.deploy(DefaultKeyMinter, AuctionToken.address);
        })
        .then(function () {
            return deployer.deploy(MockVRFAuctions,
                accounts[0],
                MockLinearCurveWithNegativeSlope.address, Mock$HRIMP.address, DefaultKeyMinter.address,
                "0xA62CD0D666A779337281A6Df80f48678679Ee3Cb", // VRF Coordinator
                "0x587F590DFf46fdFb5C73F580C665aee257351660", // LINK Token
                "0x8a962b8a9a6ace7378310449bf5cc8fd4c369774e7de097ff7a504f05680235e", // keyHash
                "100000000000000000" // 0.1 LINK
            );
        });
};
