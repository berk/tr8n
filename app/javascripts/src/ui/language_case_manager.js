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

Tr8n.LanguageCaseManager = function(options) {
  var self = this;
  this.options = options;
  this.case_key = null;

  this.container                = document.createElement('div');
  this.container.className      = 'tr8n_language_case_manager';
  this.container.id             = 'tr8n_language_case_manager';
  this.container.style.display  = "none";

  document.body.appendChild(this.container)

  var event_type = Tr8n.Utils.isOpera() ? 'click' : 'contextmenu';

  Tr8n.Utils.addEvent(document, event_type, function(e) {
    if (Tr8n.Utils.isOpera() && !e.ctrlKey) return;

    var case_node = Tr8n.Utils.findElement(e, ".tr8n_language_case");
    var link_node = Tr8n.Utils.findElement(e, "a");

    if (case_node == null) return;

    if (link_node) {
      var temp_href = link_node.href;
      link_node.href='javascript:void(0);';
      setTimeout(function() {link_node.href = temp_href;}, 500);
    }

    if (e.stop) e.stop();
    if (e.preventDefault) e.preventDefault();
    if (e.stopPropagation) e.stopPropagation();

    self.show(case_node);
  });
}

Tr8n.LanguageCaseManager.prototype = {
  hide: function() {
    this.container.style.display = "none";
    Tr8n.Utils.showFlash();
  },

  show: function(case_node) {
    var self = this;
    if (tr8nLanguageSelector) tr8nLanguageSelector.hide();
    if (tr8nLightbox) tr8nLightbox.hide();
    if (tr8nTranslator) tr8nTranslator.hide();
    Tr8n.Utils.hideFlash();

    var html          = "";
    var splash_screen = Tr8n.element('tr8n_splash_screen');

    if (splash_screen) {
      html += splash_screen.innerHTML;
    } else {
      html += "<div style='font-size:18px;text-align:center; margin:5px; padding:10px; background-color:black;'>";
      html += "  <img src='/assets/tr8n/tr8n_logo.jpg' style='width:280px; vertical-align:middle;'>";
      html += "  <img src='/assets/tr8n/loading3.gif' style='width:200px; height:20px; vertical-align:middle;'>";
      html += "</div>"
    }
    this.container.innerHTML = html;
    this.container.style.display  = "block";

    var stem                = {v:"top", h:"left",width:10, height:12};
    var stem_type           = "top_left";
    var target_dimensions   = {width:case_node.offsetWidth, height:case_node.offsetHeight};
    var target_position     = Tr8n.Utils.cumulativeOffset(case_node);
    var container_position  = {
      left: (target_position[0] + 'px'),
      top : (target_position[1] + target_dimensions.height + stem.height + 'px')
    }

    var stem_offset         = target_dimensions.width/2;
    var scroll_buffer       = 100;
    var scroll_height       = target_position[1] - scroll_buffer;

    if (window.innerWidth < target_position[0] + target_dimensions.width + window.innerWidth/2) {
      container_position.left = target_position[0] + target_dimensions.width - this.container.offsetWidth + "px";
      stem_offset = target_dimensions.width/2;
      stem.h = "right";
    }

    window.scrollTo(target_position[0], scroll_height);
    this.container.style.left     = container_position.left;
    this.container.style.top      = container_position.top;
    this.case_id                  = case_node.getAttribute('case_id');
    this.rule_id                  = case_node.getAttribute('rule_id');
    this.case_key                 = case_node.getAttribute('case_key');

    window.setTimeout(function() {
      Tr8n.Utils.update('tr8n_language_case_manager', '/tr8n/language_cases/manager', {
        evalScripts: true,
        parameters: {
            case_id: self.case_id,
            rule_id: self.rule_id,
            case_key: self.case_key,
            stem_type: stem.v + "_" + stem.h,
            stem_offset: stem_offset
        }
      });
    }, 500);
  },

  switchToCaseMapMode: function() {
    Tr8n.Effects.hide('tr8n_language_case_container');
    Tr8n.Effects.show('tr8n_language_case_exception_container');
  },

  switchCaseMapMode: function(mode) {
    var self = this;
    Tr8n.Utils.update('tr8n_language_cases_form', '/tr8n/language_cases/switch_manager_mode', {
      evalScripts: true,
      parameters: {mode: mode, case_key: self.case_key}
    });
  },

  reportCaseMap: function(map_id) {
    var msg = "Reporting these values will remove them from the system and the translator will be put on a watch list. \n\nAre you sure you want to report these values?";
    if (!confirm(msg)) return;

    Tr8n.element("tr8n_language_case_form").action = "/tr8n/language_cases/report_value_map";
    Tr8n.Effects.hide('tr8n_language_case_exception_container');
    Tr8n.Effects.show('tr8n_language_case_report_spinner');
    Tr8n.Effects.submit('tr8n_language_case_form');
  },

  submitCaseMap: function() {
    Tr8n.Effects.hide('tr8n_language_case_exception_container');
    Tr8n.Effects.show('tr8n_language_case_submit_spinner');
    Tr8n.Effects.submit('tr8n_language_case_form');
  }
}