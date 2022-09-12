// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "@rails/ujs"
import * as popper from '@popperjs/core';
import * as bootstrap from "bootstrap"

// helper function for .json class to pretty print fhir json
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

// helper function for .json class to pretty print fhir json
function prettifyJson(element) {
	const uglyJson = element.innerHTML;
	const prettyJson = syntaxHighlight(JSON.stringify(JSON.parse(uglyJson),null,2));
	element.innerHTML = prettyJson;
	return true;
}

// THE function for .json class to pretty print fhir json
function formatJson() {
  const elements = document.querySelectorAll('.json');
  console.log('Prettifying json for', elements.length, 'elements.')
  Array.from(elements).forEach((element) => {prettifyJson(element)});
}

// set callback triggers to format fhir json on webpage load
document.addEventListener("load", formatJson);
document.addEventListener("turbo:load", formatJson);
document.addEventListener("ready turbo:load", formatJson);

// turn on bootstrap 5 tooltips
function enableTooltips() {
	const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
	const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
	console.log("Enabling tooltips");
}

// set callback to enable tooltips
document.addEventListener("load", enableTooltips);
document.addEventListener("turbo:load", enableTooltips);
document.addEventListener("ready turbo:load", enableTooltips);

