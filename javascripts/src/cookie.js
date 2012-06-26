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

Tr8n.Cookie = function (key, value, options) {
	if (!Tr8n.cookies) return;

  if (arguments.length > 1 && String(value) !== "[object Object]") {
		options = Tr8n.Utils.extend({}, options);

		if (value === null || value === undefined) options.expires = -1;

		if (typeof options.expires === 'number') {
			var days = options.expires, t = options.expires = new Date();
			t.setDate(t.getDate() + days);
		}

		value = String(value);
		return (document.cookie = [
			encodeURIComponent(key), '=',
			options.raw 		? value : encodeURIComponent(value),
			options.expires ? '; expires=' + options.expires.toUTCString() : '',
			options.path 		? '; path=' + options.path : '',
			options.domain 	? '; domain=' + options.domain : '',
			options.secure 	? '; secure' : ''
		].join(''));
  }
  
  options = value || {};
  var result, decode = options.raw ? function (s) { return s; } : decodeURIComponent;
  return (result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie)) ? decode(result[1]) : null;
}
