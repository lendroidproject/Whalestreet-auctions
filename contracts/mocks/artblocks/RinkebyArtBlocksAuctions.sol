// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;

import "../../auctions/ArtBlocksAuctions.sol";


contract RinkebyArtBlocksAuctions is ArtBlocksAuctions {

    /**
     * Constructor inherits ArtBlocksAuctions
     *
     * Network: Kovan
     * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     *
     */
    // solhint-disable-next-line func-visibility
    constructor(address auctionCurveAddress, address purchaseTokenAddress, address keyMinterAddress)
        ArtBlocksAuctions(auctionCurveAddress, purchaseTokenAddress,// solhint-disable-line func-visibility
            keyMinterAddress,
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B,// VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709,// LINK Token
            0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311,// keyHash
            0.1 * 10 ** 18// 0.1 LINK
            ) {}// solhint-disable-line no-empty-blocks

}
