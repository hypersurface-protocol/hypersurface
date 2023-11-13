class FormValidator {
    static get validators() {
        return {
            'bytes': FormValidator.validateBytes,
            'string': FormValidator.validateString,
            'uint': FormValidator.validateUnsignedInt,
            'int': FormValidator.validateSignedInt,
            'bool': FormValidator.validateBoolean,
            'address': FormValidator.validateEthereumAddress
        };
    }

    static validateInput(input) {
        const type = input.getAttribute('hxh-type');
        console.log(`Processing input with hxh-type: ${type}`);
        
        const [prefix, bitSize] = type.split('-');

        if (FormValidator.validators[prefix]) {
            return FormValidator.validators[prefix](input, bitSize);
        } else {
            console.error(`Unknown hxh-type: ${type}`);
            return false;
        }
    }
	
	static isFormValid(legalForm) {
        console.log("Validating form inputs");
        let allValid = true;
        const inputs = legalForm.querySelectorAll('input');
        inputs.forEach(input => {
            if (!this.validateInput(input)) {
                allValid = false;
                console.error(`Input validation failed for: ${input.name}`);
            } else {
                console.log(`Input validation successful for: ${input.name}`);
            }
        });
        return allValid;
    }

	static validateUnsignedInt(input, bitSize) {
		const maxValue = BigInt(2) ** BigInt(bitSize) - BigInt(1);
		const inputValue = BigInt(input.value);

		if (inputValue < 0n || inputValue > maxValue) {
			input.setCustomValidity(`Enter an unsigned integer between 0 and ${maxValue}`);
			return false;
		} else {
			input.setCustomValidity('');
			return true;
		}
	}

	static validateSignedInt(input, bitSize) {
		const maxValue = BigInt(2) ** (BigInt(bitSize) - 1n) - 1n;
		const minValue = -(BigInt(2) ** (BigInt(bitSize) - 1n));
		const inputValue = BigInt(input.value);

		if (inputValue < minValue || inputValue > maxValue) {
			input.setCustomValidity(`Enter a signed integer between ${minValue} and ${maxValue}`);
			return false;
		} else {
			input.setCustomValidity('');
			return true;
		}
	}

	static validateEthereumAddress(input) {
		const pattern = /^0x[a-fA-F0-9]{40}$/;

		if (!pattern.test(input.value)) {
			input.setCustomValidity('Enter a valid Ethereum address');
			return false;
		} else {
			input.setCustomValidity('');
			return true;
		}
	}

	static validateBytes(input, size) {
		const expectedLength = parseInt(size) * 2; 
		const pattern = new RegExp(`^[a-fA-F0-9]{${expectedLength}}$`);

		if (!pattern.test(input.value)) {
			input.setCustomValidity(`Enter a byte array of length ${size} (i.e., ${expectedLength} hexadecimal characters)`);
			return false;
		} else {
			input.setCustomValidity('');
			return true;
		}
	}

	static validateString(input) {
		try {
			decodeURIComponent(escape(input.value));
			input.setCustomValidity('');
			return true;
		} catch (e) {
			input.setCustomValidity('Enter a valid UTF-8 encoded string');
			return false;
		}
	}

    validateBoolean(input) {
        // Since we're keeping the function, even if trivial, you can do more elaborate checks if needed
        // For now, it just returns true for simplicity
        return true;
    }
}

export {
	FormValidator
};