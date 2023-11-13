import { FormValidator } from './FormValidator.js';
import { SendSigned } from '../classes/SendSigned.js';

const LEGAL_FORM_SELECTOR = 'legal-form';
const SIGN_BUTTON_SELECTOR = 'button[hxh-type="sign"]';

document.addEventListener("DOMContentLoaded", function() {
    console.log("Document fully loaded and parsed");
    const legalForm = document.querySelector(LEGAL_FORM_SELECTOR);

    if (legalForm) {
        console.log("Legal form detected");
        legalForm.addEventListener('click', handleSignButtonClick, { capture: true });
    } else {
        console.warn("No legal form detected");
    }
});

function handleSignButtonClick(event) {
    if (event.target.matches(SIGN_BUTTON_SELECTOR)) {
        console.log("Sign button clicked"); // Debug log
        handleSubmit(event);
    } else {
        console.log("Clicked element is not the sign button"); // Debug log
    }
}

async function handleSubmit(event) {
    event.preventDefault();

    const legalForm = event.target.closest(LEGAL_FORM_SELECTOR);

    if (FormValidator.isFormValid(legalForm)) {  
        const fullRoute = legalForm.getAttribute('hxh-action');
        console.log(`Full action route: ${fullRoute}`); // Debug log
        
        let routeParts = fullRoute.split('/');
        let action = routeParts[routeParts.length - 1];
        console.log(`Determined action: ${action}`); // Debug log

        const inputElements = legalForm.querySelectorAll('input');
        const inputData = Array.from(inputElements).map(input => ({
            name: input.name,
            value: input.value
        }));
        
        console.log('Collected input data:', inputData); // Debug log

        try {
            console.log('Attempting to send data'); // Debug log
            await SendSigned.send(action, inputData);
            console.log('Data sent successfully'); // Debug log
        } catch (error) {
            console.error("Error sending transaction:", error);
        }
    } else {
        console.warn('Some inputs are invalid.');
    }
}
