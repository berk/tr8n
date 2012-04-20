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

Tr8n.Lightbox = function() {
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
}

Tr8n.Lightbox.prototype = {

  hide: function() {
    this.container.style.display = "none";
    this.overlay.style.display = "none";
    Tr8n.Utils.showFlash();
  },

  show: function(url, opts) {
    var self = this;
    opts = opts || {};

    if(tr8nTranslator) tr8nTranslator.hide();
    if(tr8nLanguageSelector) tr8nLanguageSelector.hide();
    Tr8n.Utils.hideFlash();

    this.content_frame.src = '/tr8n/help/splash_screen';

    this.overlay.style.display  = "block";

    opts["width"] = opts["width"] || 700;
    var default_height = 100;

    this.container.style.width        = opts["width"] + 'px';
    this.container.style.marginLeft   = -opts["width"]/2 + 'px';
    this.resize(default_height);

    this.container.style.display      = "block";

    window.setTimeout(function() {
      url += ((url.indexOf('?') == -1) ? '?' : '&');
      url += 'origin=' + escape(window.location);
      self.content_frame.src = url;
    }, 500);
  },

  resize: function(height) {
    this.container.style.height       = height + 'px';
    this.container.style.marginTop    = -height/2 + 'px';
    this.content_frame.style.height   = height + 'px';
  }
}
