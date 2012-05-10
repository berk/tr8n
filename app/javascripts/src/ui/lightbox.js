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

Tr8n.UI.Lightbox = {
  
  options: {},  
  container: null,
  overlay: null,
  content_frame: null,

  init: function(options) {
    var self = this;
    this.options = options;
    this.container                = document.createElement('div');
    this.container.className      = 'tr8n_lightbox';
    this.container.id             = 'tr8n_lightbox';
    this.container.style.height   = "100px";
    this.container.style.display  = "none";

    this.overlay                  = document.createElement('div');
    this.overlay.className        = 'tr8n_lightbox_overlay';
    this.overlay.id               = 'tr8n_lightbox_overlay';
    this.overlay.style.display    = "none";

    this.content_frame              = document.createElement('iframe');
    this.content_frame.src          = 'about:blank';
    this.content_frame.style.border = '0px';
    this.content_frame.style.width  = '100%';
    this.container.appendChild(this.content_frame);

    document.body.appendChild(this.container);
    document.body.appendChild(this.overlay);
  },

  hide: function() {
    this.container.style.display = "none";
    this.overlay.style.display = "none";
    this.content_frame.src = 'about:blank';
    Tr8n.Utils.showFlash();
  },

  showHTML: function(content, opts) {
    var self = this;
    opts = opts || {};

    Tr8n.UI.Translator.hide();
    Tr8n.UI.LanguageSelector.hide();
    Tr8n.Utils.hideFlash();

    this.content_frame.src = 'about:blank';

    this.overlay.style.display  = "block";

    opts["width"] = opts["width"] || 700;
    opts["height"] = opts["height"] || 400;

    this.container.style.width        = opts["width"] + 'px';
    this.container.style.marginLeft   = -opts["width"]/2 + 'px';
    this.resize(opts["height"]);
    this.container.style.display      = "block";

    window.setTimeout(function() {
      var iframe_doc = self.content_frame.contentWindow.document;
      iframe_doc.body.setAttribute('style', 'background-color:white;padding:10px;margin:0px;font-size:10px;font-family:Arial;');

      Tr8n.Utils.insertCSS(Tr8n.host + "/assets/tr8n/tr8n.css", iframe_doc.body);
      Tr8n.Utils.insertScript(Tr8n.host + "/assets/tr8n/tr8n.js", function() {
        self.content_frame.contentWindow.Tr8n.host = Tr8n.host;
        self.content_frame.contentWindow.Tr8n.Logger.object_keys = Tr8n.Logger.object_keys;
        
        var div = document.createElement("div");
        div.innerHTML = content;
        iframe_doc.body.appendChild(div);
      }, iframe_doc.body);

    }, 1);
  },

  show: function(url, opts) {
    var self = this;
    opts = opts || {};

    Tr8n.UI.Translator.hide();
    Tr8n.UI.LanguageSelector.hide();
    Tr8n.Utils.hideFlash();

    this.content_frame.src = Tr8n.Utils.toUrl('/tr8n/help/splash_screen', {msg: opts['message'] || 'Loading...'});

    this.overlay.style.display  = "block";

    opts["width"] = opts["width"] || 700;
    var default_height = 100;

    this.container.style.width        = opts["width"] + 'px';
    this.container.style.marginLeft   = -opts["width"]/2 + 'px';
    this.resize(default_height);

    this.container.style.display      = "block";

    window.setTimeout(function() {
      self.content_frame.src = Tr8n.Utils.toUrl(url);
    }, 500);
  },

  resize: function(height) {
    this.container.style.height       = height + 'px';
    this.container.style.marginTop    = -height/2 + 'px';
    this.content_frame.style.height   = height + 'px';
  }
}
