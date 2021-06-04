// SPDX-License-Identifier: https://github.com/lendroidproject/protocol.2.0/blob/master/LICENSE.md
pragma solidity 0.7.5;

import "../../auctions/VRFAuctions.sol";


contract MainnetArtBlocksAuctions is VRFAuctions {

    /**
     * Constructor inherits VRFAuctions
     *
     * Network: Ethereum Mainnet
     * Chainlink VRF Coordinator address: 0xf0d54349aDdcf704F77AE15b96510dEA15cb7952
     * LINK token address:                0x514910771AF9Ca656af840dff83E8264EcF986CA
     * Key Hash: 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445
     *
     */
    // solhint-disable-next-line func-visibility
    constructor(address daoTreasuryAddress,
            address auctionCurveAddress, address purchaseTokenAddress, address keyMinterAddress)
        VRFAuctions(daoTreasuryAddress,// solhint-disable-line func-visibility
            auctionCurveAddress, purchaseTokenAddress, keyMinterAddress,
            0xf0d54349aDdcf704F77AE15b96510dEA15cb7952,// VRF Coordinator
            0x514910771AF9Ca656af840dff83E8264EcF986CA,// LINK Token
            0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445,// keyHash
            2 * 10 ** 18// 2 LINK
            ) {}// solhint-disable-line no-empty-blocks

}
