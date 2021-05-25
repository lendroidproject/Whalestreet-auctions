// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import {LibDiamond} from "../../shared/libraries/LibDiamond.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {Pacemaker} from "../../heartbeat/Pacemaker.sol";
import {ILink} from "../interfaces/ILink.sol";


// solhint-disable
struct DefiKey {
    uint256 epoch;
    uint256 amount;
    uint256 timestamp;
    address keyAddress;
    uint256 keyId;
    uint256 feePercentage;
    address account;
    bytes32 vrfRequestId;
    uint256 randomness;
}

struct AppStorage {
    DefiKey[] defiKeys;
    IERC20 purchaseToken;
    // Addresses
    address childChainManager;
    address dao;
    address daoTreasury;
    string itemsBaseUri;
    bytes32 domainSeparator;
    //VRF
    mapping(bytes32 => uint256) vrfRequestIdToKeyId;
    mapping(bytes32 => uint256) vrfNonces;
    bytes32 keyHash;
    uint144 fee;
    address vrfCoordinator;
    ILink link;
}
// solhint-enable


library LibAppStorage {// solhint-disable-line two-lines-top-level-separator
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {// solhint-disable-line no-inline-assembly
            ds.slot := 0
        }
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}


contract Modifiers is Pacemaker {
    AppStorage internal s;

    modifier onlyOwner {
        LibDiamond.enforceIsContractOwner();
        _;
    }

    modifier onlyDao {
        address sender = LibMeta.msgSender();
        require(sender == s.dao, "Only DAO can call this function");
        _;
    }

    modifier onlyDaoOrOwner {
        address sender = LibMeta.msgSender();
        require(sender == s.dao || sender == LibDiamond.contractOwner(), "LibAppStorage: Do not have access");
        _;
    }

}
