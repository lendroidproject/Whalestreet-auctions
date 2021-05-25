// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Modifiers} from "../../libraries/LibAppStorage.sol";
import "../../interfaces/IERC721WhaleStreet.sol";


contract DefaultKeyMinterFaucet is Modifiers {

    enum Rarity { REGULAR, UNIQUE, LEGENDARY }

    mapping(Rarity => string) public tokenUris;

    mapping(Rarity => uint256) public feePercentages;

    IERC721WhaleStreet public auctionToken;

    // solhint-disable-next-line func-visibility
    function init(address auctionTokenAddress) internal {
        tokenUris[Rarity.REGULAR] = "REGULAR";
        tokenUris[Rarity.UNIQUE] = "UNIQUE";
        tokenUris[Rarity.LEGENDARY] = "LEGENDARY";
        feePercentages[Rarity.REGULAR] = 5;
        feePercentages[Rarity.UNIQUE] = 20;
        feePercentages[Rarity.LEGENDARY] = 50;
        auctionToken = IERC721WhaleStreet(auctionTokenAddress);
    }

    function mintWithRandomness(uint256 randomResult, address to) internal returns(
        address newTokenAddress, uint256 newTokenId, uint256 feePercentage) {
        newTokenAddress = address(auctionToken);
        require(newTokenAddress != address(0), "auctionToken address is zero");
        require((randomResult > 0) && (randomResult <= 100), "Invalid randomResult");
        string memory tokenUri;
        if (randomResult > 0 && randomResult <= 10) {
            tokenUri = tokenUris[Rarity.LEGENDARY];
            feePercentage = feePercentages[Rarity.LEGENDARY];
        } else if (randomResult > 10 && randomResult <= 30) {
            tokenUri = tokenUris[Rarity.UNIQUE];
            feePercentage = feePercentages[Rarity.UNIQUE];
        } else {
            tokenUri = tokenUris[Rarity.REGULAR];
            feePercentage = feePercentages[Rarity.REGULAR];
        }
        newTokenId = auctionToken.getNextTokenId();
        auctionToken.mintToAndSetTokenURI(to, tokenUri);
    }

}
