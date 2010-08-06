var Tr8n = {
	enabled: false,
	originalColors: {},
	selectedPhrase: "",
	translation_keys: {},
	source: "",
	
	init: function() {
		Tr8n.Utils.log("Initializing tr8n...");
        window.getBrowser().addProgressListener(new WebProgressListener(), Components.interfaces.nsIWebProgress.NOTIFY_ALL); 
	},

 	toggle: function() {
		if (!Tr8n.enabled) {
			document.getElementById("tr8nToolsMenuItem").label = "Disable Tr8n";
			Tr8n.registerKeys(Tr8n.Utils.getBrowserDocument());
			Tr8n.enabled = true;
			
//			window.content.document.addEventListener("mouseover", this.handleMouseOverEvent, false);
//			window.content.document.addEventListener("mouseout", this.handleMouseOutEvent, false);
	
			window.content.document.addEventListener('contextmenu', this.handleClickEvent, false);
		} else {
			Tr8n.Utils.getBrowserWindow().content.location.reload();
			document.getElementById("tr8nToolsMenuItem").label = "Enable Tr8n";
			Tr8n.enabled = false;
		}
	},
	
	handleBrowserLoaded: function() {
		if (Tr8n.enabled) {
			Tr8n.registerKeys(Tr8n.Utils.getBrowserDocument());
			window.content.document.addEventListener('contextmenu', this.handleClickEvent, false);
		}
	},

	handleClickEvent: function(event) {
	    if (event.stop) event.stop();
	    if (event.preventDefault) event.preventDefault();
	    if (event.stopPropagation) event.stopPropagation();
		
		if (event.target.className == 'tr8n') {
			var label = event.target.innerHTML;
			Tr8n.selectedPhrase = Tr8n.sanitizeString(label);
			Tr8n.source = encodeURI(Tr8n.Utils.getBrowserWindow().content.location + "");
			Tr8n.Utils.log(Tr8n.source);
			
			window.openDialog('chrome://tr8n/content/translator.xul','Tr8n Translator','chrome,centerscreen,modal');
		}
	},
	
	handleMouseOverEvent: function(event) {
		Tr8n.originalColors[event.target] = event.target.style.background;
		event.target.style.background = "#f00";
	},

	handleMouseOutEvent: function(event) {
		event.target.style.background = Tr8n.originalColors[event.target];
	},
	
	generateKey: function(label) {
	    var key = label + ";;;";
	    return MD5(key);
	},
	
	substituteTranslation: function(translation_key, translation) {
		if (!translation_key) return;
		var spanNodes = Tr8n.translation_keys[translation_key];
		if (!spanNodes) return;
		
	    for (var i = 0; i < spanNodes.length; i++) {
			var spanNode = spanNodes[i];
			spanNode.innerHTML = translation;
			spanNode.style.borderBottom = '2px solid green';
		}
	},
	
	sanitizeString: function(string) {
	  if (!string) return "";	
	  return string.replace(/^\s+|\s+$/g,"");
	},
	
	registerKeys: function (document) {
		var arr = [];
	    var tree_walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
	    while (tree_walker.nextNode()) {
	        arr.push(tree_walker.currentNode);
	    }
		
	    Tr8n.translation_keys = {};
		
	    for (var i = 0; i < arr.length; i++) {
	        if (arr[i].nodeValue.replace(/ /g, '').length > 1 && arr[i].parentNode.tagName != "script") {
				var label = Tr8n.sanitizeString(arr[i].nodeValue);
				if (label == "") continue;
				
	            var spanNode = document.createElement('span');
	            spanNode.className = 'tr8n';
				spanNode.style.borderBottom = '2px solid red';
	            spanNode.appendChild(document.createTextNode(arr[i].nodeValue));
	            arr[i].parentNode.replaceChild(spanNode, arr[i]);
				
				var key = Tr8n.generateKey(label);
				if (!Tr8n.translation_keys[key])
					Tr8n.translation_keys[key] = [];
				Tr8n.translation_keys[key].push(spanNode);
	        }
	    }
	}
}

Tr8n.Utils = {
	getBrowserWindow: function() {
	    var wm = Components.classes["@mozilla.org/appshell/window-mediator;1"].getService(Components.interfaces.nsIWindowMediator);
	    return wm.getMostRecentWindow("navigator:browser");
	},

	getBrowserDocument: function() {
	    return Tr8n.Utils.getBrowserWindow().content.document;
	},
	
	log: function(aText) {
	    var console = Components.classes["@mozilla.org/consoleservice;1"].getService(Components.interfaces.nsIConsoleService);
	    console.logStringMessage("Tr8n: " + aText);
	}
}

function WebProgressListener() {
	 
	this.QueryInterface = function (iid) { 
		if (iid.equals(Components.interfaces.nsIWebProgressListener) || iid.equals(Components.interfaces.nsISupportsWeakReference) || iid.equals(Components.interfaces.nsISupports)) 
			return this;
		throw Components.results.NS_ERROR_NO_INTERFACE; 
	}

	this.onStateChange = function (webProgress, request, stateFlags, status) { 
		Tr8n.Utils.log('main window: onStateChange : [' + request.name + '], flags [' + stateFlags + '], status [' + status + ']'); 
		if (stateFlags & Components.interfaces.nsIWebProgressListener.STATE_STOP) {
			Tr8n.handleBrowserLoaded();	
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

window.addEventListener("load", Tr8n.init, true);
