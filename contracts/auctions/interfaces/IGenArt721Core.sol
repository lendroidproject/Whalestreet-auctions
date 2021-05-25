// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;


/**
 * @dev Required interface of an IGenArt721Core compliant contract.
 */
interface IGenArt721Core {

    function mint(address _to, uint256 _projectId, address _by) external returns (uint256 _tokenId);
}
