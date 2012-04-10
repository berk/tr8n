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

Tr8n.Proxy = function(options) {
  var self = this;
  this.options = options;
  this.options['url'] = this.options['url'] || '/tr8n/api/v1/language/translate'; 
  this.options['scheduler_interval'] = this.options['scheduler_interval'] || 20000; 
  this.logger_enabled = false;
  this.missing_translations_locked = false;
  this.inline_translations_enabled = this.options['enable_inline_translations'];
  this.logger = new Tr8n.Proxy.Logger({
    'proxy': self,
    'element_id': options['logger_element_id'] || 'tr8n_debugger'
  });
        
  this.language = new Tr8n.Proxy.Language({
    'proxy': self
  });
  
  this.initTranslations();
  this.runScheduledTasks();
}

Tr8n.Proxy.prototype = {
  log: function(msg) {
    this.logger.debug(msg);
  },
  logSettings: function() {
    this.logger.clear();
    this.logger.logObject(this.options);
  },
  logTranslations: function() {
    this.logger.clear();
    this.translations = this.translations || {};
    this.logger.logObject(this.translations);
  },
  logMissingTranslations: function() {
    this.logger.clear();
    this.missing_translation_keys = this.missing_translation_keys || {};
    this.logger.logObject(this.missing_translation_keys);
  },
  disableLogger: function() {
    this.logger_enabled = false;
  },
  enableLogger: function() {
    this.logger_enabled = true;
  },
  debug: function(msg) {
    this.logger.debug(msg);
  },
  error: function(msg) {
    this.logger.error(msg);
  },
  translate: function(label, description, tokens, options) {
    if (!label) return "";
    description = description || "";
    tokens = tokens || {};
    options = options || {};
    return this.language.translate(label, description, tokens, options);
  },
  tr: function(label, description, tokens, options) {
    return this.translate(label, description, tokens, options);
  },
  trl: function(label, description, tokens, options) {
    options = options || {};
    options['skip_decorations'] = true;
    return this.translate(label, description, tokens, options);
  },
  getTranslations: function() {
    this.translations = this.translations || {};
    return this.translations;
  },
  getDecorationFor: function(decoration_name) {
    if (!this.options['default_decorations'])
      return null;
    return this.options['default_decorations'][decoration_name];
  },
  getLanguageRuleForType: function(rule_type) {
    // modify this section to add more rules
    if (rule_type == 'number')        return 'Tr8n.Proxy.NumericRule';
    if (rule_type == 'gender')        return 'Tr8n.Proxy.GenderRule';
    if (rule_type == 'date')          return 'Tr8n.Proxy.DateRule';
    if (rule_type == 'list')          return 'Tr8n.Proxy.ListRule';
    if (rule_type == 'gender_list')   return 'Tr8n.Proxy.GenderListRule';
    return null;    
  },
  getLanguageRuleForTokenSuffix: function(token_suffix) {
    if (!this.options['rules']) return null;
    
    for (rule_type in this.options['rules']) {
      var suffixes = this.options['rules'][rule_type]['token_suffixes'];
      if (!suffixes) continue;
      
      if (Tr8n.Utils.indexOf(suffixes, token_suffix) != -1 )
         return this.getLanguageRuleForType(rule_type);     
    }
    return null;    
  },

  registerTranslationKeys: function(translations) {
    this.log("Found " + translations.length + " registered phrases");
    for (i = 0; i < translations.length; i++) {
       var translation_key = translations[i];
       this.log("Registering " + translation_key['key']);
       this.translations[translation_key['key']] = translation_key;
    }
  },

  initTranslations: function(forced) {
    if (!forced && this.translations) return;
    
    this.translations = {};

    // Check for page variable to load translations from, if variable was provided
    if (this.options['translations_cache_id']) {
      this.log("Registering page translations from translations cache...");
      this.updateTranslations(eval(this.options['translations_cache_id']));
    }

    var self = this;

    // Optionally, fetch translations from the server
    if (this.options['fetch_translations_on_init']) {
      this.log("Fetching translations from the server...");
      Tr8n.Utils.ajax(this.options['url'], {
        method: 'get',
        parameters: {'batch': true, 'source': self.options['default_source']},
        onSuccess: function(response) {
          self.log("Received response from the server");
          self.log(response.responseText);
          self.updateTranslations(eval("[" + response.responseText + "]")[0]['phrases']);
        }
      }); 
    }
  },

  updateTranslations: function(new_translations) {
    this.translations = this.translations || {};
    this.log("Updating page translations...");
    this.registerTranslationKeys(new_translations);
  },
    
  registerMissingTranslationKey: function(translation_key, token_values, options) {
    this.missing_translation_keys = this.missing_translation_keys || {};
    if (!this.missing_translation_keys[translation_key.key]) {
      this.log('Adding missing translation to the queue: ' + translation_key.key);
      this.missing_translation_keys[translation_key.key] = {translation_key: translation_key, token_values: token_values, options:options};
    }
  },
  submitMissingTranslationKeys: function() {
    if (this.missing_translations_locked) {
      this.log('Missing translations are being processed, postponding registration task.');
      return;
    }
      
    this.missing_translation_keys = this.missing_translation_keys || {};
    
    var phrases = "[";
    for (var key in this.missing_translation_keys) {
      var translation_key = this.missing_translation_keys[key].translation_key;
      if (translation_key == null) continue;
      if (phrases!="[") phrases = phrases + ",";
      phrases = phrases + "{";
      phrases = phrases + '"label":"' + translation_key.label + '", ';
      phrases = phrases + '"description":"' + translation_key.description + '"';
      phrases = phrases + "}";
    }
    phrases = phrases + "]";
    
    if (phrases == '[]') {
//      this.log('No missing translation keys to submit...');
      return;
    }
    
    var self = this;
    this.debug('Submitting missing translation keys: ' + phrases);
    Tr8n.Utils.ajax(this.options['url'], {
      method: 'put',
      parameters: {'source': self.options['default_source'], 'phrases': phrases},
      onSuccess: function(response) {
        self.log("Received response from the server");
        self.log(response.responseText);
        self.updateMissingTranslationKeys(eval("[" + response.responseText + "]")[0]['phrases']);
      }
    }); 
  },
  
  updateMissingTranslationKeys: function(translations) {
    this.missing_translations_locked = true;
    this.log("Received " + translations.length + " registered phrases...");
    for (i = 0; i < translations.length; i++) {
       var translation_key_data = translations[i];
       
       this.log("Registering new key " + translation_key_data.key);
       this.translations[translation_key_data.key] = translation_key_data;
       var missing_key_data = this.missing_translation_keys[translation_key_data.key];
       var tr8nElement = Tr8n.element(translation_key_data.key);
      
       if (tr8nElement && missing_key_data.translation_key) {
         tr8nElement.setAttribute('translation_key_id', translation_key_data['id']);
         tr8nElement.innerHTML = missing_key_data.translation_key.translate(this.language, missing_key_data.token_values);
       }
       
       delete this.missing_translation_keys[missing_key_data.translation_key.key];
    }
    this.missing_translations_locked = false;
  },  

  runScheduledTasks: function() {
    var self = this;
    
//    this.log("Running scheduled tasks...");
    this.submitMissingTranslationKeys();
    
    window.setTimeout(function() {
      self.runScheduledTasks();
    }, this.options['scheduler_interval']);
  },

  initTml: function() {
    var tree_walker = document.createTreeWalker(document.body, NodeFilter.SHOW_ALL, function(node) {
      if (node.nodeName == 'TML:LABEL') {
        return NodeFilter.FILTER_ACCEPT;
      } else {
        return NodeFilter.FILTER_SKIP;
      }
    }, false);

    while (tree_walker.nextNode()) {
      new Tr8n.Tml.Label(tree_walker.currentNode, this).translate();
    }
  }
}