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

Tr8n.SDK.Auth = {
	
	// Returns the current authentication status of the user from the server, and provides
	// an access token if the user is logged into Tr8n and has authorized the app.
	//
	// 		Tr8n.SDK.Auth.getStatus(function(response){
	//			if(response.status == 'authorized') {
	//				// User is logged in and has authorized the app
	//			}
	//		})
	//
	// The status returned in the response will be either 'authorized', user is logged in
	// and has authorized the app, 'unauthorized', user is logged in but has not authorized 
	// the app and 'unknown', user is not logged in.
	
	getStatus: function(cb) {
		if(!Tr8n.app_id) {
			return Tr8n.log('Tr8n.Auth.getStatus() called without an app id');
		}
		var url = Tr8n.host + Tr8n.url.status;

		Tr8n.SDK.Request.hidden(url,{client_id:Tr8n.app_id}, function(data) {
			Tr8n.SDK.Auth.setStatus(data);
			if(cb) cb(data);
		});
	},
	
	// Launches the authorization window to connect to Tr8n and if successful returns an
	// access token.
	//
	// 		Tr8n.SDK.Auth.connect(function(response) {
	//			if(response.status == 'authorized') {
	//				// User is logged in and has authorized the app
	//			}
	//		})
	//
	
	connect: function(cb) {
		if(!Tr8n.app_id) {
			return Tr8n.log('Tr8n.SDK.Auth.connect() called without an app id.');
		}

		if(!Tr8n.access_token) {
			var url = Tr8n.host + Tr8n.url.connect,
  				params = {
  					response_type	: 'token',
  					client_id			: Tr8n.app_id
  				};

			Tr8n.SDK.Request.popup(url, params, function(data, win) {
				Tr8n.SDK.Auth.setStatus(data);
				if(win) win.close();
				if(cb) cb(data);
			});
		} else {
			Tr8n.log('Tr8n.SDK.Auth.connect() called when user is already connected.');
			if(cb) cb();
		}
	},
	
	// Revokes your apps authorization access
	//
	// 		Tr8n.SDK.Auth.disconnect(function(){
	//			// App authorization has been revoked
	//		})
	//
	disconnect: function(cb) {
		if(!Tr8n.app_id) {
			return Tr8n.log('Tr8n.SDK.Auth.disconnect() called without an app id.');
		}
		var url = Tr8n.host + Tr8n.url.disconnect;
		Tr8n.SDK.Request.jsonp(url, {client_id:Tr8n.app_id}, function(r) {
			Tr8n.SDK.Auth.setStatus(null);
			if(cb) cb(r);
		})
	},
	
	// Logs the user out of Tr8n
	//
	// 		Tr8n.SDK.Auth.logout(function(){
	//			// App authorization has been revoked
	//		})
	//
	logout: function(cb) {
		if(!Tr8n.app_id) {
			return Tr8n.log('Tr8n.SDK.Auth.logout called() without an app id.');
		}
		var url = Tr8n.host + Tr8n.url.logout;

		Tr8n.Request.jsonp(url, {client_id:Tr8n.app_id}, function(r) {
			Tr8n.SDK.Auth.setStatus(null);
			if(cb) cb(r);
		});
	},
	
	// Determines the correct status ('unknown', 'unauthorized' or 'authorized') and 
	// sets the access token if authorization is approved.
	setStatus: function(data) {
		data || (data = {});
		
    if (data.access_token) {
			Tr8n.access_token = data.access_token;
			Tr8n.Cookie('geni' + Tr8n.app_id, Tr8n.access_token);
			data.status = "authorized";
		} else {
			Tr8n.access_token = null;
			Tr8n.Cookie('tr8n' + Tr8n.app_id, null);
			data.status = data.status || "unknown";
		}

		if(Tr8n.status != data.status) {
			Tr8n.Event.trigger('auth:statusChange', data.status);
		}
		return (Tr8n.status = data.status);
	}

}

