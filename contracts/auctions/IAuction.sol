// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;


/**
 * @dev Required interface of an Auction compliant contract.
 */
interface IAuction {
    // admin functions
    function setKeyMinter(address keyMinterAddress) external;
    function setKeyHash(bytes32 _keyhash) external;
    function setFee(uint256 _fee) external;
    function transferKeyMinterOwnership(address newOwner) external;
    function escapeHatchERC20(address tokenAddress) external;
    // end-user functions
    function totalDefiKeys() external view returns (uint256);
    function percentageFromRandomness(uint256 randomness) external pure returns (uint256);
    function currentPrice() external view returns (uint256);
}
