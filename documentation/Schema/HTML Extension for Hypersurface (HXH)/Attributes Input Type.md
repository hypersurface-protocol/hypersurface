Associate input types directly with ABI?

1. **Basic Data Types**:
   - `hxh-type="uint8"`: 8-bit unsigned integer.
   - `hxh-type="uint16"`: 16-bit unsigned integer.
   - `hxh-type="uint32"`: 32-bit unsigned integer.
   - `hxh-type="uint64"`: 64-bit unsigned integer.
   - `hxh-type="uint128"`: 128-bit unsigned integer.
   - `hxh-type="uint256"`: 256-bit unsigned integer.
   - `hxh-type="int8"`: 8-bit signed integer.
   - `hxh-type="int16"`: 16-bit signed integer.
   - `hxh-type="int32"`: 32-bit signed integer.
   - `hxh-type="int64"`: 64-bit signed integer.
   - `hxh-type="int128"`: 128-bit signed integer.
   - `hxh-type="int256"`: 256-bit signed integer.
   - `hxh-type="bool"`: Boolean (true or false).
   - `hxh-type="address"`: Ethereum address (20-byte Ethereum address).

2. **Fixed-Point Types**:
   - `hxh-type="fixed8x1"`: Fixed-point number with 8 bits for the integer part and 1 bit for the fractional part.
   - `hxh-type="fixed16x8"`: Fixed-point number with 16 bits for the integer part and 8 bits for the fractional part.
   - `hxh-type="fixed32x16"`: Fixed-point number with 32 bits for the integer part and 16 bits for the fractional part.
   - `hxh-type="fixed64x32"`: Fixed-point number with 64 bits for the integer part and 32 bits for the fractional part.
   - `hxh-type="fixed128x64"`: Fixed-point number with 128 bits for the integer part and 64 bits for the fractional part.
   - `hxh-type="fixed256x128"`: Fixed-point number with 256 bits for the integer part and 128 bits for the fractional part.
   - `hxh-type="ufixed8x1"`: Unsigned fixed-point number with 8 bits for the integer part and 1 bit for the fractional part.
   - `hxh-type="ufixed16x8"`: Unsigned fixed-point number with 16 bits for the integer part and 8 bits for the fractional part.
   - `hxh-type="ufixed32x16"`: Unsigned fixed-point number with 32 bits for the integer part and 16 bits for the fractional part.
   - `hxh-type="ufixed64x32"`: Unsigned fixed-point number with 64 bits for the integer part and 32 bits for the fractional part.
   - `hxh-type="ufixed128x64"`: Unsigned fixed-point number with 128 bits for the integer part and 64 bits for the fractional part.
   - `hxh-type="ufixed256x128"`: Unsigned fixed-point number with 256 bits for the integer part and 128 bits for the fractional part.

3. **Bytes and Strings**:
   - `hxh-type="bytes1"`: Byte array of length 1.
   - `hxh-type="bytes2"`: Byte array of length 2.
   - `hxh-type="bytes4"`: Byte array of length 4.
   - `hxh-type="bytes8"`: Byte array of length 8.
   - `hxh-type="bytes16"`: Byte array of length 16.
   - `hxh-type="bytes32"`: Byte array of length 32.
   - `hxh-type="string"`: UTF-8 encoded string (dynamic-sized).

4. **Arrays**:
   - `hxh-type="array-uint8"`: Dynamic-sized array of 8-bit unsigned integers.
   - `hxh-type="array-uint16"`: Dynamic-sized array of 16-bit unsigned integers.
   - `hxh-type="array-uint32"`: Dynamic-sized array of 32-bit unsigned integers.
   - `hxh-type="array-uint64"`: Dynamic-sized array of 64-bit unsigned integers.
   - `hxh-type="array-uint128"`: Dynamic-sized array of 128-bit unsigned integers.
   - `hxh-type="array-uint256"`: Dynamic-sized array of 256-bit unsigned integers.
   - `hxh-type="array-int8"`: Dynamic-sized array of 8-bit signed integers.
   - `hxh-type="array-int16"`: Dynamic-sized array of 16-bit signed integers.
   - `hxh-type="array-int32"`: Dynamic-sized array of 32-bit signed integers.
   - `hxh-type="array-int64"`: Dynamic-sized array of 64-bit signed integers.
   - `hxh-type="array-int128"`: Dynamic-sized array of 128-bit signed integers.
   - `hxh-type="array-int256"`: Dynamic-sized array of 256-bit signed integers.
   - `hxh-type="array-bool"`: Dynamic-sized array of booleans.
   - `hxh-type="array-address"`: Dynamic-sized array of Ethereum addresses.
   - `hxh-type="array-fixed8x1"`: Dynamic-sized array of fixed-point numbers with 8 bits for the integer part and 1 bit for the fractional part.
   - `hxh-type="array-ufixed8x1"`: Dynamic-sized array of unsigned fixed-point numbers with 8 bits for the integer part and 1 bit for the fractional part.
   - `hxh-type="array-bytes1"`: Dynamic-sized array of byte arrays of length 1.
   - `hxh-type="array-bytes32"`: Dynamic-sized array of byte arrays of length 32.
   - `hxh-type="array-string"`: Dynamic-sized array of strings.

5. **Enums**:
   - `hxh-type="enum"`: User-defined enumerations.

6. **Structs**:
   - `hxh-type="struct"`: User-defined data structures (e.g., `hxh-type="struct-MyStruct"`).

7. **Contracts**:
   - `hxh-type="contract"`: Type of other smart contracts (used for function arguments that accept contract addresses).
   - `hxh-type="contract-MyContract"`: Specific smart contract type (replace "MyContract" with the contract name).

8. **Function Types**:
   - `hxh-type="function"`: A function type, used in contract interfaces for specifying function signatures.