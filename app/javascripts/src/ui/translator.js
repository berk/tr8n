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

    if (Tr8n.element("tr8n_translator_translation_label")) {
      Tr8n.element("tr8n_translator_translation_label").value = suggestion;
    }

    if (Tr8n.element("tr8n_translation_label_" + this.translation_key_id)) {
      Tr8n.element("tr8n_translation_label_" + this.translation_key_id).value = suggestion;
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