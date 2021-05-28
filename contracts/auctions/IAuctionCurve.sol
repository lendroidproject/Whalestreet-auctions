// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;
// pragma abicoder v2;
pragma experimental ABIEncoderV2;

import "./Structs.sol";


/**
 * @dev Required interface of an AuctionCurve compliant contract.
 */
interface IAuctionCurve {

    function epochFromTimestamp(uint256 timestamp) external pure returns (uint256);

    function epochStartTimeFromTimestamp(uint256 timestamp) external pure returns (uint256);

    function epochEndTimeFromTimestamp(uint256 timestamp) external pure returns (uint256);

    function currentEpoch() external view returns (uint256);

    function y(DefiKey[] calldata defiKeys) external view returns (uint256 value);
}