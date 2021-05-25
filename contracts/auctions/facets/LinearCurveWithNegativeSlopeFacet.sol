// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Modifiers} from "../libraries/LibAppStorage.sol";


contract LinearCurveWithNegativeSlopeFacet is Modifiers {

    using SafeMath for uint256;

    uint256 public maxY;
    uint256 public minY;

    function setMaxY(uint256 value) external onlyOwner {
        require(value > 0, "maxY cannot be 0 or negative");
        maxY = value;
    }

    function setMinY(uint256 value) external onlyOwner {
        require(value > 0, "minY cannot be 0 or negative");
        // for this slope, minY = 1
        minY = value;
    }

    function y() external view returns (uint256 value) {
        value = ((_y1().sub(1)).mul((EPOCH_PERIOD.sub(_x()))).add(EPOCH_PERIOD)).div(EPOCH_PERIOD);
        if (value > maxY) {
            value = maxY;
        }
        if (value < minY) {
            value = minY;
        }
    }

    function _x() private view returns (uint256) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp.sub(epochStartTimeFromTimestamp(block.timestamp));
    }

    function _y1() private view returns (uint256) {
        if (s.defiKeys.length == 0) {
            return maxY;
        } else if (currentEpoch().sub(s.defiKeys[s.defiKeys.length - 1].epoch) == 1) {
            return s.defiKeys[s.defiKeys.length - 1].epoch.mul(2);
        } else {
            return s.defiKeys[s.defiKeys.length - 1].amount;
        }
    }

}
