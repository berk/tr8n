var Translator = {
	init: function() {
 	  // alert(window.opener.Tr8n.enabled);	

	  var browser = document.getElementById("translatorBrowser");
	  var url = "http://localhost:3001/tr8n/firefox/translator?label=" + window.opener.Tr8n.selectedPhrase + "&source=" + window.opener.Tr8n.source;
	  browser.addProgressListener(new WebProgressListener(url), Components.interfaces.nsIWebProgress.NOTIFY_ALL); 
	  browser.loadURI(url, null, null);
	},
	handleBrowserLoaded: function() {
		log("Registering clicks...");
		var browser = document.getElementById("translatorBrowser");
		browser.contentWindow.addEventListener("click", this.handleClickEvent, false);
		var status = browser.contentWindow.document.getElementById("tr8n_translator_status");
		if (status && status.innerHTML == "Completed") {
			var translation_key = browser.contentWindow.document.getElementById("tr8n_translation_key").innerHTML;
			var translation = browser.contentWindow.document.getElementById("tr8n_translation").innerHTML;
			log(translation_key);
			window.opener.Tr8n.substituteTranslation(translation_key, translation);
			document.getElementById("translatorDialog").cancelDialog();
		}
	},
	handleClickEvent: function(event) {
		log(event.target.id);
		if (event.target.id == 'tr8nTranslateBtn') {
			var browser = document.getElementById("translatorBrowser");
			browser.contentWindow.document.getElementById("tr8n_translator_form").submit(); 
		} else if (event.target.id == 'tr8nCancelBtn') {
			document.getElementById("translatorDialog").cancelDialog();
		}
	}
}

function log(aText) {
    var console = Components.classes["@mozilla.org/consoleservice;1"].getService(Components.interfaces.nsIConsoleService);
    console.logStringMessage("Tr8n: " + aText);
}

function WebProgressListener(url) { 
	this.url_ = url;

	this.QueryInterface = function (iid) { 
		if (iid.equals(Components.interfaces.nsIWebProgressListener) || iid.equals(Components.interfaces.nsISupportsWeakReference) || iid.equals(Components.interfaces.nsISupports)) 
			return this;
		throw Components.results.NS_ERROR_NO_INTERFACE; 
	}

	this.onStateChange = function (webProgress, request, stateFlags, status) { 
		log('dialog window: onStateChange : [' + request.name + '], flags [' + stateFlags + '], status [' + status + ']'); 
		if (stateFlags & Components.interfaces.nsIWebProgressListener.STATE_STOP) {
			Translator.handleBrowserLoaded();	
		}
	}

	this.onLocationChange = function (webProgress, request, location) { 
	//	log('onLocationChange : [' + request.name + ']'); 
	}

	this.onProgressChange = function (webProgress, request, curSelf, maxSelf, curTotal, maxTotal) { 
//		log('onProgressChange : [' + request.name + ']'); 
	}

	this.onStatusChange = function (webProgress, request, status, message) { 
	//	log('onStatusChange : [' + request.name + ']'); 
	}

	this.onSecurityChange = function (webProgress, request, state) { 
		// log('onSecurityChange : [' + request.name + '], state [' + state + ']'); 
	} 
} 

window.addEventListener("load", Translator.init, true);
