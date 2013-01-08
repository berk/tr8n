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

Tr8n.Translation = {

  suggestion_key_id: null,  
  suggestion_tokens: [],

  report: function(translation_key, translation_id) {
    // TODO: wrap in trl
    var msg = "Reporting this translation will remove it from this list and the translator will be put on a watch list. \n\nAre you sure you want to report this translation?";
    if (!confirm(msg)) return;
    Tr8n.TranslatorHelper.vote(translation_key, translation_id, -1000);
  },

  vote: function(translation_key_id, translation_id, vote) {
    Tr8n.Effects.hide('tr8n_votes_for_' + translation_id);
    Tr8n.Effects.show('tr8n_spinner_for_' + translation_id);

    // the long version updates and reorders translations - used in translator and phrase list
    // the short version only updates the total results - used everywhere else
    if (Tr8n.element('tr8n_translator_votes_for_' + translation_key_id)) {
      Tr8n.Utils.update('tr8n_translator_votes_for_' + translation_key_id, '/tr8n/translations/vote', {
        parameters: { translation_id: translation_id, vote: vote },
        method: 'post'
      });
    } else {
      Tr8n.Utils.update('tr8n_votes_for_' + translation_id, '/tr8n/translations/vote', {
        parameters: { translation_id: translation_id, vote: vote, short_version: true },
        method: 'post',
        onComplete: function() {
          Tr8n.Effects.hide('tr8n_spinner_for_' + translation_id);
          Tr8n.Effects.show('tr8n_votes_for_' + translation_id);
        }
      });
    }
  },

  insertDecorationToken: function(token, text_area_id) {
    text_area_id = text_area_id || 'tr8n_translator_translation_label';
    Tr8n.Utils.wrapText(text_area_id, "[" + token + ": ", "]");
  },

  insertToken: function(token, text_area_id) {
    text_area_id = text_area_id || 'tr8n_translator_translation_label';
    Tr8n.Utils.insertAtCaret(text_area_id, "{" + token + "}");
  },

  submit: function() {
    Tr8n.Effects.hide('tr8n_translator_translation_container');
    Tr8n.Effects.hide('tr8n_translator_buttons_container');
    Tr8n.Effects.show('tr8n_translator_spinner');
    Tr8n.Effects.submit('tr8n_translator_form');
  },

  lock: function() {
    Tr8n.Effects.hide('tr8n_translator_translations_container');
    Tr8n.Effects.hide('tr8n_translator_footer_container');
    Tr8n.Effects.show('tr8n_translator_spinner');
    Tr8n.Effects.submit('tr8n_translator_form');
  },

  submitWithDependencies: function() {
    Tr8n.Effects.hide('tr8n_translator_buttons_container');
    Tr8n.Effects.hide('tr8n_translator_dependencies_container');
    Tr8n.Effects.show('tr8n_translator_spinner');
    Tr8n.element('tr8n_translator_form').action = '/tr8n/translations/lock';
    Tr8n.Effects.submit('tr8n_translator_form');
  },

  suggest: function(translation_key_id, original, tokens, from_lang, to_lang) {
    if (Tr8n.google_api_key == null) return;
    
    this.suggestion_tokens = tokens;
    this.suggestion_key_id = translation_key_id;

    var new_script = document.createElement('script');
    new_script.type = 'text/javascript';
    var source_text = escape(original);
    var api_source = 'https://www.googleapis.com/language/translate/v2?key=' + Tr8n.google_api_key;
    var source = api_source + '&source=' + from_lang + '&target=' + to_lang + '&callback=Tr8n.Translation.showSuggestion&q=' + source_text;
    new_script.src = source;
    document.getElementsByTagName('head')[0].appendChild(new_script);
  },

  showSuggestion: function(response) {
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

    Tr8n.element("tr8n_translation_suggestion_" + this.suggestion_key_id).innerHTML = suggestion;

    if (Tr8n.element('tr8n_translator_translation_label')) {
      Tr8n.element('tr8n_translator_translation_label').value = suggestion;  
    }

    Tr8n.element("tr8n_google_suggestion_container_" + this.suggestion_key_id).style.display = "block";
    var suggestion_section = Tr8n.element('tr8n_google_suggestion_section');
    if (suggestion_section) suggestion_section.style.display = "block";
  }
  
}