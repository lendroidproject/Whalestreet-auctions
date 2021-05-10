// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../chainlink/VRFConsumerBase.sol";
import "./BaseAuctions.sol";

// solhint-disable-next-line
abstract contract VRFAuctions is BaseAuctions, VRFConsumerBase {

    using SafeERC20 for IERC20;

    /**
     * Constructor inherits VRFConsumerBase
     */
    // solhint-disable-next-line func-visibility
    constructor(address auctionCurveAddress, address purchaseTokenAddress, address keyMinterAddress,
            address vrfCoordinator, address linkToken, bytes32 vrfKeyHash, uint256 vrfFee
        )
        VRFConsumerBase(vrfCoordinator, linkToken) {// solhint-disable-line func-visibility
            auctionCurve = IAuctionCurve(auctionCurveAddress);
            purchaseToken = IERC20(purchaseTokenAddress);
            keyMinter = IRandomMinter(keyMinterAddress);
            // vrf
            keyHash = vrfKeyHash;
            fee = vrfFee;
        }

    function purchase() external {
        require(keyMinter.currentOwner() == address(this), "{purchase} : Contract is not owner of distribution");
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        require(currentPrice() > 0, "Current price is 0");

        // random number
        bytes32 requestId = requestRandomness(keyHash, fee, uint256(address(this)));
        DefiKey memory newKey = DefiKey({
            epoch: auctionCurve.currentEpoch(),
            amount: auctionCurve.y(defiKeys),
            timestamp: block.timestamp,// solhint-disable-line not-rely-on-time
            auctionTokenAddress: address(0),
            auctionTokenId: 0,
            feePercentage: 0,
            account: msg.sender,
            requestId: requestId,
            randomness: 0
        });
        // save purchase
        defiKeys.push(newKey);
        // transfer fee
        purchaseToken.safeTransferFrom(msg.sender, address(this), newKey.amount);

        emit PurchaseMade(msg.sender, newKey.epoch, newKey.amount);
    }

    // solhint-disable-next-line no-unused-vars
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        requestIdToRandomness[requestId] = randomness;
        DefiKey storage key = defiKeys[defiKeys.length - 1];
        // mint nft
        (address tokenAddress, uint256 tokenId, uint256 feePercentage) = keyMinter.mintWithRandomness(
            percentageFromRandomness(randomness), key.account);
        key.auctionTokenAddress = tokenAddress;
        key.auctionTokenId = tokenId;
        key.feePercentage = feePercentage;
        key.randomness = randomness;
    }
}
