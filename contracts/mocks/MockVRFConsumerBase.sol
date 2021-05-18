// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;

import "@chainlink/contracts/src/v0.7/vendor/SafeMathChainlink.sol";
import "../chainlink/VRFConsumerBase.sol";


 // solhint-disable-next-line
abstract contract MockVRFConsumerBase is VRFConsumerBase {

    using SafeMathChainlink for uint256;

    uint256 private lastRequestId;

    function requestRandomness(bytes32 _keyHash, uint256 _fee, uint256 _seed) internal override
    returns (bytes32 requestId) {
        lastRequestId = lastRequestId.add(1);
        uint256 randomness = lastRequestId % 100;
        fulfillRandomness(bytes32(lastRequestId), randomness);
        return bytes32(lastRequestId);
    }

}
