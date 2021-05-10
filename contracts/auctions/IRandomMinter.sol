// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;


/**
 * @dev Required interface of an AuctionTokenProbabilityDistribution compliant contract.
 */
interface IRandomMinter {
    function mintWithRandomness(uint256 randomResult, address to) external returns(
        address newTokenAddress, uint256 newTokenId, uint256 feePercentage);

    function transferOwnership(address newOwner) external;

    function currentOwner() external view returns (address);
}
