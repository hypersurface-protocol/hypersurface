// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IHyperserver.sol";

library Verify {

    function verify(IHyperserver.Transfer memory transfer) public returns (address) {

        transfer.sig;

        // TODO verify the signature of the transfer

        
    }

}