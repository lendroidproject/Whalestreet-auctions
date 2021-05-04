// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;


/**
 * @dev Required interface of an ERC721WhaleStreet compliant contract.
 */
interface IGenArt721Core {

    function mint(address _to, uint256 _projectId, address _by) external returns (uint256 _tokenId);
}
