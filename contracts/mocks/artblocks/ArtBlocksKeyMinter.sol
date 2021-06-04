// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../../auctions/IRandomMinter.sol";
import "./IGenArt721Core.sol";


contract ArtBlocksKeyMinter is IRandomMinter, Ownable {

    using Address for address;

    enum Rarity { REGULAR, UNIQUE, LEGENDARY }

    mapping(Rarity => uint256) public artblocksProjectIds;

    mapping(Rarity => uint256) public daoTreasuryFeePercentages;

    IGenArt721Core public auctionToken;

    // solhint-disable-next-line func-visibility
    constructor(address auctionTokenAddress) {
        require(auctionTokenAddress.isContract(), "{ArtBlocksKeyMinter} : invalid auctionTokenAddress");
        artblocksProjectIds[Rarity.REGULAR] = 79;
        artblocksProjectIds[Rarity.UNIQUE] = 80;
        artblocksProjectIds[Rarity.LEGENDARY] = 81;
        daoTreasuryFeePercentages[Rarity.REGULAR] = 50;
        daoTreasuryFeePercentages[Rarity.UNIQUE] = 25;
        daoTreasuryFeePercentages[Rarity.LEGENDARY] = 5;
        auctionToken = IGenArt721Core(auctionTokenAddress);
    }

    function currentOwner() external view override returns (address) {
        return owner();
    }

    function mintWithRandomness(uint256 randomResult, address to) public onlyOwner override returns(
        address newTokenAddress, uint256 newTokenId, uint256 feePercentage) {
        newTokenAddress = address(auctionToken);
        require(newTokenAddress != address(0), "auctionToken address is zero");
        require((randomResult > 0) && (randomResult <= 100), "Invalid randomResult");
        uint256 projectId;
        if (randomResult > 0 && randomResult <= 15) {
            projectId = artblocksProjectIds[Rarity.LEGENDARY];
            feePercentage = daoTreasuryFeePercentages[Rarity.LEGENDARY];
        } else if (randomResult > 15 && randomResult <= 50) {
            projectId = artblocksProjectIds[Rarity.UNIQUE];
            feePercentage = daoTreasuryFeePercentages[Rarity.UNIQUE];
        } else {
            projectId = artblocksProjectIds[Rarity.REGULAR];
            feePercentage = daoTreasuryFeePercentages[Rarity.REGULAR];
        }
        address artist = auctionToken.projectIdToArtistAddress(projectId);
        newTokenId = auctionToken.mint(to, projectId, artist);
    }

    function transferOwnership(address newOwner) public override(IRandomMinter, Ownable) onlyOwner {
        require(newOwner != address(0), "{transferOwnership} : invalid new owner");
        super.transferOwnership(newOwner);
    }

}
