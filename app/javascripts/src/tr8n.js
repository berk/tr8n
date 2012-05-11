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

document.createElement('tr8n');
document.createElement('tml');

var Tr8n = {

  // current version
  version: '1.0.0',
  host: '',
  logging: true,
  app_id: null,
  status: null, // unknown, authorized or unauthorized
  cookies: false,
  access_token: null,
  google_api_key: null,
  inline_translations_enabled: false,

  url: {
    api       : '/tr8n/api/v1',
    status    : '/oauth/status',
    connect   : '/oauth/authorize',
    disconnect: '/oauth/deauthorize',
    logout    : '/oauth/logout'
  },

  UI: {

  },

  SDK: {
    TML: {},
    Tokens: {},
    Rules: {}
  },

  ///////////////////////////////////////////////////////////////////////////////////////////////  
  // Initialize the Tr8n SDK library
  // The best place to put this code is right before the closing </body> tag
  //      
  //   Tr8n.init({
  //     app_id       : 'YOUR APP KEY',             // app id or app key
  //     cookies      : true,                       // enable cookies to allow the server to access the session
  //     logging      : true                        // enable log messages to help in debugging
  //   });
  //
  ///////////////////////////////////////////////////////////////////////////////////////////////  

  init: function(opts, cb) {
    opts || (opts = {});
    this.app_id     = opts.app_id;
    this.logging    = (window.location.toString().indexOf('debug=1') > 0)  || opts.logging || this.logging;
    this.cookies    = opts.cookies  || this.cookies;
    this.host       = opts.host     || this.host;

    Tr8n.log("Initializing Tr8n...");

    if (window.addEventListener) {  // all browsers except IE before version 9
      window.addEventListener("message", Tr8n.onMessage, false);
    } else {
      if (window.attachEvent) {   // IE before version 9
          window.attachEvent("onmessage", Tr8n.onMessage);
      }
    }

    Tr8n.UI.Translator.init();

    Tr8n.Utils.addEvent(document, "keyup", function(event) {
      if (event.keyCode == 27) { // Capture Esc key
        Tr8n.UI.Translator.hide();
        Tr8n.UI.LanguageSelector.hide();
        Tr8n.UI.Lightbox.hide();
      }
    });

    return this;
  },

  ///////////////////////////////////////////////////////////////////////////////////////////////  
  // Cross-domain communication functions
  ///////////////////////////////////////////////////////////////////////////////////////////////  

  postMessage: function(msg, origin) {
    var local_domain = document.location.href.split("/")[2];
    var origin_domain = origin.split("/")[2];

    if (local_domain == origin_domain) {
      top.Tr8n.onMessage(msg);
    } else {
      if (parent.postMessage) {
        parent.postMessage(msg, origin);
      } else {
        alert("Failed to deliver a tr8n message: " + msg + " to origin: " + origin);
      }       
    }
  },

  onMessage:function(event) {
    var msg = '';
    if (typeof event == 'string') {
      msg = event;
    } else {
      msg = event.data;
    }

    var elements = msg.split(':');
    // if this is not a tr8n message, ignore it
    if (elements[0] != 'tr8n') return;

    if (elements[1] == 'reload') {
      window.location.reload();
      return;
    }

    if (elements[1] == 'translation') {
      if (elements[2] == 'report') {
        Tr8n.UI.Translator.hide();
        Tr8n.UI.Lightbox.show('/tr8n/translator/lb_report?translation_id=' + elements[3], {width:600, height:360});
        return;
      } 
    }

    if (elements[1] == 'language_selector') {
      if (elements[2] == 'change') { Tr8n.UI.LanguageSelector.change(elements[3]); return; } 
      if (elements[2] == 'toggle_inline_translations') { Tr8n.UI.LanguageSelector.toggleInlineTranslations(); return; } 
    }

    if (elements[1] == 'language_case_map') {
      if (elements[2] == 'report') {
        Tr8n.UI.Translator.hide();
        Tr8n.UI.Lightbox.show('/tr8n/translator/lb_report?language_case_map_id=' + elements[3], {width:600, height:360});
        return;
      } 
    }

    if (elements[1] == 'lightbox') {
      if (elements[2] == 'resize') { Tr8n.UI.Lightbox.resize(elements[3]); return; } 
      if (elements[2] == 'hide') { Tr8n.UI.Lightbox.hide(); return;}
    }

    if (elements[1] == 'translator') {
      if (elements[2] == 'resize') { Tr8n.UI.Translator.resize(elements[3]); return; } 
      if (elements[2] == 'hide') { Tr8n.UI.Translator.hide(); return; }
    } 

    alert("Unknown message: " + msg);
  }

};
