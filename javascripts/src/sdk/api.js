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

Tr8n.SDK.Api = {

	// Makes an oauth jsonp request to Tr8n's servers for data.
	//
	// 		Tr8n.SDK.Api.get('/translator', function(data){
	//			// do something awesome with Tr8n data
	//		})
	//
	get: function(path, params, cb) {
    if (typeof params == 'function') {
      cb = params;
      params = {};
    } 

    params || (params = {});
    if (params.method) {
      params['_method'] = params.method;
      delete params.method;
    }

    path = Tr8n.host + Tr8n.url.api + "/" + path.replace(/^\//,'');

    if (Tr8n.SDK.Request.sameOrigin()) {
      var method = params['_method'] || 'get';
      delete params._method;

      return Tr8n.SDK.Request.ajax(path, {
        method: method,
        parameters: params,
        onSuccess: cb
      });
    }
  
    Tr8n.SDK.Request.oauth(path, params, cb);
	},	
	
	// Makes an oauth jsonp request to Tr8n's servers to save data. All jsonp
	// requests use a GET method but we can get around this by adding a 
	// _method=post parameter to our request.
	//
	// 		Tr8n.Api.post('/translator', function(data){
	//			// Add awesome data to Tr8n
	//		})
	//
	post: function(path, params, cb) {
		params = Tr8n.Utils.extend({'_method':'post'}, params || {});
		this.get(path, params, cb);
	}
		
}
	