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

Tr8n.LanguageSelector = function(options) {
  this.options = options || {};
  this.keyboardMode = false;
  this.loaded = false;

  this.container                = document.createElement('div');
  this.container.className      = 'tr8n_language_selector';
  this.container.id             = 'tr8n_language_selector';
  this.container.style.display  = "none";

  document.body.appendChild(this.container);
}

Tr8n.LanguageSelector.prototype = {

  toggle: function() {
    if (this.container.style.display == "none") {
      this.show();
    } else {
      this.hide();
    }
  },

  hide: function() {
    this.container.style.display = "none";
    Tr8n.Utils.showFlash();
  },

  show: function() {
    var self = this;
    if (tr8nTranslator) tr8nTranslator.hide();
    if (tr8nLightbox) tr8nLightbox.hide();
    if (tr8nLanguageCaseManager) tr8nLanguageCaseManager.hide();
    Tr8n.Utils.hideFlash();

    var splash_screen = Tr8n.element('tr8n_splash_screen');

    if (!this.loaded) {
      var html = "";
      if (splash_screen) {
        html += splash_screen.innerHTML;
      } else {
        html += "<div style='font-size:18px;text-align:center; margin:5px; padding:10px; background-color:black;'>";
        html += "  <img src='/tr8n/images/tr8n_logo.jpg' style='width:280px; vertical-align:middle;'>";
        html += "  <img src='/tr8n/images/loading3.gif' style='width:200px; height:20px; vertical-align:middle;'>";
        html += "</div>";
      }
      this.container.innerHTML = html;
    }
    this.container.style.display  = "block";

    var trigger             = Tr8n.element('tr8n_language_selector_trigger');
    var trigger_position    = Tr8n.Utils.cumulativeOffset(trigger);
    var container_position  = {
      left: trigger_position[0] + trigger.offsetWidth - this.container.offsetWidth + 'px',
      top: trigger_position[1] + trigger.offsetHeight + 4 + 'px'
    }

//    if (trigger_position[0] < window.innerWidth/2 ) {
//      this.container.offsetLeft = trigger_position[0] + 'px';
//    }

    this.container.style.left     = container_position.left;
    this.container.style.top      = container_position.top;

    if (!this.loaded) {
      window.setTimeout(function() {
        Tr8n.Utils.update('tr8n_language_selector', '/tr8n/language/select', {
          evalScripts: true
        })
      }, 100);
    }

    this.loaded = true;
  },

  removeLanguage: function(language_id) {
    Tr8n.Utils.update('tr8n_language_lists', '/tr8n/language/lists', {
      parameters: {language_action: "remove", language_id: language_id},
      method: 'post'
    });
  },

  enableInlineTranslations: function() {
    window.location = "/tr8n/language/switch?language_action=enable_inline_mode&source_url=" + location;
  },

  disableInlineTranslations: function() {
    window.location = "/tr8n/language/switch?language_action=disable_inline_mode&source_url=" + location;
  },

  showDashboard: function() {
    window.location = "/tr8n/translator/dashboard";
  },

  manageLanguage: function() {
    window.location = "/tr8n/language";
  },

  toggleInlineTranslations: function() {
    window.location = "/tr8n/language/switch?language_action=toggle_inline_mode&source_url=" + location;
  }
}