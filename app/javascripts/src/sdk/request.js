/****************************************************************************
  Copyright (c) 2010-2012 Michael Berkovich, Ian McDaniel, tr8n.net

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

Tr8n.SDK.Request = {

	callbacks : {},
	
  evalResults: function(str) {
    return eval("[" + str + "]")[0];
  },

  ///////////////////////////////////////////////////////////////////////////////////////////////  
  // Standard AJAX request
  //
  //    Tr8n.SDK.Request.ajax(url[, options])
  //
  ///////////////////////////////////////////////////////////////////////////////////////////////  

  ajax: function(url, options) {
    options = options || {};
    options.parameters = options.parameters || {};

    var meta = Tr8n.Utils.getMetaAttributes();
    if (meta['csrf-param'] && meta['csrf-token']) {
      options.parameters[meta['csrf-param']] = meta['csrf-token'];
    }
    options.parameters = Tr8n.Utils.toQueryParams(options.parameters);
    options.method = options.method || 'get';

    var self=this;
    if (options.method == 'get' && options.parameters != '') {
      url = url + (url.indexOf('?') == -1 ? '?' : '&') + options.parameters;
    }

    var request = Tr8n.Utils.getRequest();

    request.onreadystatechange = function() {
      if(request.readyState == 4) {
        if (request.status == 200) {
          if (options.onSuccess) options.onSuccess(self.evalResults(request.responseText));
          if (options.onComplete) options.onComplete(self.evalResults(request.responseText));
          if (options.evalScripts) Tr8n.Utils.evalScripts(request.responseText);
        } else {
          if (options.onFailure) options.onFailure(request)
          if (options.onComplete) options.onComplete(request)
        }
      }
    }

    request.open(options.method, url, true);
    request.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    request.setRequestHeader('Accept', 'text/javascript, text/html, application/xml, text/xml, */*');
    request.send(options.parameters);
  },

  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// Standard JSONP request
	//
	// 		Tr8n.SDK.Request.jsonp(url[, paramerters, callback])
	//
  ///////////////////////////////////////////////////////////////////////////////////////////////  

	jsonp: function(url, params, cb) {
		var 
			self    = this,
			script 	= document.createElement('script'),
			uuid		= Tr8n.Utils.uuid(),
			params 	= Tr8n.Utils.extend((params||{}), {callback: 'Tr8n.SDK.Request.callbacks.' + uuid}),
			url 		= url + (url.indexOf('?')>-1 ? '&' : '?') + Tr8n.Utils.encodeQueryString(params);

		this.callbacks[uuid] = function(data) {
			if(data.error) {
				Tr8n.log([data.error,data.error_description].join(' : '));
			}
			if(cb) cb(data);
			delete self.callbacks[uuid];
		}
		script.src = url;
		document.getElementsByTagName('head')[0].appendChild(script);
	},
	
  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// Same as a jsonp request but with an access token for oauth authentication
	//
	// 		Tr8n.SDK.Request.oauth(url[, paramerters, callback])
	//
  ///////////////////////////////////////////////////////////////////////////////////////////////  

	oauth: function(url, params, cb) {
		params || (params = {});
		if (Tr8n.access_token) {
			Tr8n.Utils.extend(params, {access_token: Tr8n.access_token});
		} else {
			Tr8n.log('Tr8n.SDK.Request.oauth() called without an access token.');
		}
		this.jsonp(url, params, cb);
	},

  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// Opens a popup window with the given url and places it at the
	// center of the current window. Used for app authentication. Should only 
	// be called on a user event like a click as many browsers block popups 
	// if not initiated by a user. 
	//
	// 		Tr8n.Request.popup(url[, paramerters, callback])
	//
  ///////////////////////////////////////////////////////////////////////////////////////////////  

	popup: function(url, params, cb) {
		this.registerXDHandler();
		// figure out where the center is
		var
			screenX    	= typeof window.screenX != 'undefined' ? window.screenX : window.screenLeft,
			screenY    	= typeof window.screenY != 'undefined' ? window.screenY : window.screenTop,
			outerWidth 	= typeof window.outerWidth != 'undefined' ? window.outerWidth : document.documentElement.clientWidth,
			outerHeight = typeof window.outerHeight != 'undefined' ? window.outerHeight : (document.documentElement.clientHeight - 22),
			width    		= params.width 	|| 600,
			height   		= params.height || 400,
			left     		= parseInt(screenX + ((outerWidth - width) / 2), 10),
			top      		= parseInt(screenY + ((outerHeight - height) / 2.5), 10),
			features = (
				'width=' + width +
				',height=' + height +
				',left=' + left +
				',top=' + top
			);
		var 
			uuid		= Tr8n.Utils.uuid(),
			params 	= Tr8n.Utils.extend((params||{}),{
				callback	: uuid,
				display		: 'popup',
				origin		: this.origin()
			}),
			url 		= url + (url.indexOf('?')>-1 ? '&' : '?') + Tr8n.Utils.encodeQueryString(params);
		var win = window.open(url, uuid, features);
		this.callbacks[uuid] = function(data) {
			if(cb) cb(data,win);
			delete Tr8n.SDK.Request.callbacks[uuid];
		}
	},

  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// Creates and inserts a hidden iframe with the given url then removes 
	// the iframe from the DOM
	//
	// 		Tr8n.SDK.Request.hidden(url[, paramerters, callback])
	//
  ///////////////////////////////////////////////////////////////////////////////////////////////  

	hidden: function(url, params, cb) {
		this.registerXDHandler();
		var 
			iframe 	= document.createElement('iframe'),
			uuid		= Tr8n.Utils.uuid(),
			params 	= Tr8n.Utils.extend((params||{}),{
				callback	: uuid,
				display		: 'hidden',
				origin		: this.origin()
			}),
			url 		= url + (url.indexOf('?')>-1 ? '&' : '?') + Tr8n.Utils.encodeQueryString(params);
			
		iframe.style.display = "none";
		this.callbacks[uuid] = function(data) {
			if(cb) cb(data);
			delete Tr8n.SDK.Request.callbacks[uuid];
			iframe.parentNode.removeChild(iframe);
		}
		iframe.src = url;
		document.getElementsByTagName('body')[0].appendChild(iframe);
	},

  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// Make sure we're listening to the onMessage event
  ///////////////////////////////////////////////////////////////////////////////////////////////  
	registerXDHandler: function() {
		if(this.xd_registered) return;
		var 
			self = Tr8n.SDK.Request,
			fn = function(e) { Tr8n.SDK.Request.onMessage(e) }
		
    window.addEventListener ? window.addEventListener('message', fn, false) : window.attachEvent('onmessage', fn);
		this.xd_registered = true;
	},

  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// handles message events sent via postMessage, and fires the appropriate callback
  ///////////////////////////////////////////////////////////////////////////////////////////////  
	onMessage: function(e) {
		var data = {};
		if (e.data && typeof e.data == 'string') {
			data = Tr8n.Utils.decodeQueryString(e.data);
		}
		
		if (data.error) {
			Tr8n.log(data.error, data.error_description);
		}
		
		if (data.callback) {
			var cb = this.callbacks[data.callback];
			if (cb) {
				cb(data);
				delete this.callbacks[data.callback];
			}
		}
	},
	
  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// get the origin of the page
  ///////////////////////////////////////////////////////////////////////////////////////////////  
	origin: function() {
		return (window.location.protocol + '//' + window.location.host)
	},

  sameOrigin: function() {
    if (Tr8n.host == '') return true;
    var local_domain = document.location.href.split("/")[2];
    var origin_domain = Tr8n.host.split("/")[2];

    return (local_domain == origin_domain);
  }

}
