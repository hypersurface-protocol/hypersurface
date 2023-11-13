1. **Document**:
   - `<legal-document>`: Represents the entire agreement and may include meta attributes like validity, status, and integrity verification.

2. **Sections & Clauses**:
   - `<legal-section>`: Major divisions in the document, such as titles or chapters.
   - `<legal-clause>`: Represents actionable clauses within the agreement. Actions can be directly invoked from the clause.

3. **Data Rendering**:
   

4. **Parties**:
   - `<party-block>`: Represents the involved parties, with reference to their respective contracts or tokens.

5. **Signatures**:
   - `<signature-block>`: Used for the digital representation and cryptographic validation of signatures.

6. **Notifications**:
   - `<notification-block>`: Specifies the notification method and details.

7. **Tokens & Proxy Logic**:
   - `<token-block>`: References to tokens or proxy logic contracts related to the agreement. If the proxy contract has its own interface, it can be dynamically rendered when this block is accessed.