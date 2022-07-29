// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "@rails/ujs"
import * as popper from '@popperjs/core';
import * as bootstrap from "bootstrap"

// helper function for .fhir class to pretty print fhir json
function syntaxHighlight(json) {
    if (typeof json != 'string') {
         json = JSON.stringify(json, undefined, 2);
    }
    json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
        var cls = 'number';
        if (/^"/.test(match)) {
            if (/:$/.test(match)) {
                cls = 'key';
            } else {
                cls = 'string';
            }
        } else if (/true|false/.test(match)) {
            cls = 'boolean';
        } else if (/null/.test(match)) {
            cls = 'null';
        }
        return '<span class="' + cls + '">' + match + '</span>';
    });
}

// helper function for .fhir class to pretty print fhir json
function prettifyJson(element) {
	const uglyJson = element.innerHTML;
	const prettyJson = syntaxHighlight(JSON.stringify(JSON.parse(uglyJson),null,2));
	element.innerHTML = prettyJson;
	return true;
}

// THE function for .fhir class to pretty print fhir json
function formatFhir() {
  const elements = document.querySelectorAll('.fhir');
  console.log('Prettifying fhir for', elements.length, 'elements.')
  Array.from(elements).forEach((element) => {prettifyJson(element)});
}

// set callback triggers to format fhir json on webpage load
document.addEventListener("load", formatFhir);
document.addEventListener("turbo:load", formatFhir);
document.addEventListener("ready turbo:load", formatFhir);

// helper function to add hidden input element to form before submit
function addHiddenField(form, name, value) {
	console.log("Adding hidden field", name, "=", value);
	let parent = document.querySelector(form);
	let element = document.createElement('input');

	element.setAttribute('type', 'hidden');
	element.setAttribute('name', name);
	element.setAttribute('value', value);

	parent.appendChild(element);
	return true;
}

function enableTooltips() {
	const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
	const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
	console.log("Enabling tooltips");
}

// set callback to enable tooltips
document.addEventListener("load", enableTooltips);
document.addEventListener("turbo:load", enableTooltips);
document.addEventListener("ready turbo:load", enableTooltips);

