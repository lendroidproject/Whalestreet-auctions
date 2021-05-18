const timeMachine = require("ganache-time-traveler");
const linearAuctionPriceY = require("../helpers/linearAuctionPriceY");

const {
    // BN,           // Big Number support
    // constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
    time,         // Converts to Time
    ether,        // Converts to ether
} = require("@openzeppelin/test-helpers");

const { expect } = require("chai");

const Mock$HRIMP = artifacts.require("Mock$HRIMP");
const AuctionToken = artifacts.require("AuctionToken");
const LinearCurveWithNegativeSlope = artifacts.require("MockLinearCurveWithNegativeSlope");
const MockVRFAuctions = artifacts.require("MockVRFAuctions");

contract("MockVRFAuctions", (accounts) => {

    // const owner = accounts[0];
    const tester = accounts[1];
    const EPOCHPERIOD = 28800;

    let purchaseToken, auctionToken, auctionRegistry, auctionCurve;

    before(async () => {
        purchaseToken = await Mock$HRIMP.deployed();
        auctionToken = await AuctionToken.deployed();
        auctionCurve = await LinearCurveWithNegativeSlope.deployed();
        auctionRegistry = await MockVRFAuctions.deployed();
        console.log([
            purchaseToken.address,
            auctionToken.address,
            auctionCurve.address,
            auctionRegistry.address
        ]);
    });

    describe("constructor", () => {

        after(async () => {
            // Mint 350,000 reward token to tester
            await purchaseToken.mint(tester, ether("350000"));
            // Approve 1 purchaseToken to the auctionRegistry from tester
            await purchaseToken.approve(auctionCurve.address, ether("350000"), { from: tester });
            // Set maxY
            await auctionCurve.setMaxY(ether("300000"));
        });

        it("deploys successfully", async () => {
            assert.equal(await auctionRegistry.purchaseToken(), purchaseToken.address, "purchaseToken cannot be zero address");
            // assert.equal(await auctionRegistry.auctionToken(), auctionToken.address, "auctionToken is incorrect");
            assert.equal(await auctionRegistry.auctionCurve(), auctionCurve.address, "auctionCurve is incorrect");
            // assert.equal(await auctionRegistry.purchaseLocked(), false, "purchaseLocked is incorrect");
        });

    });

    describe("purchase", () => {

        beforeEach(async () => {
            snapshotId = (await timeMachine.takeSnapshot())["result"];
        });

        afterEach(async () => {
            await timeMachine.revertToSnapshot(snapshotId);
        });

        it("it succeeds", async () => {
            expect(await auctionRegistry.totalDefiKeys()).to.be.bignumber.equal("0");
            expect(await purchaseToken.balanceOf(tester)).to.be.bignumber.equal(ether("350000"));
            expect(await purchaseToken.balanceOf(auctionRegistry.address)).to.be.bignumber.equal(ether("0"));
            // Make first purchase with 1 purchaseToken
            currentEpoch = await auctionRegistry.currentEpoch();
            y1 = 300000;
            x = (await time.latest()).toNumber() - (await auctionRegistry.epochStartTimeFromTimestamp(await time.latest())).toNumber();
            currentPrice = linearAuctionPriceY(y1, x);
            console.log(`currentPrice : ${await auctionRegistry.currentPrice()}`);
            console.log(`currentPrice : ${currentPrice}`);
            const txReceipt = await auctionRegistry.purchase({ from: tester });
            expectEvent(txReceipt, "PurchaseMade", {
                account: tester,
                epoch: currentEpoch,
                purchaseAmount: ether("300000")
            });
            expect(await auctionRegistry.totalDefiKeys()).to.be.bignumber.equal("1");
            expect(await purchaseToken.balanceOf(tester)).to.be.bignumber.equal(ether("50000"));
            expect(await purchaseToken.balanceOf(auctionRegistry.address)).to.be.bignumber.equal(ether("300000"));
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

        it("at start of next epoch equals last purchase amount", async () => {
            currentPrice = await auctionRegistry.currentPrice();
            await auctionRegistry.purchase({ from: tester });
            await timeMachine.advanceTimeAndBlock((await auctionRegistry.epochEndTimeFromTimestamp(await time.latest())).toNumber() - (await time.latest()).toNumber() + 1);
            expect(await auctionRegistry.currentPrice()).to.be.bignumber.equal(currentPrice.toString());
        });

        it("at end of next epoch is nearly 1/2 last purchase amount", async () => {
            expect(await auctionRegistry.currentPrice()).to.be.bignumber.equal(ether("1"));
            await auctionRegistry.purchase({ from: tester });
            await timeMachine.advanceTimeAndBlock((await auctionRegistry.epochEndTimeFromTimestamp(await time.latest())).toNumber() - (await time.latest()).toNumber() + EPOCHPERIOD - 1);
            expect(await auctionRegistry.currentPrice()).to.be.bignumber.equal("500052083333333333");
        });

    });

});
