// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../../auctions/IRandomMinter.sol";
import "./IGenArt721Core.sol";


contract ArtBlocksKeyMinter is IRandomMinter, Ownable {

    enum Rarity { REGULAR, UNIQUE, LEGENDARY }

    mapping(Rarity => uint256) public artblocksProjectIds;
    mapping(Rarity => address) public artblocksArtistAddresses;

    mapping(Rarity => uint256) public feePercentages;

    IGenArt721Core public auctionToken;

    // solhint-disable-next-line func-visibility
    constructor(address[4] memory artblocksAndArtistAddresses) {
        artblocksProjectIds[Rarity.REGULAR] = 75;
        artblocksProjectIds[Rarity.UNIQUE] = 76;
        artblocksProjectIds[Rarity.LEGENDARY] = 76;
        feePercentages[Rarity.REGULAR] = 50;
        feePercentages[Rarity.UNIQUE] = 20;
        feePercentages[Rarity.LEGENDARY] = 5;
        artblocksArtistAddresses[Rarity.REGULAR] = artblocksAndArtistAddresses[1];
        artblocksArtistAddresses[Rarity.UNIQUE] = artblocksAndArtistAddresses[2];
        artblocksArtistAddresses[Rarity.LEGENDARY] = artblocksAndArtistAddresses[3];
        auctionToken = IGenArt721Core(artblocksAndArtistAddresses[0]);
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
        address artist;
        if (randomResult > 0 && randomResult <= 15) {
            projectId = artblocksProjectIds[Rarity.LEGENDARY];
            artist = artblocksArtistAddresses[Rarity.LEGENDARY];
            feePercentage = feePercentages[Rarity.LEGENDARY];
        } else if (randomResult > 15 && randomResult <= 50) {
            projectId = artblocksProjectIds[Rarity.UNIQUE];
            artist = artblocksArtistAddresses[Rarity.UNIQUE];
            feePercentage = feePercentages[Rarity.UNIQUE];
        } else {
            projectId = artblocksProjectIds[Rarity.REGULAR];
            artist = artblocksArtistAddresses[Rarity.REGULAR];
            feePercentage = feePercentages[Rarity.REGULAR];
        }
        newTokenId = auctionToken.mint(to, projectId, artist);
    }

    function transferOwnership(address newOwner) public override(IRandomMinter, Ownable) onlyOwner {
        require(newOwner != address(0), "{transferOwnership} : invalid new owner");
        super.transferOwnership(newOwner);
    }

}
