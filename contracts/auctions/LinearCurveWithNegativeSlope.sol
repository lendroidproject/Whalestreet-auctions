// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../heartbeat/Pacemaker.sol";
import "./IAuctionCurve.sol";


// solhint-disable-next-line
abstract contract LinearCurveWithNegativeSlope is IAuctionCurve, Pacemaker, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public maxY;
    uint256 public minY;

    // solhint-disable-next-line func-visibility
    constructor() {
        minY = 1;
    }

    function setMaxY(uint256 value) external onlyOwner {
        require(value > 0, "maxY cannot be 0 or negative");
        maxY = value;
    }

    function setMinY(uint256 value) external onlyOwner {
        require(value > 0, "minY cannot be 0 or negative");
        minY = value;
    }

    function y(DefiKey[] calldata defiKeys) external view override returns (uint256 value) {
        value = ((_y1(defiKeys).sub(1)).mul((EPOCH_PERIOD.sub(_x()))).add(EPOCH_PERIOD)).div(EPOCH_PERIOD);
        if (value > maxY) {
            value = maxY;
        }
        if (value < minY) {
            value = minY;
        }
    }

    function currentEpoch() public view override(IAuctionCurve, Pacemaker) returns (uint256) {
        return super.currentEpoch();
    }

    function _x() private view returns (uint256) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp.sub(epochStartTimeFromTimestamp(block.timestamp));
    }

    function _y1(DefiKey[] memory defiKeys) private view returns (uint256) {
        if (defiKeys.length == 0) {
            return maxY;
        } else if (currentEpoch().sub(defiKeys[defiKeys.length - 1].epoch) == 1) {
            return defiKeys[defiKeys.length - 1].epoch.mul(2);
        } else {
            return defiKeys[defiKeys.length - 1].amount;
        }
    }

}
