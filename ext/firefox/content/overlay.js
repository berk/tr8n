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
**** Tr8n Firefox Extension Singleton
****************************************************************************/

Tr8n.Firefox = {
	enabled: false,
	original_colors: {},
	translation_keys: {},
	proxy: {},
  selected_label: "",
	inline_translations_enabled: false,
  	
	init: function() {
		Tr8n.Firefox.log("Initializing Tr8n Firefox Extension...");
    window.getBrowser().addProgressListener(new BrowserProgressListener(), Components.interfaces.nsIWebProgress.NOTIFY_ALL); 
	},

  getBrowserWindow: function() {
      var wm = Components.classes["@mozilla.org/appshell/window-mediator;1"].getService(Components.interfaces.nsIWindowMediator);
      return wm.getMostRecentWindow("navigator:browser");
  },

  getBrowserDocument: function() {
      return Tr8n.Firefox.getBrowserWindow().content.document;
  },
  
	getProxy: function() {
		return Tr8n.Firefox.proxy;
	},
	
  log: function(aText) {
      var console = Components.classes["@mozilla.org/consoleservice;1"].getService(Components.interfaces.nsIConsoleService);
      console.logStringMessage("Tr8n Extension: " + aText);
  },

  getElement: function(id) {
		return document.getElementById(id);
	},


	getBrowserElement: function(id) {
    return Tr8n.Firefox.getBrowserDocument().getElementById(id);
  },

  toggleInlineTranslations: function() {
    if (!Tr8n.Firefox.inline_translations_enabled) {
      Tr8n.Firefox.getElement("tr8n_enable_inline_mode_toolbar_button").label = "Disable Inline Translations";
			Tr8n.Firefox.inline_translations_enabled = true;
	  } else {
      Tr8n.Firefox.getElement("tr8n_enable_inline_mode_toolbar_button").label = "Enable Inline Translations";
      Tr8n.Firefox.inline_translations_enabled = false;
		}
		
    Tr8n.Firefox.getBrowserWindow().content.location.reload();
	},

 	toggle: function() {
		if (!Tr8n.Firefox.enabled) {
			Tr8n.Firefox.getElement("tr8n_tools_menu_item").label = "Disable Tr8n";
			Tr8n.Firefox.getElement("tr8n_enable_toolbar_button").label = "Disable Tr8n";
			Tr8n.Firefox.registerDocumentElements(Tr8n.Firefox.getBrowserDocument());
			Tr8n.Firefox.enabled = true;
			
//			window.content.document.addEventListener("mouseover", this.handleMouseOverEvent, false);
//			window.content.document.addEventListener("mouseout", this.handleMouseOutEvent, false);
	
			Tr8n.Firefox.registerClicks();
		} else {
			
			Tr8n.Firefox.getBrowserWindow().content.location.reload();
			Tr8n.Firefox.getElement("tr8n_tools_menu_item").label = "Enable Tr8n";
      Tr8n.Firefox.getElement("tr8n_enable_toolbar_button").label = "Enable Tr8n";
			Tr8n.Firefox.enabled = false;
		}
	},
	
	registerClicks: function() {
		if (!Tr8n.Firefox.inline_translations_enabled) return;
		window.content.document.addEventListener('contextmenu', Tr8n.Firefox.handleClickEvent, false);
	},
	
	handleBrowserLoaded: function() {
		// if the status node has already been added, don't process the doc
		if (Tr8n.Firefox.getBrowserElement('tr8n_status_node')) return;
		
		Tr8n.Firefox.log("Registering document elements...");
		if (Tr8n.Firefox.enabled) {
			Tr8n.Firefox.registerDocumentElements(Tr8n.Firefox.getBrowserDocument());
 	    Tr8n.Firefox.registerClicks();
		}
	},

  getSource: function() {
		return Tr8n.Firefox.getBrowserWindow().content.location + "";
	},
	
	getSelectedLabel: function() {
		return Tr8n.Firefox.selected_label;
	},
	
	handleClickEvent: function(event) {
		if (event.stop) event.stop();
		if (event.preventDefault) event.preventDefault();
		if (event.stopPropagation) event.stopPropagation();
		
		if (event.target.className == 'tr8n') {
			var label = event.target.innerHTML;
			Tr8n.Firefox.selected_label = Tr8n.Firefox.sanitizeString(label);
			window.openDialog('chrome://tr8n/content/translator.xul', 'Tr8n Translator', 'chrome,centerscreen,modal');
		}
	},
	
	handleMouseOverEvent: function(event) {
		Tr8n.Firefox.original_colors[event.target] = event.target.style.background;
		event.target.style.background = "#f00";
	},

	handleMouseOutEvent: function(event) {
		event.target.style.background = Tr8n.Firefox.original_colors[event.target];
	},
	
	generateKey: function(label) {
	    var key = label + ";;;";
	    return MD5(key);
	},
	
	substituteTranslations: function() {
		Tr8n.Firefox.log("Translations loaded...");
    var translations = Tr8n.Firefox.getProxy().getTranslations();
		
		for (var key in Tr8n.Firefox.translation_keys) {
      var translation = translations[key];
			if (!translation) continue;
			var translated_label = translation['label'];
      if (!translated_label) continue;
			
			Tr8n.Firefox.log("Translation: " + translated_label);
			Tr8n.Firefox.substituteTranslation(key, translated_label);
		}
	},
	
	substituteTranslation: function(translation_key, translation) {
		if (!translation_key) return;
		var spanNodes = Tr8n.Firefox.translation_keys[translation_key];
		if (!spanNodes) return;
		
    for (var i = 0; i < spanNodes.length; i++) {
			var spanNode = spanNodes[i];
      spanNode.innerHTML = translation;
			
      if (Tr8n.Firefox.inline_translations_enabled) {
	  	  spanNode.style.borderBottom = '2px solid green';
	    }
		}
	},
	
	sanitizeString: function(string) {
	  if (!string) return "";	
	  return string.replace(/^\s+|\s+$/g,"");
	},
	
	registerDocumentElements: function (document) {
		if (document.getElementById('tr8n_status_node')) return;
		
    Tr8n.Firefox.proxy = new Tr8n.Proxy({
      source: Tr8n.Firefox.getSource(),
			url: 'http://localhost:3001/tr8n/api/v1/language/translate',
			onTranslationsRegistered: Tr8n.Firefox.substituteTranslations
    });

    // add node to the document so it is not processed twice
    var tr8nStatusNode = document.createElement('div');
    tr8nStatusNode.id = 'tr8n_status_node';
		tr8nStatusNode.style.display = 'none';
		document.body.appendChild(tr8nStatusNode);

	  var arr = [];
    var tree_walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
    while (tree_walker.nextNode()) {
        arr.push(tree_walker.currentNode);
    }
	
	  var language = new Tr8n.Proxy.Language({
	    'proxy': Tr8n.Firefox.getProxy()
	  });
		
    Tr8n.Firefox.translation_keys = {};
	
    for (var i = 0; i < arr.length; i++) {
      if (arr[i].parentNode.tagName == "script") continue;
			if (arr[i].nodeValue.replace(/ /g, '').length == 0) continue;
			// if (arr[i].nodeValue.indexOf("<!-") != -1) continue;
			
			// we need to handle empty spaces better
			var original_label = Tr8n.Firefox.sanitizeString(arr[i].nodeValue);
			if (original_label == "") continue;

      var tkey = new Tr8n.Proxy.TranslationKey(original_label, "", {'proxy': Tr8n.Firefox.getProxy()});
      var translated_label = tkey.translate(language, {}, {});

      if (!Tr8n.Firefox.translation_keys[tkey.key]) 
         Tr8n.Firefox.translation_keys[tkey.key] = [];
			
			if (Tr8n.Firefox.inline_translations_enabled) {
	      var spanNode = document.createElement('span');
	      spanNode.className = 'tr8n';
	      spanNode.style.borderBottom = '2px solid red';
	      spanNode.appendChild(document.createTextNode(arr[i].nodeValue));
	      arr[i].parentNode.replaceChild(spanNode, arr[i]);
	      Tr8n.Firefox.translation_keys[tkey.key].push(spanNode);
			} else {
				Tr8n.Firefox.translation_keys[tkey.key].push(arr[i].parentNode);
			}
			
    }
	}
}

/****************************************************************************
**** Browser Window Progress Listener
****************************************************************************/

function BrowserProgressListener() {
	 
	this.QueryInterface = function (iid) { 
		if (iid.equals(Components.interfaces.nsIWebProgressListener) || iid.equals(Components.interfaces.nsISupportsWeakReference) || iid.equals(Components.interfaces.nsISupports)) 
			return this;
		throw Components.results.NS_ERROR_NO_INTERFACE; 
	}

	this.onStateChange = function (webProgress, request, stateFlags, status) { 
		// Tr8n.Firefox.log('main window: onStateChange : [' + request.name + '], flags [' + stateFlags + '], status [' + status + ']'); 
		if (stateFlags & Components.interfaces.nsIWebProgressListener.STATE_STOP) {
			 Tr8n.Firefox.handleBrowserLoaded();	
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

window.addEventListener("load", Tr8n.Firefox.init, true);
