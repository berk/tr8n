/****************************************************************************
  Copyright (c) 2010 Michael Berkovich, Ian McDaniel, Geni Inc

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

/****************************************************************************
**** Tr8n Generic Helper Functions
****************************************************************************/

document.createElement('tr8n');

var Tr8n = Tr8n || {
  element:function(element_id) {
    if (typeof element_id == 'string') return document.getElementById(element_id);
    return element_id;
  },
  value:function(element_id) {
    return Tr8n.element(element_id).value;
  }
};

/****************************************************************************
**** Tr8n Effects Helper Functions - Can be overloaded by JS frameworks
****************************************************************************/

Tr8n.Effects = {
  toggle: function(element_id) {
    if (Tr8n.element(element_id).style.display == "none")
      Tr8n.element(element_id).show();
    else
      Tr8n.element(element_id).hide();
  },
  hide: function(element_id) {
    Tr8n.element(element_id).style.display = "none";
  },
  show: function(element_id) {
    var style = (Tr8n.element(element_id).tagName == "SPAN") ? "inline" : "block";
    Tr8n.element(element_id).style.display = style;
  },
  blindUp: function(element_id) {
    Tr8n.Effects.hide(element_id);
  },
  blindDown: function(element_id) {
    Tr8n.Effects.show(element_id);
  },
  appear: function(element_id) {
    Tr8n.Effects.show(element_id);
  },
  fade: function(element_id) {
    Tr8n.Effects.hide(element_id);
  },
  submit: function(element_id) {
    Tr8n.element(element_id).submit();
  },
  focus: function(element_id) {
    Tr8n.element(element_id).focus();
  },
  scrollTo: function(element_id) {
    var theElement = Tr8n.element(element_id);
    var selectedPosX = 0;
    var selectedPosY = 0;
    while(theElement != null){
      selectedPosX += theElement.offsetLeft;
      selectedPosY += theElement.offsetTop;
      theElement = theElement.offsetParent;
    }
    window.scrollTo(selectedPosX,selectedPosY);
  }
}

/****************************************************************************
**** Tr8n Translator
****************************************************************************/

Tr8n.Translator = function(options) {
  var self = this;
  this.options = options;
  this.translation_key_id = null;
  this.suggestion_tokens = null;

  this.container                = document.createElement('div');
  this.container.className      = 'tr8n_translator';
  this.container.id             = 'tr8n_translator';
  this.container.style.display  = "none";

  document.body.appendChild(this.container);


  var event_type = Tr8n.Utils.isOpera() ? 'click' : 'contextmenu';

  Tr8n.Utils.addEvent(document, event_type, function(e) {
    if (Tr8n.Utils.isOpera() && !e.ctrlKey) return;

    var translatable_node = Tr8n.Utils.findElement(e, ".tr8n_translatable");
    var link_node = Tr8n.Utils.findElement(e, "a");

    if (translatable_node == null) return;

    if (link_node) {
      var temp_href = link_node.href;
      link_node.href='javascript:void(0);';
      setTimeout(function() {link_node.href = temp_href;}, 500);
    }

    if (e.stop) e.stop();
    if (e.preventDefault) e.preventDefault();
    if (e.stopPropagation) e.stopPropagation();

    self.show(translatable_node);
    return false;
  });
}

