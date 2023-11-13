import { contract, provider, wallet } from '../ethers.config.js';

class SendSigned {
    
    static async send(action, inputData) {
        console.log('Starting SendSigned.send with action:', action);
        console.log('Input data:', inputData);
        
        const inputValues = inputData.map(data => data.value);
        const data = contract.interface.encodeFunctionData(action, inputValues);
        console.log('Encoded function data:', data);

        try {
            const estimatedGas = await contract.estimateGas[action](...inputValues);
            console.log('Estimated gas:', estimatedGas.toString());

            const gasPrice = await provider.getGasPrice();
            console.log('Current gas price:', gasPrice.toString());

            const nonce = await provider.getTransactionCount(wallet.address, 'pending');
            console.log('Current nonce:', nonce);

            const tx = {
                to: contract.address,
                nonce: nonce,
                gasLimit: estimatedGas,
                gasPrice: gasPrice,
                data: data
            };

            console.log('Prepared transaction details:', tx);
            
            const txResponse = await wallet.sendTransaction(tx);
            console.log('Transaction sent, tx hash:', txResponse.hash);

            const receipt = await txResponse.wait();
            console.log('Transaction was mined in block:', receipt.blockNumber);
        } catch (error) {
            console.error("Error sending transaction:", error);
            if (error.data) {
                console.error("Error details:", error.data);
            }
        }
    }
}

export {
    SendSigned
};
