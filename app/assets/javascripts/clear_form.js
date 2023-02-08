const form = document.forms[0];

function clearTextInputs(inputElements) {
    inputElements.forEach(elem => {
        form[elem].value = '';
    });
}

function clearSelectBox(inputElements){
    inputElements.forEach(elem => {
        form[elem].value = '';
    });
}

function clearCheckBox(inputElements){
    inputElements.forEach(elem => {
        form[elem].forEach(box => { box.checked = false; });
    });
}
