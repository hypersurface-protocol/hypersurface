GET, if not specified assume index


    // Handle "/" as index  
    bytes32 funcSlot;
    if (transfer.step == transfer[0].route.length) {
        funcSlot = keccak256("index"); // TODO Temp
    }
    else {
        funcSlot = transfer.route[transfer.step];
    }

    // Set vars
    bytes memory documentData;
    bytes memory funcData;



    // Check if is GET type, if it is then make the call 
    if (isGet(selectorEntry.typeHash)) {

        // Get the function selector from the current step's data.
        bytes4 selector = bytes4(selectorEntry.dataHash);

        // Require the route is the final step
        require(transfer.step == transfer.route.length, "Non final step");
        
        // Perform a delegate call to the library function.
        (bool success, bytes memory data) = libraryAddress.delegatecall(abi.encodeWithSelector(selector));

        require(success, "Require the call has been succesful");

        returnData = abi.encode(documentData, data);
    }
    // Check if is POST type, if it is then 
    else if (isPost(selectorEntry.typeHash)) {
        returnData = documentData;
        // Just return the page/interface if get calling a method
    } else { 
        // If none of the above types match, revert.
        revert InvalidEntryType();
    }