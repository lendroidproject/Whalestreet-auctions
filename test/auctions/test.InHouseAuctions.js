const timeMachine = require("ganache-time-traveler");
const linearAuctionPriceY = require("../helpers/linearAuctionPriceY");

const {
    BN,           // Big Number support
    // constants,    // Common constants, like the zero address and largest integers
    // expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
    time,         // Converts to Time
    ether,        // Converts to ether
} = require("@openzeppelin/test-helpers");

const { expect } = require("chai");

const Mock$HRIMP = artifacts.require("Mock$HRIMP");
const AuctionToken = artifacts.require("AuctionToken");
const LinearCurveWithNegativeSlope = artifacts.require("MockLinearCurveWithNegativeSlope");
const DefaultKeyMinter = artifacts.require("DefaultKeyMinter");
const MockVRFAuctions = artifacts.require("MockVRFAuctions");

contract("MockVRFAuctions", (accounts) => {

    const owner = accounts[0];
    const tester = accounts[1];
    const EPOCHPERIOD = 28800;

    let purchaseToken, auctionToken, auctionCurve, keyMinter, auctionRegistry;

    before(async () => {
        purchaseToken = await Mock$HRIMP.deployed();
        auctionToken = await AuctionToken.deployed();
        auctionCurve = await LinearCurveWithNegativeSlope.deployed();
        keyMinter = await DefaultKeyMinter.deployed();
        auctionRegistry = await MockVRFAuctions.deployed();
        console.log([
            owner,
            purchaseToken.address,
            auctionToken.address,
            auctionCurve.address,
            keyMinter.address,
            auctionRegistry.address
        ]);
    });

    describe("setup", () => {

        it("deploys successfully", async () => {
            assert.equal(await auctionRegistry.purchaseToken(), purchaseToken.address, "purchaseToken cannot be zero address");
            assert.equal(await auctionRegistry.auctionCurve(), auctionCurve.address, "auctionCurve is incorrect");

            // auctionCurve setup
            // Set maxY on auctionCurve
            await auctionCurve.setMaxY(ether("300000"), { from: owner });
            // tester setup
            // Mint 350,000 reward token to tester
            await purchaseToken.mint(tester, ether("350000"));
            // Approve 1 purchaseToken to the auctionRegistry from tester
            await purchaseToken.approve(auctionRegistry.address, ether("350000"), { from: tester });

            // transfer acutionToken ownership to keyMinter
            assert.equal(await auctionToken.owner() === owner, true);
            await auctionToken.transferOwnership(keyMinter.address, { from: owner });
            assert.equal(await auctionToken.owner() === keyMinter.address, true);

            // transfer keyMinter ownership to auctionRegistry
            assert.equal(await keyMinter.currentOwner() === owner, true);
            await keyMinter.transferOwnership(auctionRegistry.address, { from: owner });
            assert.equal(await keyMinter.currentOwner() === auctionRegistry.address, true);
        });

    });

    describe("purchase", () => {

        beforeEach(async () => {
            snapshotId = (await timeMachine.takeSnapshot())["result"];
        });

        afterEach(async () => {
            await timeMachine.revertToSnapshot(snapshotId);
        });

        it("first purchase succeeds", async () => {
            expect(await auctionRegistry.totalDefiKeys()).to.be.bignumber.equal("0");
            expect(await purchaseToken.balanceOf(tester)).to.be.bignumber.equal(ether("350000"));
            expect(await purchaseToken.balanceOf(auctionRegistry.address)).to.be.bignumber.equal(ether("0"));
            // Make first purchase with 1 purchaseToken
            currentEpoch = await auctionCurve.currentEpoch();
            y1 = 300000;
            x = (await time.latest()).toNumber() - (await auctionCurve.epochStartTimeFromTimestamp(await time.latest())).toNumber();
            expectedCurrentPrice = linearAuctionPriceY(y1, x);
            auctionCurrentPrice = await auctionRegistry.currentPrice();

            await auctionRegistry.purchase({ from: tester });
            expect(await auctionRegistry.totalDefiKeys()).to.be.bignumber.equal("1");
        });

        it("fails for consecutive purchases within same epoch", async () => {
            await auctionRegistry.purchase({ from: tester });
            // Conditions that trigger a require statement can be precisely tested
            await expectRevert(
                auctionRegistry.purchase({ from: tester }),
                "Current price is 0",
            );
        });
    });

    describe("currentPrice", () => {

        beforeEach(async () => {
            snapshotId = (await timeMachine.takeSnapshot())["result"];
        });

        afterEach(async () => {
            await timeMachine.revertToSnapshot(snapshotId);
        });

        it("0 after purchase for given epoch", async () => {
            await auctionRegistry.purchase({ from: tester });
            expect(await auctionRegistry.currentPrice()).to.be.bignumber.equal(ether("0"));
        });

        it("at start of next epoch equals 2x last purchase amount", async () => {
            const latest = await time.latest();
            const endTime = await auctionCurve.epochEndTimeFromTimestamp(latest);

            await timeMachine.advanceBlockAndSetTime(endTime.toNumber() - (EPOCHPERIOD / 2));

            await auctionRegistry.purchase({ from: tester });
            const purchase = await auctionRegistry.defiKeys(0);
            auctionCurrentPrice = purchase.amount.mul(new BN(2)).sub(new BN(28800));

            await timeMachine.advanceBlockAndSetTime(endTime.toNumber());

            expect(await auctionRegistry.currentPrice())
                .to.be.bignumber
                .equal((auctionCurrentPrice).toString());
        });

        it("at end of epoch price will be at 1", async () => {
            const latest = await time.latest();
            const endTime = await auctionCurve.epochEndTimeFromTimestamp(latest);

            await timeMachine.advanceBlockAndSetTime(endTime.toNumber() - 1);

            expect(await auctionRegistry.currentPrice())
                .to.be.bignumber
                .equal("10416666666666695465"); // ether("1").mul(new BN(300000)).div(new BN(EPOCHPERIOD))
        });

    });

});
