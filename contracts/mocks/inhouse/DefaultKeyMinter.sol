// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../../auctions/IRandomMinter.sol";
import "./IERC721WhaleStreet.sol";


contract DefaultKeyMinter is IRandomMinter, Ownable {

    using Address for address;

    enum Rarity { REGULAR, UNIQUE, LEGENDARY }

    mapping(Rarity => string) internal tokenUris;

    mapping(Rarity => uint256) public daoTreasuryFeePercentages;

    IERC721WhaleStreet public auctionToken;

    // solhint-disable-next-line func-visibility
    constructor(address auctionTokenAddress) {
        require(auctionTokenAddress.isContract(), "{DefaultKeyMinter} : invalid auctionTokenAddress");
        tokenUris[Rarity.REGULAR] = "REGULAR";
        tokenUris[Rarity.UNIQUE] = "UNIQUE";
        tokenUris[Rarity.LEGENDARY] = "LEGENDARY";
        daoTreasuryFeePercentages[Rarity.REGULAR] = 50;
        daoTreasuryFeePercentages[Rarity.UNIQUE] = 25;
        daoTreasuryFeePercentages[Rarity.LEGENDARY] = 5;
        auctionToken = IERC721WhaleStreet(auctionTokenAddress);
    }

    function currentOwner() external view override returns (address) {
        return owner();
    }

    function mintWithRandomness(uint256 randomResult, address to) public onlyOwner override returns(
        address newTokenAddress, uint256 newTokenId, uint256 feePercentage) {
        newTokenAddress = address(auctionToken);
        require(newTokenAddress != address(0), "auctionToken address is zero");
        require((randomResult > 0) && (randomResult <= 100), "Invalid randomResult");
        string memory tokenUri;
        if (randomResult > 0 && randomResult <= 10) {
            tokenUri = tokenUris[Rarity.LEGENDARY];
            feePercentage = daoTreasuryFeePercentages[Rarity.LEGENDARY];
        } else if (randomResult > 15 && randomResult <= 30) {
            tokenUri = tokenUris[Rarity.UNIQUE];
            feePercentage = daoTreasuryFeePercentages[Rarity.UNIQUE];
        } else {
            tokenUri = tokenUris[Rarity.REGULAR];
            feePercentage = daoTreasuryFeePercentages[Rarity.REGULAR];
        }
        newTokenId = auctionToken.getNextTokenId();
        auctionToken.mintToAndSetTokenURI(to, tokenUri);
    }

    function transferOwnership(address newOwner) public override(IRandomMinter, Ownable) onlyOwner {
        require(newOwner != address(0), "{transferOwnership} : invalid new owner");
        super.transferOwnership(newOwner);
    }

}
