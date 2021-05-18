// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

/* solhint-disable */
struct DefiKey {
    uint256 epoch;
    uint256 amount;
    uint256 timestamp;
    address auctionTokenAddress;
    uint256 auctionTokenId;
    uint256 feePercentage;
    address account;
    bytes32 requestId;
    uint256 randomness;
}
/* solhint-enable */
