/****************************************************************************
  Copyright (c) 2010 Michael Berkovich, Geni Inc

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

var Tr8n = Tr8n || {};

/****************************************************************************
**** Tr8n Proxy
****************************************************************************/

Tr8n.Proxy = function(options) {
  var self = this;
  this.options = options;
  this.options['url'] = this.options['url'] || '/tr8n/api/v1/language/translate'; 
  this.options['scheduler_interval'] = this.options['scheduler_interval'] || 20000; 
  this.logger_enabled = true;
  
  this.logger = new Tr8n.Proxy.Logger({
    'proxy': self
  });
        
  this.language = new Tr8n.Proxy.Language({
    'proxy': self
  });
  
  this.initTranslations();
  //this.runScheduledTasks();
}

Tr8n.Proxy.prototype = {
  log: function(msg) {
    this.logger.debug(msg);
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
    return this.language.translate(label, description, tokens, options);
  },
  tr: function(label, description, tokens, options) {
    return this.translate(label, description, tokens, options);
  },
  getTranslations: function() {
    if (!this.translations) return {};
    return this.translations;
  },
  registerMissingTranslationKey: function(translation_key) {
    this.missing_translation_keys = this.missing_translation_keys || {};
    if (!this.missing_translation_keys[translation_key.key]) {
      this.missing_translation_keys[translation_key.key] = translation_key;
    }
  },
  registerTranslationKeys: function(translations) {
    this.log("Found " + translations.length + " phrases");
    for (var i = 0; i < translations.length; i++) {
       this.log("Registering " + translations[i]['key']);
       this.translations[translations[i]['key']] = translations[i];
    }
		if (this.options.onTranslationsRegistered) 
		    this.options.onTranslationsRegistered();
  },
  submitMissingTranslationKeys: function() {
    if (!this.missing_translation_keys) {
      this.log('No missing translation keys to submit...');
      return;
    }
    
    var phrases = "[";
    for (var key in this.missing_translation_keys) {
      var translation_key = this.missing_translation_keys[key];
      if (phrases!="[") phrases = phrases + ",";
      phrases = phrases + "{";
      phrases = phrases + '"label":"' + translation_key.label + '", ';
      phrases = phrases + '"description":"' + translation_key.description + '"';
      phrases = phrases + "}";
    }
    phrases = phrases + "]";
    this.missing_translation_keys = null;
    
    var self = this;
    this.debug('Submitting missing translation keys: ' + phrases);
    Tr8n.Proxy.Utils.ajax(this.options['url'], {
      method: 'put',
      parameters: {'source': encodeURI(self.options['source']), 'phrases': phrases},
      onSuccess: function(response) {
        self.log("Received response from the server");
        self.log(response.responseText);
        self.registerTranslationKeys(eval("[" + response.responseText + "]")[0]['phrases']);
      }
    }); 
  },
  initTranslations: function(forced) {
    if (!forced && this.translations) return;

    var self = this;
    self.log("Fetching translations from the server...");
		
    self.translations = {};
    Tr8n.Proxy.Utils.ajax(this.options['url'], {
      method: 'get',
      parameters: {'language':'ru', 'batch': true, 'source': encodeURI(self.options['source'])},
      onSuccess: function(response) {
        self.log("Received response from the server");
        self.log(response.responseText);
        self.registerTranslationKeys(eval("[" + response.responseText + "]")[0]['phrases']);
      }
    }); 
  },
  runScheduledTasks: function() {
    var self = this;
    
    this.log("Running scheduled tasks...");
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
      this.getLogger().error("Translations are in a weid form...");
      return null;
    }
		
    this.getLogger().debug('Found translations: ' + translations.length);

    // there is no support for tokens or rules in firefox mode
		if (translations.length > 0) return translations[0];
		
    this.getLogger().debug('No acceptable ranslations found');
    return null;        
  },
  translate: function(language, token_values, options) {
    if (!this.label) {
      this.getLogger().error('Label must always be provided for the translate method');
      return '';
    }
    
    var translations = this.getProxy().getTranslations();
    if (translations[this.key]) {
      var translation = this.findFirstAcceptableTranslation(translations[this.key], token_values);
      if (!translation) return this.substituteTokens(this.label, token_values, options);
      return this.substituteTokens(translation['label'], token_values, options);    
    }

    this.getProxy().registerMissingTranslationKey(this);
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
  substituteTokens: function(label, token_values, options) {
    // no tokens are supported in firefox mode    
    return label;
  } 
}

/****************************************************************************
**** Tr8n Proxy Logger
****************************************************************************/

Tr8n.Proxy.Logger = function(options) {
  this.options = options;
}

Tr8n.Proxy.Logger.prototype = {
  log: function(msg) {
    if (!this.options['proxy'].logger_enabled) return;

    var now = new Date();
    var console = Components.classes["@mozilla.org/consoleservice;1"].getService(Components.interfaces.nsIConsoleService);
    console.logStringMessage("Tr8n: " + (now.toLocaleDateString() + " " + now.toLocaleTimeString()) + ":: " + msg);
  },
  debug: function(msg) {
    this.log(msg);
  },
  error: function(msg) {
    this.log(msg);
  }
}

/****************************************************************************
**** Tr8n Proxy Utils
****************************************************************************/

Tr8n.Proxy.Utils = {
  
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
  
  toQueryParams: function (obj) { 
    if (typeof obj == 'undefined' || obj == null) return "";
    if (typeof obj == 'string') return obj;      
    
    var qs = [];
    for(p in obj) {
        qs.push(p + "=" + encodeURIComponent(obj[p]))
    }
    return qs.join("&")
  },

  ajax: function(url, options) {
    options = options || {};
    options.parameters = Tr8n.Proxy.Utils.toQueryParams(options.parameters);
    options.method = options.method || 'get';

    var self=this;
    if (options.method == 'get' && options.parameters != '') {
      url = url + (url.indexOf('?') == -1 ? '?' : '&') + options.parameters;
    }
    
    var request = new XMLHttpRequest();
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
		
    var console = Components.classes["@mozilla.org/consoleservice;1"].getService(Components.interfaces.nsIConsoleService);
    console.logStringMessage("Tr8n: " + url);
		
    request.open(options.method, url, true);
    request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    request.setRequestHeader('Accept', 'text/javascript, text/html, application/xml, text/xml, */*');
    request.send(options.parameters);
  } 
}
