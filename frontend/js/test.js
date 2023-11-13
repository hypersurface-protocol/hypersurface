import { Call } from './classes/Call.js';
import { SendSigned } from './classes/SendSigned.js';

// Function to set details using the SendSigned
async function setDetails(name, email, age) {
    try {
        const action = 'updateDetails';
        const inputData = [
            { name: 'name', value: name },
            { name: 'email', value: email },
            { name: 'age', value: age }
        ];
        await SendSigned.send(action, inputData);
        console.log('Details have been set successfully.');
    } catch (error) {
        console.error('Error while setting details:', error);
    }
}

async function fetchDetails() {
    try {
        const details = await Call.call('fetchDetails');
        console.log('Details have been fetched successfully.');
        return details;
    } catch (error) {
        console.error('Error while fetching details:', error);
    }
}

// Example usage
(async () => {
    await setDetails("Jimmy", "jimmy@email.com", 99);

    const details = await fetchDetails();
    if (details) {
        const { name, email, age } = details;
        console.log(`Fetched details:\nName: ${name}\nEmail: ${email}\nAge: ${age}`);
    }
})();
