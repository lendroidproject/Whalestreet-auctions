// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;
pragma abicoder v2;

import "./Structs.sol";


/**
 * @dev Required interface of an AuctionCurve compliant contract.
 */
interface IAuctionCurve {

    function currentEpoch() external view returns (uint256);

    function y(DefiKey[] calldata defiKeys) external view returns (uint256 value);
}
