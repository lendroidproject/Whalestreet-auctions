// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;

import "../../auctions/ArtBlocksAuctions.sol";


contract MainnetArtBlocksAuctions is ArtBlocksAuctions {

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
            0xf0d54349aDdcf704F77AE15b96510dEA15cb7952,// VRF Coordinator
            0x514910771AF9Ca656af840dff83E8264EcF986CA,// LINK Token
            0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445,// keyHash
            2 * 10 ** 18// 2 LINK
            ) {}// solhint-disable-line no-empty-blocks

}
