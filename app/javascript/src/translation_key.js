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

Tr8n.Proxy.TranslationKey = function(label, description, options) {
  this.label = label;
  this.description = description;
  this.options = options;
  this.generateKey();
}

Tr8n.Proxy.TranslationKey.prototype = {
  getProxy: function() {
    return this.options['proxy'];
  },
  getLogger: function() {
    return this.getProxy().logger;
  },
  findFirstAcceptableTranslation: function(translations, token_values) {
    // check for a single translation case - no context rules
    if (translations['label']!=null) {
      this.getLogger().debug('Found a single translation: ' + translations['label']);
      return translations;    
    }
  
    translations = translations['labels'];
    if (!translations) {
      this.getLogger().error("Translations are in a weird form...");
      return null;
    }

    this.getLogger().debug('Found translations: ' + translations.length);
    for (var i=0; i<translations.length; i++) {
      this.getLogger().debug("Checking context rules for:" + translations[i]['label']);
      
      if (!translations[i]['context']) {
        this.getLogger().debug("Translation has no context, using it by default");
        return translations[i];
      }
      var valid_context = true;

      for (var token in translations[i]['context']) {
        if (!valid_context) continue;
        var token_context = translations[i]['context'][token];
        var rule_name = this.getProxy().getLanguageRuleForType(token_context['type']);
        this.getLogger().debug("Evaluating rule: " + rule_name);
        var options = {'proxy': this.getProxy()};
        var rule = eval("new " + rule_name + "()");
        rule.definition = token_context;
        rule.options = options;
        valid_context = valid_context && rule.evaluate(token, token_values);
      }
      
      if (valid_context) {
        this.getLogger().debug("Found valid translation: " + translations[i].label);
        return translations[i];
      } else {
        this.getLogger().debug("The rules were not matched for: " + translations[i].label);
      }
    }
    
    this.getLogger().debug('No acceptable ranslations found');
    return null;        
  },
  
  translate: function(language, token_values, options) {
    if (!this.label) {
      this.getLogger().error('Label must always be provided for the translate method');
      return '';
    }
    
    var translations = this.getProxy().getTranslations();
    var translation_key = translations[this.key];
        
    if (translation_key) {
      this.getLogger().debug("Found translations, evaluating rules...");      
      
      this.id = translation_key.id;
      this.original = translation_key.original;
      var translation = this.findFirstAcceptableTranslation(translation_key, token_values);

      if (translation) {
        this.getLogger().debug("Found a valid match: " + translation.label);      
        return this.substituteTokens(translation['label'], token_values, options);
      } else {
        this.getLogger().debug("No valid match found, using default language");      
        return this.substituteTokens(this.label, token_values, options);
      }
      
    } else {
      this.getLogger().debug("Translation not found, using default language");      
    }

    this.getProxy().registerMissingTranslationKey(this, token_values, options);
    this.getLogger().debug('No translation found. Using default...');
    return this.substituteTokens(this.label, token_values, options);    
  },
  
  generateKey: function() {
    this.key = this.label + ";;;";
    if (this.description) this.key = this.key + this.description;
       
    this.getLogger().debug('Preparing label signature: ' + this.key);
    this.key = MD5(this.key);
    this.getLogger().debug('Label signature: ' + this.key);
  },
  
  registerDataTokens: function(label) {
    this.data_tokens = [];
    this.data_tokens = this.data_tokens.concat(Tr8n.Proxy.DataToken.parse(label, {'key': this, 'proxy':this.getProxy()}));
    this.data_tokens = this.data_tokens.concat(Tr8n.Proxy.TransformToken.parse(label, {'key': this, 'proxy':this.getProxy()}));
  },

  registerDecorationTokens: function(label) {
    this.decoration_tokens = [];
    this.decoration_tokens = this.decoration_tokens.concat(Tr8n.Proxy.DecorationToken.parse(label, {'key': this, 'proxy':this.getProxy()}));
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
  
  decorateLabel: function(label, options){
    options = options || {};
    if (options['skip_decorations'])
      return label;
      
    html = [];
    html.push("<tr8n ");
    
    if (this.id) 
      html.push(" translation_key_id='" + this.id + "' ");
      
    if (this.key) 
      html.push(" id='" + this.key + "' ");
  
    var klasses = ['tr8n_translatable'];
    
    if (this.original)
      klasses.push('tr8n_not_translated');
    else  
      klasses.push('tr8n_translated');

    if (this.getProxy().inline_translations_enabled && this.id)
      html.push(" class='" + klasses.join(' ') + "'");
      
    html.push(">");
    html.push(label);
    html.push("</tr8n>");
    return html.join("");
  }
}
