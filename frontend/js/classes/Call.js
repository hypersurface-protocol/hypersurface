import { contract } from '../ethers.config.js';

class Call {
    
    static async call(action, ...args) {
        try {
            const response = await contract[action](...args);
            return response;
        } catch (error) {
            console.error(`Error calling contract method ${action}:`, error);
            throw error;  // Propagate the error to be handled by the calling function
        }
    }
}

export { Call };
