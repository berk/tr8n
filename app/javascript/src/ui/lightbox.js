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
  this.container.style.display  = "none";

  this.overlay                  = document.createElement('div');
  this.overlay.className        = 'tr8n_lightbox_overlay';
  this.overlay.id               = 'tr8n_lightbox_overlay';
  this.overlay.style.display    = "none";

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
    if(tr8nLanguageCaseManager) tr8nLanguageCaseManager.hide();
    Tr8n.Utils.hideFlash();

    this.container.innerHTML = "<div class='inner'><div class='bd'><img src='/assets/tr8n/spinner.gif' style='vertical-align:middle'> Loading...</div></div>";
    
    this.overlay.style.display  = "block";

    opts["width"] = opts["width"] || 700;
    opts["height"] = opts["height"] || 520;

    this.container.style.width  = opts["width"] + 'px';
    this.container.style.height = opts["height"] + 'px';
    this.container.style.marginLeft  = -opts["width"]/2 + 'px';
    this.container.style.marginTop  = -opts["height"]/2 + 'px';
    this.container.style.display  = "block";

    Tr8n.Utils.update('tr8n_lightbox', url, {
      evalScripts: true
    });
  }
}
