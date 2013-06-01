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
  locale: null,
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

    Tr8n.log("Initializing Dispatcher...");

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

    if (typeof msg != 'object') {
        alert("Invalid message: " + msg + " to origin: " + origin);
        return;
    }

    msg['source'] = 'tr8n';
    msg_json = JSON.stringify(msg)

    if (local_domain == origin_domain) {
      if (msg['subject'] == 'proxy') { // for now same origin proxy messages should be reloaded
        window.parent.location.reload();
      } else {
        window.parent.Tr8n.onMessage(msg_json);
      }
    } else {
      if (parent.postMessage) {
        parent.postMessage(msg_json, origin);
      } else {
        alert("Failed to deliver a tr8n message: " + msg_json + " to origin: " + origin);
      }       
    }
  },

  onMessage:function(event) {
    var msg = null;
    if (typeof event == 'string') {
      msg = event;
    } else {
      msg = event.data;
    }

    // not tr8n - get out
    if (msg.indexOf('tr8n') == -1) return;

    try {
      msg = JSON.parse(msg)
    } catch(e) {
      Tr8n.log("Failed to parse message: " + msg)
      return;
    }

    var subject = msg['subject'];
    var action = msg['action'];

    if (subject == 'window') {
      if (action == 'reload') {
        window.location.reload();
        return;
      }
    }

    if (subject == 'proxy') {
      if (action == 'update_translations') {
        Tr8n.SDK.Proxy.updateMissingTranslationKeys(msg['translations']);
        return;
      }
    }

    if (subject == 'cookie') {
      if (action == 'set') {
        document.cookie = escape(msg['name']) + "=" + escape(msg['value']) + "; path=/";
        return;
      }
    }

    if (subject == 'translation') {
      if (action == 'report') {
        Tr8n.UI.Translator.hide();
        Tr8n.UI.Lightbox.show('/tr8n/translator/lb_report?translation_id=' + msg['id'], {width:600, height:360});
        return;
      } 
    }

    if (subject == 'language_selector') {
      if (action == 'change') { Tr8n.UI.LanguageSelector.change(msg['locale']); return; } 
      if (action == 'toggle_inline_translations') { Tr8n.UI.LanguageSelector.toggleInlineTranslations(); return; } 
    }

    if (subject == 'language_case_map') {
      if (action == 'report') {
        Tr8n.UI.Translator.hide();
        Tr8n.UI.Lightbox.show('/tr8n/translator/lb_report?language_case_map_id=' + msg['id'], {width:600, height:360});
        return;
      } 
    }

    if (subject == 'lightbox') {
      if (action == 'resize') { Tr8n.UI.Lightbox.resize(msg['height']); return; } 
      if (action == 'hide') { Tr8n.UI.Lightbox.hide(); return;}
    }

    if (subject == 'translator') {
      if (action == 'resize') { Tr8n.UI.Translator.resize(msg['height']); return; } 
      if (action == 'hide') { Tr8n.UI.Translator.hide(); return; }
    } 

    alert("Unknown message: " + subject + '.' + action);
  }

};
