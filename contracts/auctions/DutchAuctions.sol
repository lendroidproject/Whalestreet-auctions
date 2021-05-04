// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../chainlink/VRFConsumerBase.sol";
import "./IRandomMinter.sol";
import "./IAuctionCurve.sol";

// solhint-disable-next-line
abstract contract DutchAuctions is VRFConsumerBase, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // calulations
    DefiKey[] public defiKeys;// solhint-disable-line var-name-mixedcase;
    IAuctionCurve public auctionCurve;
    IERC20 public purchaseToken;
    IRandomMinter public keyMinter;
    // vrf
    mapping(bytes32 => uint256) public requestIdToRandomness;
    bytes32 internal keyHash;
    uint256 internal fee;
    // events
    event PurchaseMade(address indexed account, uint256 indexed epoch, uint256 purchaseAmount);

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

    function setKeyMinter(address keyMinterAddress) external onlyOwner {
        require(keyMinterAddress != address(0),
            "{setKeyMinter} : invalid keyMinterAddress");
        keyMinter = IRandomMinter(keyMinterAddress);
    }

    function setKeyHash(bytes32 _keyhash) external onlyOwner {
        keyHash = _keyhash;
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function transferKeyMinterOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "{transferKeyMinterOwnership} : invalid newOwner");
        // transfer ownership of Auction Token Distribution contract to newOwner
        keyMinter.transferOwnership(newOwner);
    }

    /**
    * @notice Safety function to handle accidental / excess token transfer to the contract
    */
    function escapeHatchERC20(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        token.safeTransfer(owner(), token.balanceOf(address(this)));
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

    function totalDefiKeys() external view returns (uint256) {
        return defiKeys.length;
    }

    function percentageFromRandomness(uint256 randomness) public pure returns (uint256) {
        return randomness.mod(100);
    }

    function currentPrice() public view returns (uint256) {
        if ((defiKeys.length > 0) && (defiKeys[defiKeys.length - 1].epoch == auctionCurve.currentEpoch())) {
            return 0;
        } else {
            return auctionCurve.y(defiKeys);
        }
    }

    // solhint-disable-next-line no-unused-vars
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        requestIdToRandomness[requestId] = randomness;
        DefiKey storage key = defiKeys[defiKeys.length - 1];
        // mint nft
        (address tokenAddress, uint256 tokenId) = keyMinter.mintWithRandomness(
            percentageFromRandomness(randomness), key.account);
        key.auctionTokenAddress = tokenAddress;
        key.auctionTokenId = tokenId;
        key.randomness = randomness;
    }

}
