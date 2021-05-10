// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./IAuction.sol";
import "./IRandomMinter.sol";
import "./IAuctionCurve.sol";

// solhint-disable-next-line
abstract contract BaseAuctions is IAuction, Ownable {

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

    function setKeyMinter(address keyMinterAddress) external override onlyOwner {
        require(keyMinterAddress != address(0),
            "{setKeyMinter} : invalid keyMinterAddress");
        keyMinter = IRandomMinter(keyMinterAddress);
    }

    function setKeyHash(bytes32 _keyhash) external override onlyOwner {
        keyHash = _keyhash;
    }

    function setFee(uint256 _fee) external override onlyOwner {
        fee = _fee;
    }

    function transferKeyMinterOwnership(address newOwner) external override onlyOwner {
        require(newOwner != address(0), "{transferKeyMinterOwnership} : invalid newOwner");
        // transfer ownership of Auction Token Distribution contract to newOwner
        keyMinter.transferOwnership(newOwner);
    }

    /**
    * @notice Safety function to handle accidental / excess token transfer to the contract
    */
    function escapeHatchERC20(address tokenAddress) external override onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        token.safeTransfer(owner(), token.balanceOf(address(this)));
    }

    function totalDefiKeys() external view override returns (uint256) {
        return defiKeys.length;
    }

    function percentageFromRandomness(uint256 randomness) public pure override returns (uint256) {
        return randomness.mod(100);
    }

    function currentPrice() public view override returns (uint256) {
        if ((defiKeys.length > 0) && (defiKeys[defiKeys.length - 1].epoch == auctionCurve.currentEpoch())) {
            return 0;
        } else {
            return auctionCurve.y(defiKeys);
        }
    }

}
