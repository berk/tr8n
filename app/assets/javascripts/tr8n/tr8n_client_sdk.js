/****************************************************************************
  Copyright (c) 2010-2012 Michael Berkovich

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
****
**** This JavaScript Client SDK supports English as the native site language.
**** If your site native language is other than English, please read
**** the integration guide for details on how to make the SDK work with 
**** your native language.
****
****************************************************************************/

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
**** Tr8n Proxy
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
      
      if (Tr8n.Proxy.Utils.indexOf(suffixes, token_suffix) != -1 )
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
      Tr8n.Proxy.Utils.ajax(this.options['url'], {
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
    Tr8n.Proxy.Utils.ajax(this.options['url'], {
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
         tr8nElement.innerHTML = missing_key_data.translation_key.translate(this.language, missing_key_data.token_values, {skip_decorations:true});
         tr8nElement.setAttribute('translation_key_id', translation_key_data['id']);
         if (this.inline_translations_enabled) {
            tr8nElement.className = 'tr8n_translatable tr8n_not_translated';
         }
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
}

/****************************************************************************
**** Tr8n Proxy Language
****************************************************************************/

Tr8n.Proxy.Language = function(options) {
  this.options = options;
}

Tr8n.Proxy.Language.prototype = {
  getProxy: function() {
    return this.options['proxy'];
  },
  getLogger: function() {
    return this.getProxy().logger;
  },
  translate: function(label, description, tokens, options) {
    return (new Tr8n.Proxy.TranslationKey(label, description, {'proxy': this.getProxy()}).translate(this, tokens, options));
  }
}

/****************************************************************************
**** Tr8n Proxy TranslationKey
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
        var rule = eval("new " + rule_name + "(token_context, options)");
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

/****************************************************************************
**** Tr8n Proxy LanguageRule
****************************************************************************/

Tr8n.Proxy.LanguageRule = function() {}

Tr8n.Proxy.LanguageRule.prototype = {
  getProxy: function() {
    return this.options['proxy'];
  },
  getLogger: function() {
    return this.getProxy().logger;
  },
  getTokenValue: function(token_name, token_values) {
    var object = token_values[token_name];
    if (object == null) { 
      this.getLogger().error("Invalid token value for token: " + token_name);
    }
    
    return object;    
  },
  getDefinitionDescription: function() {
    var result = [];
    for (var key in this.definition)
      result.push(key + ": '" + this.definition[key] + "'");
    return "{" + result.join(", ") + "}";   
  },
  sanitizeArrayValue: function(value) {
    var results = [];
    var arr = value.split(',');
    for (var index = 0; index < arr.length; index++) {
      results.push(Tr8n.Proxy.Utils.trim(arr[index]));
    }   
    return results;
  }
}

/****************************************************************************
**** Tr8n Proxy NumericRule
****************************************************************************/

Tr8n.Proxy.NumericRule = function(definition, options) {
  this.definition = definition;
  this.options = options;
}

Tr8n.Proxy.NumericRule.prototype = new Tr8n.Proxy.LanguageRule();

// English based transform method
// FORM: [singular, plural]
// {count | message, messages}
// {count | person, people}
Tr8n.Proxy.NumericRule.transform = function(count, values) {
  if (count == 1) return values[0];
  return values[1];  
}

Tr8n.Proxy.NumericRule.prototype.evaluate = function(token_name, token_values){
  //  "count":{"value1":"2,3,4","operator":"and","type":"number","multipart":true,"part2":"does_not_end_in","value2":"12,13,14","part1":"ends_in"}
  
  var object = this.getTokenValue(token_name, token_values);
  if (object == null) return false;

  var token_value = null;
  if (typeof object == 'string' || typeof object == 'number') {
    token_value = "" + object;
  } else if (typeof object == 'object' && object['subject']) { 
    token_value = "" + object['subject'];
  } else {
    this.getLogger().error("Invalid token value for numeric token: " + token_name);
    return false;
  }
  
  this.getLogger().debug("Rule value: '" + token_value + "' for definition: " + this.getDefinitionDescription());
  
  var result1 = this.evaluatePartialRule(token_value, this.definition['part1'], this.sanitizeArrayValue(this.definition['value1']));
  if (this.definition['multipart'] == 'false' || this.definition['multipart'] == false || this.definition['multipart'] == null) return result1;
  this.getLogger().debug("Part 1: " + result1 + " Processing part 2...");

  var result2 = this.evaluatePartialRule(token_value, this.definition['part2'], this.sanitizeArrayValue(this.definition['value2']));
  this.getLogger().debug("Part 2: " + result2 + " Completing evaluation...");
  
  if (this.definition['operator'] == "or") return (result1 || result2);
  return (result1 && result2);
}


Tr8n.Proxy.NumericRule.prototype.evaluatePartialRule = function(token_value, name, values) {
  if (name == 'is') {
    if (Tr8n.Proxy.Utils.indexOf(values, token_value)!=-1) return true; 
    return false;
  }
  if (name == 'is_not') {
    if (Tr8n.Proxy.Utils.indexOf(values, token_value)==-1) return true; 
    return false;
  }
  if (name == 'ends_in') {
    for(var i=0; i<values.length; i++) {
      if (token_value.match(values[i] + "$")) return true;
    }
    return false;
  }
  if (name == 'does_not_end_in') {
    for(var i=0; i<values.length; i++) {
      if (token_value.match(values[i] + "$")) return false;
    }
    return true;
  }
  return false;
}


/****************************************************************************
**** Tr8n Proxy GenderRule
****************************************************************************/

Tr8n.Proxy.GenderRule = function(definition, options) {
  this.definition = definition;
  this.options = options;
}

Tr8n.Proxy.GenderRule.prototype = new Tr8n.Proxy.LanguageRule();

//  FORM: [male, female, unknown]
//  {user | registered on}
//  {user | he, she}
//  {user | he, she, he/she}
Tr8n.Proxy.GenderRule.transform = function(object, values) {
  if (values.length == 1) return values[0];
  
  if (typeof object == 'string') {
    if (object == 'male') return values[0];
    if (object == 'female') return values[1];
  } else if (typeof object == 'object') {
    if (object['gender'] == 'male') return values[0];
    if (object['gender'] == 'female') return values[1];
  }

  if (values.length == 3) return values[2];
  return values[0] + "/" + values[1]; 
}

Tr8n.Proxy.GenderRule.prototype.evaluate = function(token_name, token_values) {

  var object = this.getTokenValue(token_name, token_values);
  if (!object) return false;

  var gender = "";
  
  if (typeof object != 'object') {
    this.getLogger().error("Invalid token value for gender based token: " + token_name + ". Token value must be an object.");
    return false;
  } 

  if (!object['subject']) {
    this.getLogger().error("Invalid token subject for gender based token: " + token_name + ". Token value must contain a subject. Subject can be a string or an object with a gender.");
    return false;
  }
  
  if (typeof object['subject'] == 'string') {
    gender = object['subject'];
  } else if (typeof object['subject'] == 'object') {
    gender = object['subject']['gender'];
    if (!gender) {
      this.getLogger().error("Cannot determine gender for token subject: " + token_name);
      return false;
    }
  } else {
    this.getLogger().error("Invalid token subject for gender based token: " + token_name + ". Subject does not have a gender.");
    return false;
  }
  
  if (this.definition['operator'] == "is") {
     return (gender == this.definition['value']);
  } else if (this.definition['operator'] == "is_not") {
     return (gender != this.definition['value']);
  }
  
  return false;
}

/****************************************************************************
**** Tr8n Proxy ListRule
****************************************************************************/

Tr8n.Proxy.ListRule = function(definition, options) {
  this.definition = definition;
  this.options = options;
}

Tr8n.Proxy.ListRule.prototype = new Tr8n.Proxy.LanguageRule();

Tr8n.Proxy.ListRule.transform = function(object, values) {
  return "";
}

Tr8n.Proxy.ListRule.prototype.evaluate = function(token, token_values) {
  return true;
}

/****************************************************************************
**** Tr8n Proxy GenderListRule
****************************************************************************/

Tr8n.Proxy.GenderListRule = function(definition, options) {
  this.definition = definition;
  this.options = options;
}

Tr8n.Proxy.GenderListRule.prototype = new Tr8n.Proxy.LanguageRule();

Tr8n.Proxy.GenderListRule.transform = function(object, values) {
  return "";
}

Tr8n.Proxy.GenderListRule.prototype.evaluate = function(token, token_values) {
  return true;
}

/****************************************************************************
**** Tr8n Proxy DateRule
****************************************************************************/

Tr8n.Proxy.DateRule = function(definition, options) {
  this.definition = definition;
  this.options = options;
}

Tr8n.Proxy.DateRule.prototype = new Tr8n.Proxy.LanguageRule();

Tr8n.Proxy.DateRule.transform = function(object, values) {
  return "";
}

Tr8n.Proxy.DateRule.prototype.evaluate = function(token, token_values) {
  return true;
}

/****************************************************************************
**** Tr8n Proxy Token
****************************************************************************/

Tr8n.Proxy.Token = function() {}

Tr8n.Proxy.Token.prototype = {
  getProxy: function() {
    return this.options['proxy'];
  },
  getLogger: function() {
    return this.getProxy().logger;
  },
  getExpression: function() {
    // must be implemented by the extending class
    return null;
  },
  register: function(label, options) {
    if (this.getExpression() == null)
      alert("Token expression must be provided");
      
    var tokens = label.match(this.getExpression());
    if (!tokens) return [];
    
    var objects = [];
    var uniq = {};
    for(i=0; i<tokens.length; i++) {
      if (uniq[tokens[i]]) continue;
      options['proxy'].debug("Registering data token: " + tokens[i]);
      objects.push(new Tr8n.Proxy.TransformToken(label, tokens[i], options)); 
      uniq[tokens[i]] = true;
    }
    return objects;
  },
  getFullName: function() {
    return this.full_name;
  },
  getDeclaredName: function() {
    if (!this.declared_name) {
      this.declared_name = this.getFullName().replace(/[{}\[\]]/g, '');
    }
    return this.declared_name;
  },
  getName: function() {
    if (!this.name) {
      this.name = Tr8n.Proxy.Utils.trim(this.getDeclaredName().split(':')[0]); 
    }
    return this.name;
  },
  getLanguageRule: function() {
    
    return null;
  },
  substitute: function(label, token_values) {
    var value = token_values[this.getName()];
    
    if (value == null) {
      this.getLogger().error("Value for token: " + this.getFullName() + " was not provided");
      return label;
    }

    return Tr8n.Proxy.Utils.replaceAll(label, this.getFullName(), this.getTokenValue(value)); 
  },
  getTokenValue: function(token_value) {
    if (typeof token_value == 'string') return token_value;
    if (typeof token_value == 'number') return token_value;
    return token_value['value'];
  },
  getTokenObject: function(token_value) {
    if (typeof token_value == 'string') return token_value;
    if (typeof token_value == 'number') return token_value;
    return token_value['subject'];
  },
  getType: function() {
    if (this.getDeclaredName().indexOf(':') == -1)
      return null;
    
    if (!this.type) {
      this.type = this.getDeclaredName().split('|')[0].split(':');
      this.type = this.type[this.type.length - 1];
    }
    
    return this.type;     
  },
  getSuffix: function() {
    if (!this.suffix) {
      this.suffix = this.getName().split('_');
      this.suffix = this.suffix[this.suffix.length - 1];
    }
    return this.suffix;
  },
  getLanguageRule: function() {
    if (!this.language_rule) {
      if (this.getType()) {
        this.language_rule = this.getProxy().getLanguageRuleForType(this.getType()); 
      } else {
        this.language_rule = this.getProxy().getLanguageRuleForTokenSuffix(this.getSuffix());
      }
    }
    return this.language_rule;
  }
}

/****************************************************************************
**** Tr8n Proxy Data Token
****************************************************************************/

Tr8n.Proxy.DataToken = function(label, token, options) {
  this.label = label;
  this.full_name = token;
  this.options = options;
}

Tr8n.Proxy.DataToken.prototype = new Tr8n.Proxy.Token();

Tr8n.Proxy.DataToken.parse = function(label, options) {
  var tokens = label.match(/(\{[^_][\w]+(:[\w]+)?\})/g);
  if (!tokens) return [];
  
  var objects = [];
  var uniq = {};
  for(i=0; i<tokens.length; i++) {
    if (uniq[tokens[i]]) continue;
    options['proxy'].debug("Registering data token: " + tokens[i]);
    objects.push(new Tr8n.Proxy.DataToken(label, tokens[i], options));
    uniq[tokens[i]] = true;
  }
  return objects;
}

/****************************************************************************
**** Tr8n Proxy Transform Token
****************************************************************************/

Tr8n.Proxy.TransformToken = function(label, token, options) {
  this.label = label;
  this.full_name = token;
  this.options = options;
}

Tr8n.Proxy.TransformToken.prototype = new Tr8n.Proxy.Token();

Tr8n.Proxy.TransformToken.parse = function(label, options) {
  var tokens = label.match(/(\{[^_][\w]+(:[\w]+)?\s*\|\|?[^{^}]+\})/g);
  if (!tokens) return [];
  
  var objects = [];
  var uniq = {};
  for(i=0; i<tokens.length; i++) {
    if (uniq[tokens[i]]) continue;
    options['proxy'].debug("Registering transform token: " + tokens[i]);
    objects.push(new Tr8n.Proxy.TransformToken(label, tokens[i], options)); 
    uniq[tokens[i]] = true;
  }
  return objects;
}

Tr8n.Proxy.TransformToken.prototype.getName = function() {
  if (!this.name) {
    this.name = Tr8n.Proxy.Utils.trim(this.getDeclaredName().split('|')[0].split(':')[0]); 
  }
  return this.name;
}

Tr8n.Proxy.TransformToken.prototype.getPipedParams = function() {
  if (!this.piped_params) {
    var temp = this.getDeclaredName().split('|');
    temp = temp[temp.length - 1].split(",");
    this.piped_params = [];
    for (i=0; i<temp.length; i++) {
      this.piped_params.push(Tr8n.Proxy.Utils.trim(temp[i]));
    }
  }
  return this.piped_params;
}

Tr8n.Proxy.TransformToken.prototype.substitute = function(label, token_values) {
  var object = token_values[this.getName()];
  if (object == null) {
    this.getLogger().error("Value for token: " + this.getFullName() + " was not provided");
    return label;
  }
  
  var token_object = this.getTokenObject(object);
  this.getLogger().debug("Registered " + this.getPipedParams().length + " piped params");
  
  var lang_rule_name = this.getLanguageRule();
  
  if (!lang_rule_name) {
    this.getLogger().error("Rule type cannot be determined for the transform token: " + this.getFullName());
    return label;
  } else {
    this.getLogger().debug("Transform token uses rule: " + lang_rule_name);
  }

  var transform_value = eval(lang_rule_name).transform(token_object, this.getPipedParams());
  this.getLogger().debug("Registered transform value: " + transform_value);
  
  // for double pipes - show the actual value as well
  if (this.isAllowedInTranslation()) {
    var token_value = this.getTokenValue(object);
    transform_value = token_value + " " + transform_value; 
  }
  
  return Tr8n.Proxy.Utils.replaceAll(label, this.getFullName(), transform_value);
}

Tr8n.Proxy.TransformToken.prototype.getPipedSeparator = function() {
  if (!this.piped_separator) {
    this.piped_separator = (this.getFullName().indexOf("||") != -1 ? "||" : "|");
  }
  return this.piped_separator;
}

Tr8n.Proxy.TransformToken.prototype.isAllowedInTranslation = function(){
  return this.getPipedSeparator() == "||";
}

/****************************************************************************
**** Tr8n Proxy Decoration Token
****************************************************************************/

Tr8n.Proxy.DecorationToken = function(label, token, options) {
  this.label = label;
  this.full_name = token;
  this.options = options;
}

Tr8n.Proxy.DecorationToken.prototype = new Tr8n.Proxy.Token();

Tr8n.Proxy.DecorationToken.parse = function(label, options) {
  var tokens = label.match(/(\[\w+:[^\]]+\])/g);
  if (!tokens) return [];
  
  var objects = [];
  var uniq = {};
  for(i=0; i<tokens.length; i++) {
    if (uniq[tokens[i]]) continue;
    options['proxy'].debug("Registering decoration token: " + tokens[i]);
    objects.push(new Tr8n.Proxy.DecorationToken(label, tokens[i], options));
    uniq[tokens[i]] = true;
  }
  return objects;
}

Tr8n.Proxy.DecorationToken.prototype.getDecoratedValue = function() {
  if (!this.decorated_value) {
    var value = this.getFullName().replace(/[\]]/g, '');
    value = value.substring(value.indexOf(':') + 1, value.length);
    this.decorated_value = Tr8n.Proxy.Utils.trim(value);
  }
  return this.decorated_value;
}

Tr8n.Proxy.DecorationToken.prototype.substitute = function(label, token_values) {
  var object = token_values[this.getName()];
  var decoration = object;
  
  if (!object || typeof object == 'object') {
    // look for the default decoration
    decoration = this.getProxy().getDecorationFor(this.getName());
    if (!decoration) {
      this.getLogger().error("Default decoration is not defined for token " + this.getName());
      return label;
    }
    
    decoration = Tr8n.Proxy.Utils.replaceAll(decoration, '{$0}', this.getDecoratedValue());
    if (object) {
      for (var key in object) {
        decoration = Tr8n.Proxy.Utils.replaceAll(decoration, '{$' + key + '}', object[key]);
      }
    }
  } else if (typeof object == 'string') {
    decoration = Tr8n.Proxy.Utils.replaceAll(decoration, '{$0}', this.getDecoratedValue());
  } else {
    this.getLogger().error("Unknown type of decoration token " + this.getFullName());
    return label;
  }
  
  return Tr8n.Proxy.Utils.replaceAll(label, this.getFullName(), decoration);
}

/****************************************************************************
**** Tr8n Proxy Logger
****************************************************************************/

Tr8n.Proxy.Logger = function(options) {
  this.options = options;
  this.object_keys = [];
}

Tr8n.Proxy.Logger.prototype = {
  clear: function() {
    if (!this.options['proxy'].logger_enabled) return;
    if (!this.options['element_id']) return;
    if (!Tr8n.Proxy.Utils.element(this.options['element_id'])) return;
    Tr8n.element(this.options['element_id']).innerHTML = ""; 
  },
  append: function(msg) {
    if (!this.options['proxy'].logger_enabled) return;
    if (!this.options['element_id']) return;
    if (!Tr8n.Proxy.Utils.element(this.options['element_id'])) return;

    var str = msg + "<br>" + Tr8n.Proxy.Utils.element(this.options['element_id']).innerHTML;
    Tr8n.element(this.options['element_id']).innerHTML = str; 
  },
  log: function(msg) {
    if (!this.options['proxy'].logger_enabled) return;
    var now = new Date();
    var str = "<span style='color:#ccc;'>" + (now.toLocaleDateString() + " " + now.toLocaleTimeString()) + "</span>: " + msg;  
    this.append(str); 
  },
  debug: function(msg) {
    this.log("<span style='color:grey'>" + msg + "</span>");
  },
  error: function(msg) {
    this.log("<span style='color:red'>" + msg + "</span>");
  },
  S4: function() {
    return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
  },
  guid: function() {
    return (this.S4()+this.S4()+"-"+this.S4()+"-"+this.S4()+"-"+this.S4()+"-"+this.S4()+this.S4()+this.S4());
  },
  escapeHTML: function(str) { 
    return( str.replace(/&/g,'&amp;').replace(/>/g,'&gt;').replace(/</g,'&lt;').replace(/"/g,'&quot;')); 
  },
  showObject: function (obj_key, flag) {
    if (flag) {
      Tr8n.Proxy.Utils.hide("no_object_" + obj_key);
      Tr8n.Proxy.Utils.show("object_" + obj_key);
      Tr8n.element("expander_" + obj_key).innerHTML = "<img src='/assets/tr8n/minus_node.png'>";
    } else {
      Tr8n.Proxy.Utils.hide("object_" + obj_key);
      Tr8n.Proxy.Utils.show("no_object_" + obj_key);
      Tr8n.element("expander_" + obj_key).innerHTML = "<img src='/assets/tr8n/plus_node.png'>";
    } 
  },
  toggleNode: function(obj_key) {
    this.showObject(obj_key, (Tr8n.element("object_" + obj_key).style.display == 'none'));
  },
  expandAllNodes: function() {
    for (var i=0; i<this.object_keys.length; i++) {
      this.showObject(this.object_keys[i], true);
    }
  },
  collapseAllNodes: function() {
    for (var i=0; i<this.object_keys.length; i++) {
      this.showObject(this.object_keys[i], false);
    }
  },
  logObject: function(data) {
    this.object_keys = [];
    html = []
    html.push("<div style='float:right;padding-right:10px;'>");
    html.push("<span style='padding:2px;' onClick=\"tr8nProxy.logger.expandAllNodes()\"><img src='/assets/tr8n/plus_node.png'></span>");
    html.push("<span style='padding:2px;' onClick=\"tr8nProxy.logger.collapseAllNodes()\"><img src='/assets/tr8n/minus_node.png'></span>");
    html.push("</div>");

    var results = data;
    if (typeof results == 'string') {
      try {
        results = eval("[" + results + "]")[0];
      } 
      catch (err) {
        this.push(results);
        return;
      }
    }
    if (typeof results == 'object') {
      html.push(this.formatObject(results, 1));
    } else {
      html.push(results);
    }
    this.append(html.join(""));
  },
  formatObject: function(obj, level) {
    if (obj == null) return "{<br>}";

    var html = [];
    var obj_key = this.guid();  
    html.push("<span class='tr8n_logger_expander' id='expander_" + obj_key + "' onClick=\"tr8nProxy.logger.toggleNode('" + obj_key + "')\"><img src='/assets/tr8n/minus_node.png'></span> <span style='display:none' id='no_object_" + obj_key + "'>{...}</span> <span id='object_" + obj_key + "'>{");
    this.object_keys.push(obj_key);

    var keys = Object.keys(obj).sort();

    for (var i=0; i<keys.length; i++) {
      key = keys[i];
      if (this.isObject(obj[key])) {
        if (this.isArray(obj[key])) {
          html.push(this.createSpacer(level) + "<span class='tr8n_logger_obj_key'>" + key + ":</span>" + this.formatArray(obj[key], level + 1) + ",");
        } else {
          html.push(this.createSpacer(level) + "<span class='tr8n_logger_obj_key'>" + key + ":</span>" + this.formatObject(obj[key], level + 1) + ",");
        }
      } else {
        html.push(this.createSpacer(level) + this.formatProperty(key, obj[key]) + ",");
      }
    }
    html.push(this.createSpacer(level-1) + "}</span>");
    return html.join("<br>");
  },
  formatArray: function(arr, level) {
    if (arr == null) return "[<br>]";

    var html = [];
    var obj_key = this.guid();  
    html.push("<span class='tr8n_logger_expander' id='expander_" + obj_key + "' onClick=\"tr8nProxy.logger.toggleNode('" + obj_key + "')\"><img src='/assets/tr8n/minus_node.png'></span> <span style='display:none' id='no_object_" + obj_key + "'>[...]</span> <span id='object_" + obj_key + "'>[");
    this.object_keys.push(obj_key);

    for (var i=0; i<arr.length; i++) {
      if (this.isObject(arr[i])) {
        if (this.isArray(arr[i])) {
           html.push(this.createSpacer(level) + this.formatArray(arr[i], level + 1) + ","); 
        } else {
           html.push(this.createSpacer(level) + this.formatObject(arr[i], level + 1) + ",");  
        }     
      } else {
        html.push(this.createSpacer(level) + this.formatProperty(null, arr[i]) + ",");
      }
    }  
    html.push(this.createSpacer(level-1) + "]</span>");
    return html.join("<br>");
  },
  formatProperty: function(key, value) {
    if (value == null) return "<span class='tr8n_logger_obj_key'>" + key + ":</span><span class='obj_value_null'>null</span>";
    
    var cls = "tr8n_logger_obj_value_" + (typeof value);
    var value_span = "";
    
    if (this.isString(value)) 
      value_span = "<span class='" + cls + "'>\"" + this.escapeHTML(value) + "\"</span>";
    else
      value_span = "<span class='" + cls + "'>" + value + "</span>";
       
    if (key == null)
      return value_span;
      
    return "<span class='tr8n_logger_obj_key'>" + key + ":</span>" + value_span;
  },
  createSpacer: function(level) {
    return "<img src='/assets/tr8n/pixel.gif' style='height:1px;width:" + (level * 20) + "px;'>";
  },
  isArray: function(obj) {
    if (obj == null) return false;
    return !(obj.constructor.toString().indexOf("Array") == -1);
  },
  isObject: function(obj) {
    if (obj == null) return false;
    return (typeof obj == 'object');
  },
  isString: function(obj) {
    return (typeof obj == 'string');
  },
  isURL: function(str) {
    str = "" + str;
    return (str.indexOf("http://") != -1) || (str.indexOf("https://") != -1);
  }
}



/****************************************************************************
**** Tr8n Proxy Utils
****************************************************************************/

Tr8n.Proxy.Utils = {
  
  element:function(element_id) {
    if (typeof element_id == 'string') return document.getElementById(element_id);
    return element_id;
  },
  
  hide: function(element_id) {
    Tr8n.element(element_id).style.display = "none";
  },

  show: function(element_id) {
    var style = (Tr8n.element(element_id).tagName == "SPAN") ? "inline" : "block";
    Tr8n.element(element_id).style.display = style;
  },

  indexOf: function(array, item, i) {
    i || (i = 0);
    var length = array.length;
    if (i < 0) i = length + i;
    for (; i < length; i++)
      if (array[i] === item) return i;
    return -1;
  },

  replaceAll: function(label, key, value) {
    while (label.indexOf(key) != -1) {
      label = label.replace(key, value);
    }
    return label;
  },
  
  trim: function(string) {
    return string.replace(/^\s+|\s+$/g,"");
  },
  
  ltrim: function(string) {
    return string.replace(/^\s+/,"");
  },
  
  rtrim: function(string) {
    return string.replace(/\s+$/,"");
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
    options.parameters = Tr8n.Proxy.Utils.toQueryParams(options.parameters);
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
  } 
}

/****************************************************************************
***
***  MD5 (Message-Digest Algorithm)
***  http://www.webtoolkit.info/
***
****************************************************************************/
 
var MD5 = function (string) {
 
  function RotateLeft(lValue, iShiftBits) {
    return (lValue<<iShiftBits) | (lValue>>>(32-iShiftBits));
  }
 
  function AddUnsigned(lX,lY) {
    var lX4,lY4,lX8,lY8,lResult;
    lX8 = (lX & 0x80000000);
    lY8 = (lY & 0x80000000);
    lX4 = (lX & 0x40000000);
    lY4 = (lY & 0x40000000);
    lResult = (lX & 0x3FFFFFFF)+(lY & 0x3FFFFFFF);
    if (lX4 & lY4) {
      return (lResult ^ 0x80000000 ^ lX8 ^ lY8);
    }
    if (lX4 | lY4) {
      if (lResult & 0x40000000) {
        return (lResult ^ 0xC0000000 ^ lX8 ^ lY8);
      } else {
        return (lResult ^ 0x40000000 ^ lX8 ^ lY8);
      }
    } else {
      return (lResult ^ lX8 ^ lY8);
    }
  }
 
  function F(x,y,z) { return (x & y) | ((~x) & z); }
  function G(x,y,z) { return (x & z) | (y & (~z)); }
  function H(x,y,z) { return (x ^ y ^ z); }
  function I(x,y,z) { return (y ^ (x | (~z))); }
 
  function FF(a,b,c,d,x,s,ac) {
    a = AddUnsigned(a, AddUnsigned(AddUnsigned(F(b, c, d), x), ac));
    return AddUnsigned(RotateLeft(a, s), b);
  };
 
  function GG(a,b,c,d,x,s,ac) {
    a = AddUnsigned(a, AddUnsigned(AddUnsigned(G(b, c, d), x), ac));
    return AddUnsigned(RotateLeft(a, s), b);
  };
 
  function HH(a,b,c,d,x,s,ac) {
    a = AddUnsigned(a, AddUnsigned(AddUnsigned(H(b, c, d), x), ac));
    return AddUnsigned(RotateLeft(a, s), b);
  };
 
  function II(a,b,c,d,x,s,ac) {
    a = AddUnsigned(a, AddUnsigned(AddUnsigned(I(b, c, d), x), ac));
    return AddUnsigned(RotateLeft(a, s), b);
  };
 
  function ConvertToWordArray(string) {
    var lWordCount;
    var lMessageLength = string.length;
    var lNumberOfWords_temp1=lMessageLength + 8;
    var lNumberOfWords_temp2=(lNumberOfWords_temp1-(lNumberOfWords_temp1 % 64))/64;
    var lNumberOfWords = (lNumberOfWords_temp2+1)*16;
    var lWordArray=Array(lNumberOfWords-1);
    var lBytePosition = 0;
    var lByteCount = 0;
    while ( lByteCount < lMessageLength ) {
      lWordCount = (lByteCount-(lByteCount % 4))/4;
      lBytePosition = (lByteCount % 4)*8;
      lWordArray[lWordCount] = (lWordArray[lWordCount] | (string.charCodeAt(lByteCount)<<lBytePosition));
      lByteCount++;
    }
    lWordCount = (lByteCount-(lByteCount % 4))/4;
    lBytePosition = (lByteCount % 4)*8;
    lWordArray[lWordCount] = lWordArray[lWordCount] | (0x80<<lBytePosition);
    lWordArray[lNumberOfWords-2] = lMessageLength<<3;
    lWordArray[lNumberOfWords-1] = lMessageLength>>>29;
    return lWordArray;
  };
 
  function WordToHex(lValue) {
    var WordToHexValue="",WordToHexValue_temp="",lByte,lCount;
    for (lCount = 0;lCount<=3;lCount++) {
      lByte = (lValue>>>(lCount*8)) & 255;
      WordToHexValue_temp = "0" + lByte.toString(16);
      WordToHexValue = WordToHexValue + WordToHexValue_temp.substr(WordToHexValue_temp.length-2,2);
    }
    return WordToHexValue;
  };
 
  function Utf8Encode(string) {
    string = string.replace(/\r\n/g,"\n");
    var utftext = "";
 
    for (var n = 0; n < string.length; n++) {
 
      var c = string.charCodeAt(n);
 
      if (c < 128) {
        utftext += String.fromCharCode(c);
      }
      else if((c > 127) && (c < 2048)) {
        utftext += String.fromCharCode((c >> 6) | 192);
        utftext += String.fromCharCode((c & 63) | 128);
      }
      else {
        utftext += String.fromCharCode((c >> 12) | 224);
        utftext += String.fromCharCode(((c >> 6) & 63) | 128);
        utftext += String.fromCharCode((c & 63) | 128);
      }
 
    }
 
    return utftext;
  };
 
  var x=Array();
  var k,AA,BB,CC,DD,a,b,c,d;
  var S11=7, S12=12, S13=17, S14=22;
  var S21=5, S22=9 , S23=14, S24=20;
  var S31=4, S32=11, S33=16, S34=23;
  var S41=6, S42=10, S43=15, S44=21;
 
  string = Utf8Encode(string);
 
  x = ConvertToWordArray(string);
 
  a = 0x67452301; b = 0xEFCDAB89; c = 0x98BADCFE; d = 0x10325476;
 
  for (k=0;k<x.length;k+=16) {
    AA=a; BB=b; CC=c; DD=d;
    a=FF(a,b,c,d,x[k+0], S11,0xD76AA478);
    d=FF(d,a,b,c,x[k+1], S12,0xE8C7B756);
    c=FF(c,d,a,b,x[k+2], S13,0x242070DB);
    b=FF(b,c,d,a,x[k+3], S14,0xC1BDCEEE);
    a=FF(a,b,c,d,x[k+4], S11,0xF57C0FAF);
    d=FF(d,a,b,c,x[k+5], S12,0x4787C62A);
    c=FF(c,d,a,b,x[k+6], S13,0xA8304613);
    b=FF(b,c,d,a,x[k+7], S14,0xFD469501);
    a=FF(a,b,c,d,x[k+8], S11,0x698098D8);
    d=FF(d,a,b,c,x[k+9], S12,0x8B44F7AF);
    c=FF(c,d,a,b,x[k+10],S13,0xFFFF5BB1);
    b=FF(b,c,d,a,x[k+11],S14,0x895CD7BE);
    a=FF(a,b,c,d,x[k+12],S11,0x6B901122);
    d=FF(d,a,b,c,x[k+13],S12,0xFD987193);
    c=FF(c,d,a,b,x[k+14],S13,0xA679438E);
    b=FF(b,c,d,a,x[k+15],S14,0x49B40821);
    a=GG(a,b,c,d,x[k+1], S21,0xF61E2562);
    d=GG(d,a,b,c,x[k+6], S22,0xC040B340);
    c=GG(c,d,a,b,x[k+11],S23,0x265E5A51);
    b=GG(b,c,d,a,x[k+0], S24,0xE9B6C7AA);
    a=GG(a,b,c,d,x[k+5], S21,0xD62F105D);
    d=GG(d,a,b,c,x[k+10],S22,0x2441453);
    c=GG(c,d,a,b,x[k+15],S23,0xD8A1E681);
    b=GG(b,c,d,a,x[k+4], S24,0xE7D3FBC8);
    a=GG(a,b,c,d,x[k+9], S21,0x21E1CDE6);
    d=GG(d,a,b,c,x[k+14],S22,0xC33707D6);
    c=GG(c,d,a,b,x[k+3], S23,0xF4D50D87);
    b=GG(b,c,d,a,x[k+8], S24,0x455A14ED);
    a=GG(a,b,c,d,x[k+13],S21,0xA9E3E905);
    d=GG(d,a,b,c,x[k+2], S22,0xFCEFA3F8);
    c=GG(c,d,a,b,x[k+7], S23,0x676F02D9);
    b=GG(b,c,d,a,x[k+12],S24,0x8D2A4C8A);
    a=HH(a,b,c,d,x[k+5], S31,0xFFFA3942);
    d=HH(d,a,b,c,x[k+8], S32,0x8771F681);
    c=HH(c,d,a,b,x[k+11],S33,0x6D9D6122);
    b=HH(b,c,d,a,x[k+14],S34,0xFDE5380C);
    a=HH(a,b,c,d,x[k+1], S31,0xA4BEEA44);
    d=HH(d,a,b,c,x[k+4], S32,0x4BDECFA9);
    c=HH(c,d,a,b,x[k+7], S33,0xF6BB4B60);
    b=HH(b,c,d,a,x[k+10],S34,0xBEBFBC70);
    a=HH(a,b,c,d,x[k+13],S31,0x289B7EC6);
    d=HH(d,a,b,c,x[k+0], S32,0xEAA127FA);
    c=HH(c,d,a,b,x[k+3], S33,0xD4EF3085);
    b=HH(b,c,d,a,x[k+6], S34,0x4881D05);
    a=HH(a,b,c,d,x[k+9], S31,0xD9D4D039);
    d=HH(d,a,b,c,x[k+12],S32,0xE6DB99E5);
    c=HH(c,d,a,b,x[k+15],S33,0x1FA27CF8);
    b=HH(b,c,d,a,x[k+2], S34,0xC4AC5665);
    a=II(a,b,c,d,x[k+0], S41,0xF4292244);
    d=II(d,a,b,c,x[k+7], S42,0x432AFF97);
    c=II(c,d,a,b,x[k+14],S43,0xAB9423A7);
    b=II(b,c,d,a,x[k+5], S44,0xFC93A039);
    a=II(a,b,c,d,x[k+12],S41,0x655B59C3);
    d=II(d,a,b,c,x[k+3], S42,0x8F0CCC92);
    c=II(c,d,a,b,x[k+10],S43,0xFFEFF47D);
    b=II(b,c,d,a,x[k+1], S44,0x85845DD1);
    a=II(a,b,c,d,x[k+8], S41,0x6FA87E4F);
    d=II(d,a,b,c,x[k+15],S42,0xFE2CE6E0);
    c=II(c,d,a,b,x[k+6], S43,0xA3014314);
    b=II(b,c,d,a,x[k+13],S44,0x4E0811A1);
    a=II(a,b,c,d,x[k+4], S41,0xF7537E82);
    d=II(d,a,b,c,x[k+11],S42,0xBD3AF235);
    c=II(c,d,a,b,x[k+2], S43,0x2AD7D2BB);
    b=II(b,c,d,a,x[k+9], S44,0xEB86D391);
    a=AddUnsigned(a,AA);
    b=AddUnsigned(b,BB);
    c=AddUnsigned(c,CC);
    d=AddUnsigned(d,DD);
  }
 
  var temp = WordToHex(a)+WordToHex(b)+WordToHex(c)+WordToHex(d);
 
  return temp.toLowerCase();
}