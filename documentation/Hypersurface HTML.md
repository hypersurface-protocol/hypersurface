Hypersurface has created a number of low level extensions for HTML: 

The HyperLegal Markup Language ("HLML") is an extension of standard HTML tags used to structure legal contracts, providing greater context and specificity. 

The HTML Extension for Hypersurface ("HXH") is a suite of custom HTML attributes and methods which may be applied to custom HLML elements or traditional HTML elements, allowing users to interact with the Hypersurface protocol from basic web pages. 

The purpose of these extensions is to enable sophisticated blockchain functionality to be made accessible in a form factor that is extremely simple. We believe this will greatly enhance security and democratise access by transforming the primary interaction patterns of web3. 

Hypersurface represents a simple layer of abstraction on top of basic HTML. Compare the following pieces of code:

```
// HTML
<form action="route/to/submit/data" method="POST">
	<input type="email" placeholder="janesmith@acme.com">
	<input type="password" placeholder="*****">
	<button type="submit">Submit</button>
</form>

// Hypersurface
<legal-form hxh-action="contract/library/function" hxh-method="POST">
	<input hxh-type="address" placeholder="0x012...">
	<input hxh-type="uint256" placeholder="100">
	<button hxh-type"sign">Sign</button>
</legal-form>
```

# Document Structure 

Hypersurface features a number of basic custom HTML tags used to mark up legal agreements. 

1. `<legal-head>` (*extends `head`*): Wraps document metadata.
2. `<legal-body>` (*extends `body`*): Wraps the legal document.
3. `<legal-section>` (*extends `section`*): A major division within the document.
4. `<legal-clause>` (*extends `article`*): Represents individual clauses within the agreement.
5. `<legal-subclause>` (*extends `p`*): Represents sub-clauses or points under a primary clause.
6. `<legal-footer>` (*extends `footer`*): Footnotes, dates, or other peripheral information.

# References and Actions

Documents may link to on-chain objects like Hyperlinks. 

These typically follow the pattern of `registry.contract/proxy/selector`. A typical route may look something `hyp.acme/details/name` or simply `acme/details/name`. 

1. The `registry` is the top level Hypersurface domain registry ("`hyp.`"), used to lookup accounts.

2. The `contract` indicates the specific smart contract account (e.g., `acme`, `lorem-capital`, `jane-smith`, etc) being called. 

3. The `proxy` indicates a specific proxy logic contract associated with an account (e.g., `details`, `governance`, `shares`, etc). These are typically libraries created and deployed by Hypersurface or ecosystem actors to provide users with specific operation functionality.

4. The `selector` indicates a specific name spaced function selector (e.g., `name`, `balance`, `proposal`, etc). 

Hypertokens can also encode arguments, `acme/shares/balance?account=[account]`. In this example, an account is passed in as an argument to a balance lookup. It is important to mention that traditionally, this would have been a specific account or smart contract indicated by their address (e.g., `0x01AB...`). in the Hypersurface protocol an account is identified by their domain name (e.g., `hyp.jane-smith`). The preceding top-level domain ("`hyp.`") indicates that the domain requires lookup in the top level registry. 

Steps in the resolution routeway can function as pointers to one or more additional items, like folders, meaning these routes can continue to an arbitrary depth. For example, `acme/shares/series-a-common/balance?account=[account]` or even `acme/shares/series-a/common/balance?account=[account]` depending on how users preferer to structure their projects.

The previous examples primarily reference URLs and `GET`-style interactions. The same resolution method can also be used for `POST`-style actions. For example, a `form` element can include a resolution route as it's `hxh-action`. For example, `acme/shares/transfer`. In this instance, the function selector at the end of the resolution route ("`transfer`") is treated as a route, and use to handle user input data for a state changing action.

# Contracts

### Legal Documents

Plain text legal contracts, which do not include any interactive or sign-able elements are indicated with the `<legal-document>`  tags. 

```
<legal-document>
	// Contract content...
</legal-document>
```
### Legal Agreement

Legal agreements are legal contracts without user interactive inputs that users must explicitly sign to agree to the contracts terms (e.g., NDA, etc). They are indicated with the `<legal-agreement>` tags. Although the legal agreement features no interactive inputs, the agreement itself is treated as the submission, which is triggered by the button. This signs the hash of the legal agreement content to confirm to the precise terms of the agreement rendered.

