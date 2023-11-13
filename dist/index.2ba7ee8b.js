const elements = [
    "legal-document",
    "legal-form",
    "legal-section",
    "legal-clause",
    "legal-subclause",
    "legal-header",
    "legal-footer"
];
elements.forEach((element)=>{
    class CustomElement extends HTMLElement {
        constructor(){
            super();
        }
    }
    customElements.define(element, CustomElement);
});

//# sourceMappingURL=index.2ba7ee8b.js.map
