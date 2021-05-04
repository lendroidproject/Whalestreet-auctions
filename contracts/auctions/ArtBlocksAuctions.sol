// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;

import "./DutchAuctions.sol";


contract ArtBlocksAuctions is DutchAuctions {

    // solhint-disable-next-line func-visibility
    constructor(address auctionCurveAddress, address purchaseTokenAddress, address keyMinterAddress,
        address vrfCoordinator, address linkToken, bytes32 vrfKeyHash, uint256 vrfFee)
        DutchAuctions(auctionCurveAddress, purchaseTokenAddress,// solhint-disable-line func-visibility
            keyMinterAddress,
            vrfCoordinator, linkToken, vrfKeyHash, vrfFee) {}// solhint-disable-line no-empty-blocks

}
