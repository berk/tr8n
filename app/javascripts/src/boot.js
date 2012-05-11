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


// Tr8n.Utils.addEvent(window, 'load', function() {
//   alert("Booting Tr8n");


  // Tr8n.Utils.insertDiv('tr8n_root', 'display:none');

window.Tr8n = window.$tr8n = Tr8n.Utils.extend(Tr8n, {
  element     : Tr8n.Utils.element,
  value       : Tr8n.Utils.value,
  log         : Tr8n.Logger.log,
  getStatus   : Tr8n.SDK.Auth.getStatus,
  connect     : Tr8n.SDK.Auth.connect,
  disconnect  : Tr8n.SDK.Auth.disconnect,
  logout      : Tr8n.SDK.Auth.logout,
  api         : Tr8n.SDK.Api.get          //most api calls are gets
});

Tr8n.init();

// });
