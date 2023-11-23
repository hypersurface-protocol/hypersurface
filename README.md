# Hypersurface

This is the monorepo for the Hypersurface protocol.

## Protocol

The Hypersurface core protocol centers around a new form of upgradeable proxy smart contract called "Hyperserver". At the protocol level, Hyperserver revolves around three key components:

- An append-only ledger
- One or more signing keypairs
- An ERC1155-like multi-token

### Ledger and Signed Entries

At the core of Hyperserver is an append-only ledger where data may be entered. The ledger serves as the backbone of data entry and retrieval for the server. Data is signed into the ledger by one or more signing keypairs held by the Hyperserver. These keypairs can be used for different wallets, operators, divisions, funds, etc.

Due to the privacy provided by Oasis Sapphire, blockchain explorers no longer stand as the definitive record of actions. By signing ledger entries, Hyperserver ensures that the data has not been tampered with. Each entry includes a cryptographic signature that can be used to verify its authenticity. This is crucial for data integrity, especially in the distributed systems Hyperserver can be used to construct, where data might pass through multiple servers.

### Tokens

Specific ledger entries can then be shared with other accounts via tokenization. The token component of the contract essentially functions like an ERC1155, whereby the token metadata/data is recorded on-chain as a ledger entry, instead of off-chain as JSON.

When a token is sent to a server, it is received using a token receiver hook similar to an ERC1155 receiver. Where Hyperserver differs from traditional ERC1155 receivers is that the sender may specify the intended recipient by providing the ledger entry associated with it. For simple transfers, the entry ID is used to specify the recipient keypair (e.g., keccak256(alice) => 0x01Ab..). The receiver hook then logs the receipt and returns the appropriate address, which is then used to update the token balance.

Tokenized entries can be withheld from everyone but token holders, creating a simple means for access management. To access the entry data, a request is signed by the receiving keypair, the server then computes the address based on the signature and looks up the balance of the signer to ensure they have been issued access. 

### Proxy Logic Functionality

Entry data can be used to add proxy logic functionality to the core Hyperserver, in a similar way to the ERC-2535 Multi-Facet Diamond Proxy. Instead of extracting the function selector, which the core contract associates with a library for delegate call, users specify the relevant entries for their intended action. 

*In essence, all function calls can be viewed as different token receiver hooks. Unlike traditional account models, Hyperserver does not pass data directly into function calls. Instead of submitting data directly, Hyperserver transfers a token to the appropriate receiver providing entry IDs to specify the functionality that should be used to handle the data. 

Because tokens are used as the fundamental unit of interaction, the majority of actions can actually be reduced to very simple procedures made up of token transfers or issuances, signature verification, balance lookups (either internal or external), and return issuances or transfers.  

For actions that cannot be performed using tokens, the recipient simply signs a request for the token entry data received by the hook, retrieves, verifies, and interprets the data to then use for the specified action. This also gives the issuer the opportunity to reduce the caller's balance if the token is consumable (for example, an action authorization). 

### Why not just pass data in directly?

1. The use of signed entries in an append-only ledger gives all participants a cryptographically secure and provable audit trail for all interactions. This is particularly important in scenarios where the history of transactions or changes needs to be transparent and unchangeable.

2. Tokens function as the single standardized unit of interaction, eliminating complex custom interactions and making sophisticated functionality accessible to non-technical users.

3. And, most importantly, namespaced ledger entries (essentially pointers) can be used to create semantic URLs (e.g., `acme/shares/transfer`). Where this becomes particularly useful is in combination with Hypersurface's unique document model, as ledger entries can be used for GET and POST actions in the frontend.

## Frontend

Hypersurface enables the creation of smart legal agreements using basic HTML. This is made possible through two custom HTML extensions, HyperLegal Markup Language ("HLML") and Hypersurface Extension for HTML ("HXH"), that represent a simple layer of abstraction on top of basic HTML. Preliminary implementations of these can be found in the "frontend" directory.

HyperLegal Markup Language ("HLML") is an extension of standard HTML tags used to structure legal contracts, providing greater context and specificity. This enables external machine systems to parse and index legal agreements like webpages, without the need for cumbersome techniques such as natural language processing.

The Hypersurface Extension for HTML ("HXH") is a suite of custom HTML attributes and methods which may be applied to HTML or HLML elements, allowing users to interact with the blockchain from basic web pages. Instead of using less secure standard HTML inputs such as `type="text"` or `type="number"`, documents can take advantage of custom HXH Solidity type-safe attributes, such as `hxh-type="bytes-32"` or `hxh-type="uint-256"`.

The purpose of these extensions is to enable sophisticated blockchain functionality to be made accessible in a form factor that is extremely simple. We believe this will greatly enhance transparency, security, and democratize access by transforming the primary interaction pattern of web3. Due to the trustless way in which ledger entries are served, and the use of basic HTML for smart legal documents, user uncertainty surrounding the intended purpose of these pages can be minimized. This means that the web3 promise of "don't trust, verify" can be fulfilled in the frontend UX for the first time. 

### What does this look like in application?

- Users add ledger entries that encapsulate both backend logic and frontend HTML. 
- These are then tokenized and issued to the intended recipient.
- The recipient then loads the legal webpage in the browser using a signed GET call. 
- The document specifies its intended action as a particular route, e.g., `hxh-action="route/for/submission" hxh-method="POST"`. 
- The recipient can review the document and input data as required via simple form input. 
- Upon submission, signed entries for the document and the submission data are added to the recipient's ledger. 
- Both are returned to the issuer via the route specified in the form's action attribute.
- The backend logic then handles the receipt to verify that, (1) the signer has signed the agreement, (2) has been issued it in the first place (via a balance check), and (3) handles any return data.

# Why is this so important?

Hypersurface exists at the intersection of the traditional legal system, fundamental web technologies, and cutting-edge smart contract functionality. This unique combination of features means that not only can the blockchain be used in ways that users are familiar with for the first time ever (i.e., like the web), but it also forms the basis for a fundamentally new web architecture.

Hypersurface bridges the gap between the traditional legal system and advanced web technology, streamlining the way legal agreements are managed and executed online. It moves away from static document formats like PDF and paper, which often require cumbersome methods for data entry and signature.

Unlike the conventional web interaction where users send data to a server without maintaining a record of the data in its full context, Hypersurface allows for capturing data explicitly in its intended context, ensuring that users have a complete record of their data submissions.

Users interact with their own server, which securely records the data in its entirety. This server then securely communicates the data to the relevant external servers, incorporating hashing and signing of webpages for added security.

Hypersurface introduces the concept of balances and transferability into web documents. This means that web pages can now be used to record not just legal agreements but also assets and permissions. Each interaction or transaction on these pages can be recorded with precise balances, and the ownership or rights can be transferred as per the specified legal and operational frameworks.

For more information, please see the [Hypersurface Whitepaper](https://github.com/hypersurface-protocol/whitepaper).
