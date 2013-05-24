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

Tr8n.SDK.TranslationKey = function(label, description, options) {
  this.id = null;                         // translation_key_id used by translator
  this.key = null;                        // unique translation key used to find elements 
  this.element_id = Tr8n.Utils.uuid();    // element id to be updated
  this.original = true;                   // by default assuming there are no translations in the cache
  this.label = label; 
  this.description = description;
  this.options = options;
  this.generateKey();
}

Tr8n.SDK.TranslationKey.prototype = {

  generateKey: function() {
    this.key = this.label + ";;;";
    if (this.description) this.key = this.key + this.description;
    this.key = MD5(this.key);
  },

  findFirstAcceptableTranslation: function(translations, token_values) {
    // check for a single translation case - no context rules
    if (translations['label']!=null) {
      // Tr8n.log('Found a single translation: ' + translations['label']);
      return translations;    
    }
  
    translations = translations['labels'];
    if (!translations) {
      Tr8n.error("Translations are in a weird form...");
      return null;
    }

    // Tr8n.log('Found translations: ' + translations.length);

    for (var i=0; i<translations.length; i++) {
      // Tr8n.log("Checking context rules for:" + translations[i]['label']);
      
      if (!translations[i]['context']) {
        // Tr8n.log("Translation has no context, using it by default");
        return translations[i];
      }
      var valid_context = true;

      for (var token in translations[i]['context']) {
        if (!valid_context) continue;
        var token_context = translations[i]['context'][token];
        var rule_name = Tr8n.SDK.Proxy.getLanguageRuleForType(token_context['type']);

        // Tr8n.log("Evaluating rule: " + rule_name);
        var rule = eval("new " + rule_name + "()");
        rule.definition = token_context;
        rule.options = {};
        valid_context = valid_context && rule.evaluate(token, token_values);
      }
      
      if (valid_context) {
        // Tr8n.log("Found valid translation: " + translations[i].label);
        return translations[i];
      } else {
        // Tr8n.log("The rules were not matched for: " + translations[i].label);
      }
    }
    
    // Tr8n.log('No acceptable ranslations found');
    return null;        
  },
  
  translate: function(language, token_values, options) {
    if (!this.label) {
      // Tr8n.log('Label must always be provided for the translate method');
      return '';
    }
    
    var translations = Tr8n.SDK.Proxy.translations;
    var translation_key = translations[this.key];

    if (translation_key) {
       // Tr8n.log("Translate: found translation key: " + JSON.stringify(translation_key));
      // Tr8n.log("Found translations, evaluating rules...");      
      
      this.id = translation_key.id;
      this.original = translation_key.original;
      var translation = this.findFirstAcceptableTranslation(translation_key, token_values);

      if (translation) {
        // Tr8n.log("Found a valid match: " + translation.label);      
        return this.substituteTokens(translation['label'], token_values, options);
      } else {
        // Tr8n.log("No valid match found, using default language");      
        return this.substituteTokens(this.label, token_values, options);
      }
      
    } else {
      // Tr8n.log("Translation not found, using default language");      
    }

    Tr8n.SDK.Proxy.registerMissingTranslationKey(this, token_values, options);
    // Tr8n.log('No translation found. Using default...');
    return this.substituteTokens(this.label, token_values, options);    
  },
  
  registerDataTokens: function(label) {
    this.data_tokens = [];
    this.data_tokens = this.data_tokens.concat(Tr8n.SDK.Tokens.DataToken.parse(label, {}));
    this.data_tokens = this.data_tokens.concat(Tr8n.SDK.Tokens.TransformToken.parse(label, {}));
  },

  registerDecorationTokens: function(label) {
    this.decoration_tokens = [];
    this.decoration_tokens = this.decoration_tokens.concat(Tr8n.SDK.Tokens.DecorationToken.parse(label, {}));
  },

  substituteTokens: function(label, token_values, options) {
    this.registerDataTokens(label);
    if (!this.data_tokens) return this.decorateLabel(label, options);
    for (var i = 0; i < this.data_tokens.length; i++) {
      label = this.data_tokens[i].substitute(label, token_values || {});
    }
    
    this.registerDecorationTokens(label);
    if (!this.decoration_tokens) return label;
    for (var i = 0; i < this.decoration_tokens.length; i++) {
      label = this.decoration_tokens[i].substitute(label, token_values || {});
    }
    
    return this.decorateLabel(label, options);
  },
  
  decorationClasses: function() {
    var klasses = [];
    klasses.push('tr8n_translatable');
    if (Tr8n.SDK.Proxy.inline_translations_enabled) {
      if (this.original)
        klasses.push('tr8n_not_translated');
      else  
        klasses.push('tr8n_translated');
    }
    return klasses.join(' ');
  },

  decorateLabel: function(label, options) {
    options = options || {};
    if (options['skip_decorations'])
      return label;
      
    html = [];
    html.push("<tr8n ");
    html.push(" id='" + this.element_id + "' ");
    
    if (this.id) 
      html.push(" translation_key_id='" + this.id + "' ");

    html.push(" class='" + this.decorationClasses() + "'");
    html.push(">");
    html.push(label);
    html.push("</tr8n>");

    return html.join("");
  }
}
