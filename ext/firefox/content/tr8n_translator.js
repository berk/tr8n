/****************************************************************************
  Copyright (c) 2010 Michael Berkovich, Geni Inc

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:
 
  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.
 
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
****************************************************************************/

var Tr8n = Tr8n || {};

/****************************************************************************
**** Tr8n FireFox Translator Singleton
****************************************************************************/

Tr8n.Translator = {
	eventsRegistered: false,
	
	init: function() {
    Tr8n.Translator.log("Initializing Tr8n Firefox Translator...");
    Tr8n.Translator.eventsRegistered = false;
		
	  var url = "http://localhost:3001/tr8n/firefox/translator";
    url = url + "?label=" + encodeURIComponent(Tr8n.Translator.getExtension().getSelectedLabel());
		url = url + "&source=" + encodeURIComponent(Tr8n.Translator.getExtension().getSource()); 		

    Tr8n.Translator.log(url);
		
    var browser = Tr8n.Translator.getElement("translatorBrowser");
	  browser.addProgressListener(new TranslatorProgressListener(), Components.interfaces.nsIWebProgress.NOTIFY_ALL); 
	  browser.loadURI(url, null, null);
	},
	getExtension: function() {
		return window.opener.Tr8n.Firefox;
	},
	getElement: function(id) {
		return document.getElementById(id);
	},
  getBrowserElement: function(id) {
    var browser = Tr8n.Translator.getElement("translatorBrowser");
    return browser.contentWindow.document.getElementById(id);
  },
  log: function(aText) {
    var console = Components.classes["@mozilla.org/consoleservice;1"].getService(Components.interfaces.nsIConsoleService);
    console.logStringMessage("Tr8n Translator: " + aText);
  },
	handleBrowserLoaded: function() {
		// only register events once
		if (Tr8n.Translator.eventsRegistered) return;
		
		Tr8n.Translator.eventsRegistered = true;
			
		Tr8n.Translator.log("Registering clicks... ");

		var browser = Tr8n.Translator.getElement("translatorBrowser");
		browser.contentWindow.addEventListener("click", this.handleClickEvents, false);
		
		var status = browser.contentWindow.document.getElementById("tr8n_translator_status");
		if (status && status.innerHTML == "Completed") {
			var translation_key = Tr8n.Translator.getBrowserElement("tr8n_translation_key").innerHTML;
			var translation = Tr8n.Translator.getBrowserElement("tr8n_translation").innerHTML;
			Tr8n.Translator.log(translation_key);
			Tr8n.Translator.getExtension().substituteTranslation(translation_key, translation);
			Tr8n.Translator.getElement("translatorDialog").cancelDialog();
		}
	},
	
	handleClickEvents: function(event) {
		if (event.target.id == 'tr8nTranslateBtn') {
			var browser = Tr8n.Translator.getElement("translatorBrowser");
      Tr8n.Translator.eventsRegistered = false;
			Tr8n.Translator.getBrowserElement("tr8n_translator_form").submit(); 
			
		} else if (event.target.id == 'tr8nCancelBtn') {
			Tr8n.Translator.getElement("translatorDialog").cancelDialog();
			
		}
	}
}

function TranslatorProgressListener() { 

	this.QueryInterface = function (iid) { 
		if (iid.equals(Components.interfaces.nsIWebProgressListener) || iid.equals(Components.interfaces.nsISupportsWeakReference) || iid.equals(Components.interfaces.nsISupports)) 
			return this;
		throw Components.results.NS_ERROR_NO_INTERFACE; 
	}

	this.onStateChange = function (webProgress, request, stateFlags, status) { 
		if (stateFlags & Components.interfaces.nsIWebProgressListener.STATE_STOP) {
       // Tr8n.Translator.log('dialog window: onStateChange : [' + request.name + '], flags [' + stateFlags + '], status [' + status + ']'); 
			 Tr8n.Translator.handleBrowserLoaded();	
		}
	}

	this.onLocationChange = function (webProgress, request, location) { 
	//	log('onLocationChange : [' + request.name + ']'); 
	}

	this.onProgressChange = function (webProgress, request, curSelf, maxSelf, curTotal, maxTotal) { 
  //	log('onProgressChange : [' + request.name + ']'); 
	}

	this.onStatusChange = function (webProgress, request, status, message) { 
	//	log('onStatusChange : [' + request.name + ']'); 
	}

	this.onSecurityChange = function (webProgress, request, state) { 
		// log('onSecurityChange : [' + request.name + '], state [' + state + ']'); 
	} 
} 

window.addEventListener("load", Tr8n.Translator.init, true);