Tr8n.Translator.prototype = {
  hide: function() {
    this.container.style.display = "none";
    Tr8n.Utils.showFlash();
  },

  show: function(translatable_node) {
    var self = this;
    if (tr8nLanguageSelector) tr8nLanguageSelector.hide();
    if (tr8nLightbox) tr8nLightbox.hide();
    if (tr8nLanguageCaseManager) tr8nLanguageCaseManager.hide();
    Tr8n.Utils.hideFlash();

    var html          = "";
    var splash_screen = Tr8n.element('tr8n_splash_screen');

    if (splash_screen) {
      html += splash_screen.innerHTML;
    } else {
      html += "<div style='font-size:18px;text-align:center; margin:5px; padding:10px; background-color:black;'>";
      html += "  <img src='/tr8n/images/tr8n_logo.jpg' style='width:280px; vertical-align:middle;'>";
      html += "  <img src='/tr8n/images/loading3.gif' style='width:200px; height:20px; vertical-align:middle;'>";
      html += "</div>"
    }
    this.container.innerHTML = html;
    this.container.style.display  = "block";

    var stem                = {v:"top", h:"left",width:10, height:12};
    var stem_type           = "top_left";
    var target_dimensions   = {width:translatable_node.offsetWidth, height:translatable_node.offsetHeight};
    var target_position     = Tr8n.Utils.cumulativeOffset(translatable_node);
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
    this.translation_key_id       = translatable_node.getAttribute('translation_key_id');

    window.setTimeout(function() {
      Tr8n.Utils.update('tr8n_translator', '/tr8n/language/translator', {
        evalScripts: true,
        parameters: {
            translation_key_id: self.translation_key_id,
            stem_type: stem.v + "_" + stem.h,
            stem_offset: stem_offset
        }
      });
    }, 500);
  },

  reportTranslation: function(key, translation_id) {
    var msg = "Reporting this translation will remove it from this list and the translator will be put on a watch list. \n\nAre you sure you want to report this translation?";
    if (!confirm(msg)) return;
    this.voteOnTranslation(key, translation_id, -1000);
  },

  voteOnTranslation: function(key, translation_id, vote) {
    Tr8n.Effects.hide('tr8n_votes_for_' + translation_id);
    Tr8n.Effects.show('tr8n_spinner_for_' + translation_id);

    // the long version updates and reorders translations - used in translator and phrase list
    // the short version only updates the total results - used everywhere else
    if (Tr8n.element('tr8n_translator_votes_for_' + key)) {
      Tr8n.Utils.update('tr8n_translator_votes_for_' + key, '/tr8n/translations/vote', {
        parameters: {
          translation_id: translation_id,
          vote: vote
        },
        method: 'post'
      });
    } else {
      Tr8n.Utils.update('tr8n_votes_for_' + translation_id, '/tr8n/translations/vote', {
        parameters: {
          translation_id: translation_id,
          vote: vote,
          short_version: true
        },
        method: 'post',
        onComplete: function() {
          Tr8n.Effects.hide('tr8n_spinner_for_' + translation_id);
          Tr8n.Effects.show('tr8n_votes_for_' + translation_id);
        }
      });
    }
  },

  insertDecorationToken: function (token, txtarea_id) {
    txtarea_id = txtarea_id || 'tr8n_translator_translation_label';
    Tr8n.Utils.wrapText(txtarea_id, "[" + token + ": ", "]");
  },

  insertToken: function (token, txtarea_id) {
    txtarea_id = txtarea_id || 'tr8n_translator_translation_label';
    Tr8n.Utils.insertAtCaret(txtarea_id, "{" + token + "}");
  },

  switchTranslatorMode: function(translation_key_id, mode, source_url) {
    Tr8n.Utils.update('tr8n_translator_container', '/tr8n/language/translator', {
      parameters: {translation_key_id: translation_key_id, mode: mode, source_url: source_url},
      evalScripts: true
    });
  },

  submitTranslation: function() {
    Tr8n.Effects.hide('tr8n_translator_translation_container');
    Tr8n.Effects.hide('tr8n_translator_buttons_container');
    Tr8n.Effects.show('tr8n_translator_spinner');
    Tr8n.Effects.submit('tr8n_translator_form');
  },

  submitViewingUserDependency: function() {
    Tr8n.element('tr8n_translator_translation_has_dependencies').value = "true";
    this.submitTranslation();
  },

  submitDependencies: function() {
    Tr8n.Effects.hide('tr8n_translator_buttons_container');
    Tr8n.Effects.hide('tr8n_translator_dependencies_container');
    Tr8n.Effects.show('tr8n_translator_spinner');
    Tr8n.element('tr8n_translator_form').action = '/tr8n/translations/permutate';
    Tr8n.Effects.submit('tr8n_translator_form');
  },

  translate: function(label, callback, opts) {
    opts = opts || {}
    Tr8n.Utils.ajax('/tr8n/language/translate', {
      method: 'post',
      parameters: {
        label: label,
        description: opts.description,
        tokens: opts.tokens,
        options: opts.options,
        language: opts.language
      },
      onSuccess: function(r) {
        if(callback) callback(r.responseText);
      }
    });
  },

  translateBatch: function(phrases, callback) {
    Tr8n.Utils.ajax('/tr8n/language/translate', {
      method: 'post',
      parameters: {phrases: phrases},
      onSuccess: function(r) {
        if (callback) callback(r.responseText);
      }
    });
  },

  processSuggestedTranslation: function(response) {
    if (response == null ||response.data == null || response.data.translations==null || response.data.translations.length == 0) 
      return;
    var suggestion = response.data.translations[0].translatedText;
    if (this.suggestion_tokens) {
      var tokens = this.suggestion_tokens.split(",");
      this.suggestion_tokens = null;
      for (var i=0; i<tokens.length; i++) {
        suggestion = Tr8n.Utils.replaceAll(suggestion, "(" + i + ")", tokens[i]);
      }
    }  
    Tr8n.element("tr8n_translation_suggestion_" + this.translation_key_id).innerHTML = suggestion;
    Tr8n.element("tr8n_google_suggestion_container_" + this.translation_key_id).style.display = "block";
    var suggestion_section = Tr8n.element('tr8n_google_suggestion_section');
    if (suggestion_section) suggestion_section.style.display = "block";
  },
  
  suggestTranslation: function(translation_key_id, original, tokens, from_lang, to_lang) {
    if (Tr8n.google_api_key == null) return;
    
    this.suggestion_tokens = tokens;
    this.translation_key_id = translation_key_id;
    var new_script = document.createElement('script');
    new_script.type = 'text/javascript';
    var source_text = escape(original);
    var api_source = 'https://www.googleapis.com/language/translate/v2?key=' + Tr8n.google_api_key;
    var source = api_source + '&source=' + from_lang + '&target=' + to_lang + '&callback=tr8nTranslator.processSuggestedTranslation&q=' + source_text;
    new_script.src = source;
    document.getElementsByTagName('head')[0].appendChild(new_script);
  }

}

