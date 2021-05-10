// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;

import "../../auctions/VRFAuctions.sol";


contract RinkebyArtBlocksAuctions is VRFAuctions {

    /**
     * Constructor inherits VRFAuctions
     *
     * Network: Rinkeby
     * Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK token address:                0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     *
     */
    // solhint-disable-next-line func-visibility
    constructor(address auctionCurveAddress, address purchaseTokenAddress, address keyMinterAddress)
        VRFAuctions(auctionCurveAddress, purchaseTokenAddress,// solhint-disable-line func-visibility
            keyMinterAddress,
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B,// VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709,// LINK Token
            0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311,// keyHash
            0.1 * 10 ** 18// 0.1 LINK
            ) {}// solhint-disable-line no-empty-blocks

}
