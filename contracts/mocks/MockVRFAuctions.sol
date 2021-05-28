// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;
// pragma abicoder v2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../auctions/BaseAuctions.sol";
import "./MockVRFConsumerBase.sol";

// solhint-disable-next-line
contract MockVRFAuctions is BaseAuctions, MockVRFConsumerBase {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    // vrf
    mapping(bytes32 => uint256) public requestIdToKeyId;
    bytes32 internal keyHash;
    uint256 internal fee;

    /**
     * Constructor inherits VRFConsumerBase
     */
    // solhint-disable-next-line func-visibility
    constructor(address daoTreasuryAddress,
            address auctionCurveAddress, address purchaseTokenAddress, address keyMinterAddress,
            address vrfCoordinator, address linkToken, bytes32 vrfKeyHash, uint256 vrfFee
        )
        VRFConsumerBase(vrfCoordinator, linkToken) {// solhint-disable-line func-visibility
            require(daoTreasuryAddress != address(0), "{VRFAuctions} : invalid daoTreasuryAddress");
            require(auctionCurveAddress.isContract(), "{VRFAuctions} : invalid auctionCurveAddress");
            require(purchaseTokenAddress.isContract(), "{VRFAuctions} : invalid purchaseTokenAddress");
            require(keyMinterAddress.isContract(), "{VRFAuctions} : invalid keyMinterAddress");
            daoTreasury = daoTreasuryAddress;
            auctionCurve = IAuctionCurve(auctionCurveAddress);
            purchaseToken = IERC20(purchaseTokenAddress);
            keyMinter = IRandomMinter(keyMinterAddress);
            // vrf
            keyHash = vrfKeyHash;
            fee = vrfFee;
        }

    function setKeyHash(bytes32 _keyhash) external onlyOwner {
        keyHash = _keyhash;
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function purchase() external {
        require(keyMinter.currentOwner() == address(this), "{purchase} : Contract is not owner of keyMinter");
        require(currentPrice() > 0, "{purchase} : Current price is 0");

        // random number
        bytes32 requestId = requestRandomness(keyHash, fee, uint256(address(this)));
        requestIdToKeyId[requestId] = defiKeys.length;
        DefiKey memory newKey = DefiKey({
            epoch: auctionCurve.currentEpoch(),
            amount: auctionCurve.y(defiKeys),
            timestamp: block.timestamp,// solhint-disable-line not-rely-on-time
            auctionTokenAddress: address(0),
            auctionTokenId: 0,
            feePercentage: 0,
            account: msg.sender,
            requestId: requestId,
            randomness: uint256(requestId).mod(100)
        });

        (address tokenAddress, uint256 tokenId, uint256 feePercentage) = keyMinter.mintWithRandomness(
            percentageFromRandomness(newKey.randomness), newKey.account);
        newKey.auctionTokenAddress = tokenAddress;
        newKey.auctionTokenId = tokenId;
        newKey.feePercentage = feePercentage;

        // save purchase
        defiKeys.push(newKey);
        // transfer fee
        purchaseToken.safeTransferFrom(msg.sender, address(daoTreasury), newKey.amount);

        emit PurchaseMade(msg.sender, newKey.epoch, newKey.amount);
    }

    function percentageFromRandomness(uint256 randomness) public pure returns (uint256) {
        return randomness.mod(100);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        revert();
    }

}