/****************************************************************************
**** Tr8n Language Case Manager
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
      html += "  <img src='/tr8n/images/tr8n_logo.jpg' style='width:280px; vertical-align:middle;'>";
      html += "  <img src='/tr8n/images/loading3.gif' style='width:200px; height:20px; vertical-align:middle;'>";
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


/****************************************************************************
**** Tr8n Language Selector
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
    window.location = "/tr8n/dashboard";
  },

  manageLanguage: function() {
    window.location = "/tr8n/language";
  },

  toggleInlineTranslations: function() {
    window.location = "/tr8n/language/switch?language_action=toggle_inline_mode&source_url=" + location;
  }
}



/****************************************************************************
**** Tr8n Lightbox
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

    this.container.innerHTML = "<div class='inner' style='font-size:18px;text-align:left;padding:10px;'><img src='/tr8n/images/spinner.gif' style='vertical-align:middle'> Loading...</div>";
    
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

/****************************************************************************
**** Tr8n Utils
****************************************************************************/

Tr8n.Utils = {

  hideFlash: function() {
		// alert("Hiding");
    var embeds = document.getElementsByTagName('embed');
    for(i = 0; i < embeds.length; i++) {
        embeds[i].style.visibility = 'hidden';
    } 
	},

  showFlash: function() {
    // alert("Showing");
    var embeds = document.getElementsByTagName('embed');
    for(i = 0; i < embeds.length; i++) {
        embeds[i].style.visibility = 'visible';
    } 
  },

  isOpera: function() {
    return /Opera/.test(navigator.userAgent);
  },

  addEvent: function(elm, evType, fn, useCapture) {
    useCapture = useCapture || false;
    if (elm.addEventListener) {
      elm.addEventListener(evType, fn, useCapture);
      return true;
    } else if (elm.attachEvent) {
      var r = elm.attachEvent('on' + evType, fn);
      return r;
    } else {
      elm['on' + evType] = fn;
    }
  },

  toQueryParams: function (obj) {
    if (typeof obj == 'undefined' || obj == null) return "";
    if (typeof obj == 'string') return obj;

    var qs = [];
    for(p in obj) {
        qs.push(p + "=" + encodeURIComponent(obj[p]))
    }
    return qs.join("&")
  },

  serializeForm: function(form) {
    var els = Tr8n.element(form).elements;
    var form_obj = {}
    for(i=0; i < els.length; i++) {
      if (els[i].type == 'checkbox' && !els[i].checked) continue;
      form_obj[els[i].name] = els[i].value;
    }
    return form_obj;
  },

  replaceAll: function(label, key, value) {
    while (label.indexOf(key) != -1) {
      label = label.replace(key, value);
    }
    return label;
  },

  getRequest: function() {
    var factories = [
      function() { return new ActiveXObject("Msxml2.XMLHTTP"); },
      function() { return new XMLHttpRequest(); },
      function() { return new ActiveXObject("Microsoft.XMLHTTP"); }
    ];
    for(var i = 0; i < factories.length; i++) {
      try {
        var request = factories[i]();
        if (request != null)  return request;
      } catch(e) {continue;}
    }
  },

  ajax: function(url, options) {
    options = options || {};
    options.parameters = Tr8n.Utils.toQueryParams(options.parameters);
    options.method = options.method || 'get';

    var self=this;
    if (options.method == 'get' && options.parameters != '') {
      url = url + (url.indexOf('?') == -1 ? '?' : '&') + options.parameters;
    }

    var request = this.getRequest();

    request.onreadystatechange = function() {
      if(request.readyState == 4) {
        if (request.status == 200) {
          if(options.onSuccess) options.onSuccess(request);
          if(options.onComplete) options.onComplete(request);
          if(options.evalScripts) self.evalScripts(request.responseText);
        } else {
          if(options.onFailure) options.onFailure(request)
          if(options.onComplete) options.onComplete(request)
        }
      }
    }

    request.open(options.method, url, true);
    request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    request.setRequestHeader('Accept', 'text/javascript, text/html, application/xml, text/xml, */*');
    request.send(options.parameters);
  },

  update: function(element_id, url, options) {
    options.onSuccess = function(response) {
        Tr8n.element(element_id).innerHTML = response.responseText;
    };
    Tr8n.Utils.ajax(url, options);
  },

  evalScripts: function(html){
    var script_re = '<script[^>]*>([\\S\\s]*?)<\/script>';
    var matchAll = new RegExp(script_re, 'img');
    var matchOne = new RegExp(script_re, 'im');
    var matches = html.match(matchAll) || [];
    for(var i=0,l=matches.length;i<l;i++){
      var script = (matches[i].match(matchOne) || ['', ''])[1];
      // console.info(script)
      // alert(script);
      eval(script);
    }
  },

  hasClassName:function(el, cls){
    var exp = new RegExp("(^|\\s)"+cls+"($|\\s)");
    return (el.className && exp.test(el.className))?true:false;
  },

  findElement: function (e,selector,el) {
    var event = e || window.event;
    var target = el || event.target || event.srcElement;
    if(target == document.body) return null;
    var condition = (selector.match(/^\./)) ? this.hasClassName(target,selector.replace(/^\./,'')) : (target.tagName.toLowerCase() == selector.toLowerCase());
    if(condition) {
      return target;
    } else {
      return this.findElement(e,selector,target.parentNode);
    }
  },

  cumulativeOffset: function(element) {
    var valueT = 0, valueL = 0;
    do {
      valueT += element.offsetTop  || 0;
      valueL += element.offsetLeft || 0;
      element = element.offsetParent;
    } while (element);
    return [valueL, valueT];
  },

  wrapText: function (obj_id, beginTag, endTag) {
    var obj = document.getElementById(obj_id);

    if (typeof obj.selectionStart == 'number') {
        // Mozilla, Opera, and other browsers
        var start = obj.selectionStart;
        var end   = obj.selectionEnd;
        obj.value = obj.value.substring(0, start) + beginTag + obj.value.substring(start, end) + endTag + obj.value.substring(end, obj.value.length);

    } else if(document.selection) {
        // Internet Explorer
        obj.focus();
        var range = document.selection.createRange();
        if(range.parentElement() != obj)
          return false;

        if(typeof range.text == 'string')
          document.selection.createRange().text = beginTag + range.text + endTag;
    } else
        obj.value += beginTag + " " + endTag;

    return true;
  },

  insertAtCaret: function (areaId, text) {
    var txtarea = document.getElementById(areaId);
    var scrollPos = txtarea.scrollTop;
    var strPos = 0;
    var br = ((txtarea.selectionStart || txtarea.selectionStart == '0') ? "ff" : (document.selection ? "ie" : false ) );

    if (br == "ie") {
      txtarea.focus();
      var range = document.selection.createRange();
      range.moveStart ('character', -txtarea.value.length);
      strPos = range.text.length;
    } else if (br == "ff")
      strPos = txtarea.selectionStart;

    var front = (txtarea.value).substring(0, strPos);
    var back = (txtarea.value).substring(strPos, txtarea.value.length);
    txtarea.value=front+text+back;

    strPos = strPos + text.length;
    if (br == "ie") {
      txtarea.focus();
      var range = document.selection.createRange();
      range.moveStart ('character', -txtarea.value.length);
      range.moveStart ('character', strPos);
      range.moveEnd ('character', 0); range.select();
    }  else if (br == "ff") {
      txtarea.selectionStart = strPos;
      txtarea.selectionEnd = strPos;
      txtarea.focus();
    }
    txtarea.scrollTop = scrollPos;
  },

  toggleKeyboards: function() {
    if(!VKI_attach) return;
    if (!this.keyboardMode) {
      this.keyboardMode = true;

      var elements = document.getElementsByTagName("input");
      for(i=0; i<elements.length; i++) {
        if (elements[i].type == "text") VKI_attach(elements[i]);
      }
      elements = document.getElementsByTagName("textarea");
      for(i=0; i<elements.length; i++) {
        VKI_attach(elements[i]);
      }
    } else {
      window.location.reload();
    }
  },

  displayShortcuts: function() {
    if (tr8nLightbox)
      tr8nLightbox.show('/tr8n/help/lb_shortcuts', {width:400, height:480});
  },

  displayStatistics: function() {
    if (tr8nLightbox)
      tr8nLightbox.show('/tr8n/help/lb_stats', {width:420, height:400});
  }

}

/****************************************************************************
**** Tr8n Initialization
****************************************************************************/

var tr8nTranslator = null;
var tr8nLanguageSelector = null;
var tr8nLightbox = null;
var tr8nLanguageCaseManager = null;

function initializeTr8n(opts) {
  var setup = function() {
    tr8nTranslator            = new Tr8n.Translator();
    tr8nLanguageSelector      = new Tr8n.LanguageSelector();
    tr8nLightbox              = new Tr8n.Lightbox();
    tr8nLanguageCaseManager   = new Tr8n.LanguageCaseManager();

    Tr8n.Utils.addEvent(document, "keyup", function(event) {
      if (event.keyCode == 27) { // Capture Esc key
        tr8nTranslator.hide();
        tr8nLanguageSelector.hide();
        tr8nLightbox.hide();
        tr8nLanguageCaseManager.hide();
      }
    });
  }

  Tr8n.Utils.addEvent(window, 'load', setup);
}