```
<legal-agreement hxh-action="contract/proxy/transfer" hxh-method="POST">
	// Contract content...
	<button hxh-type="sign">Sign</button>				// Signs the agreement
</legal-agreement>
```
### Legal Form

Legal forms are the final type of legal contract. They handle legal agreements with user input data and are indicated with the `<legal-form>` tag.  

```
<legal-form hxh-action="contract/proxy/transfer" hxh-method="POST">
	<p>Recipient Account:</p>							// Label
	<input hxh-type="address" placeholder="0x01...">	// Address input
	<p>Amount of tokens to send:</p>					// Label
	<input hxh-type="uint256" placeholder="100">		// Amount input
	<button hxh-type"sign">Sign</button>				// Sign and submit
</legal-form>
```

# Inputs

Hypersurface creates custom input types for handling form submissions. These are rendered as standard HTML `<input>` tags, but feature custom `hxh-type` attributes. These attributes correspond with their underlying Solidity input (e.g., `uint8`, `address`, `bytes32`, etc).

These tags feature custom form validation to ensure that the appropriate types are input by the user. For example, a `uint8` (unsigned 8-bit integer) can have values ranging from 0 to 255. To ensure user input is a `uint8`, the input verifies that we're matching numbers within this range.

Upon signing, the agreement is processed in such a way that (1) the input data is extracted and handled appropriately, and (2) the input fields are swapped for the plain text data input by the user, which is inserted in place into the contract. The `<legal-form>` contract is then rendered in plain text and hashed. The hash is then signed and submitted, in the same way as a `<legal-agreement>`.

Inputs fields may be rendered immutable using standard HTML `readonly` tag. This enables contract senders to hardcode particular input values. For example, a user may choose to prefill an address for receiving funds upon form submission. By using a `readonly` input they create an element which is not mutable to the user, whilst presenting data in a way that can be handled appropriately on form submission.

In order to introduce maximum security, Hypersurface input fields demand field names to correspond with the intended input field. This creates a clear mapping from user input data to the function argument, ensuring any functions with multiple inputs of the same type (e.g., sender address, recipient address) are handled safely. For example, the HTML inputs on a form with the route `contract/shares/transfer` would appear as:

```
<input hxh-name="to" hxh-type="address" placeholder="0x01...">
<input hxh-name="value" hxh-type="uint256" placeholder="100">
```

Would correspond with the smart contracts "transfer" function: 

```
transfer(address to, uint256 value) 
```

# Submission Routes

The route for form submission is captured in a forms `hxh-action` attribute. This will typically record a specific route for the handling of form data. For example, `hxh-action="contract/proxy/transfer"` will submit inputs to the transfer selector, thereby executing a transfer to the `address` of the `amount`. 

# Identification Tags

The Hypersurface protocol uses custom identification tags to render and reference contract  content, `hxh-id` tags bind HTML elements to their underlying objects on-chain. 

`hxh-data` a versatile tag for fetching and displaying blockchain data from tokens or their associated contracts. The specific data fetched is determined by the reference provided.

How is embedded 

# General Submission

Smart contract accounts in the Hypersurface ecosystem employee token received hooks to log received tokens. 



Instead of returning tokenised documents directly to the sender account, senders can introduce token hooks to handle specific receipt functionality. In essence, not only can hooks expose contract type specific inboxes to users for submission, transfering received tokens, but can also be introduce specific logic to handle contract submissions. 

Submission hooks can be viewed as basic proxy logic contracts. 

For example, a company may issue an NDA to an investor before granting them access to review investment materials. 

For example, if a 

These hooks are recorded in the `hxh-action` as a route. These can be understood as routes in traditional server paradigms. 

Hooks may enable processing of received 

Users may add specific functionality to handle form submission. 
These hooks can read received tokens to verify the data







## General Submission

For general return submissions, the action of the form may simply be encoded as the return contract account. For example, `hxh-action="hyp.acme"`. This will make use of the central token receipt hook. The signed contract will appear in the users inbox and may be manually processed. 
## Submission Hooks
















Write a routing engine in Javascript in the frontend
This should be the engine of transaction routing 


In order to replicate but also verify user input data, do a comparison based on adding the abstracted input data (via meta) against the original agreement