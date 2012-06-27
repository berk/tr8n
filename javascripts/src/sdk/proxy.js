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

///////////////////////////////////////////////////////////////////////////
// Tr8n.SDK.Proxy.init({
//   "default_source": "welcome/index/JS",
//   "scheduler_interval": 5000,
//   "enable_inline_translations": true,
//   "enable_tml": true,
//   "default_decorations": {
//     "strong":"<strong>{$0}</strong>",
//     "bold":"<strong>{$0}</strong>",
//     "b":"<strong>{$0}</strong>",
//     "em":"<em>{$0}</em>",
//     "italic":"<i>{$0}</i>",
//     "i":"<i>{$0}</i>",
//     "link":"<a href='{$href}'>{$0}</a>",
//     "br":"<br>{$0}",
//     "div":"<div id='{$id}' class='{$class}' style='{$style}'>{$0}</div>",
//     "span":"<span id='{$id}' class='{$class}' style='{$style}'>{$0}</span>",
//     "h1":"<h1>{$0}</h1>",
//     "h2":"<h2>{$0}</h2>",
//     "h3":"<h3>{$0}</h3>"
//   },
//   "default_tokens": {
//     "ndash":"&ndash;",
//     "mdash":"&mdash;",
//     "iexcl":"&iexcl;",
//     "iquest":"&iquest;",
//     "quot":"&quot;",
//     "ldquo":"&ldquo;",
//     "rdquo":"&rdquo;",
//     "lsquo":"&lsquo;",
//     "rsquo":"&rsquo;",
//     "laquo":"&laquo;",
//     "raquo":"&raquo;",
//     "nbsp":"&nbsp;",
//     "lsaquo":"&lsaquo;",
//     "rsaquo":"&rsaquo;",
//     "br":"<br/>",
//     "lbrace":"{",
//     "rbrace":"}"
//   },
//   "rules": {
//     "number": {
//       "token_suffixes": ["count","num","age","hours","minutes","years","seconds"],
//       "object_method": "to_i"
//     },
//     "gender": {
//       "token_suffixes": ["user","profile","actor","target","partner"], 
//       "object_method": "gender",
//       "method_values": {
//         "female": "female",
//         "male": "male",
//         "neutral": "neutral",
//         "unknown": "unknown"
//       }
//     },
//     "list": {
//       "object_method": "size",
//       "token_suffixes": ["list"]
//     }, 
//     "date": {
//       "token_suffixes": ["date"],
//       "object_method": "to_date"
//     }
//   }
// });
///////////////////////////////////////////////////////////////////////////


Tr8n.SDK.Proxy = {

  options: {},
  scheduler_enabled: true,
  inline_translations_enabled: false,
  tml_enabled: false,
  scheduler_interval: 5000,
  batch_size: 5,
  language: null,
  translations: {},
  missing_translation_keys: {},
  source: null,  // the source is only needed for custom components - in most cases referrer should be used to minimize jsonp urls
  page_locale: "en-US", // this needs to be dynamically determined based on tha page content
  selected_locale: "en-US",

  init: function(opts) {
    Tr8n.log("Initializing Tr8n Client SDK...");

    this.options = opts || (opts = {});
    this.scheduler_interval = this.options['scheduler_interval'] || this.scheduler_interval; 
    this.inline_translations_enabled = this.options['enable_inline_translations'];
    Tr8n.inline_translations_enabled = this.options['enable_inline_translations'];
    this.tml_enabled = this.options['enable_tml'];
    this.text_enabled = this.options['enable_text'];
    this.source = this.options['source'];
    this.selected_locale = this.options['locale'];

    this.language = new Tr8n.SDK.Language();

    this.initTranslations();
    this.runScheduledTasks();

    if ( this.tml_enabled ) {
      Tr8n.log("Parsing tml...");
      Tr8n.Utils.addEvent(window, 'load', function() {
        Tr8n.SDK.Proxy.initTml();
      });
    } else if ( this.text_enabled ) {
      Tr8n.log("Parsing text...");
      Tr8n.Utils.addEvent(window, 'load', function() {
        Tr8n.SDK.Proxy.initText();
      });
    }

    return this;
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

  getDecorationFor: function(decoration_name) {
    if (!this.options['default_decorations'])
      return null;
    return this.options['default_decorations'][decoration_name];
  },

  getLanguageRuleForType: function(rule_type) {
    // modify this section to add more rules
    if (rule_type == 'number')        return 'Tr8n.SDK.Rules.NumericRule';
    if (rule_type == 'gender')        return 'Tr8n.SDK.Rules.GenderRule';
    if (rule_type == 'date')          return 'Tr8n.SDK.Rules.DateRule';
    if (rule_type == 'list')          return 'Tr8n.SDK.Rules.ListRule';
    if (rule_type == 'gender_list')   return 'Tr8n.SDK.Rules.GenderListRule';
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
    if (!Tr8n.Utils.isArray(translations)) {
      translations = translations['phrases'];
    }

    Tr8n.log("Found " + translations.length + " registered phrases");

    for (i = 0; i < translations.length; i++) {
       var translation_key = translations[i];
       // Tr8n.log("Registering " + translation_key['key']);
       this.translations[translation_key['key']] = translation_key;
    }
  },

  initTranslations: function() {
    // Check for page variable to load translations from, if variable was provided
    if (this.options['translations_cache_id']) {
      this.log("Registering page translations from translations cache...");
      this.registerTranslationKeys(eval(this.options['translations_cache_id']));
    }

    var self = this;
    
    // Tr8n.log("Before fetching translations " + this.options['fetch_translations_on_init']);

    // Optionally, fetch translations from the server
    if (this.options['fetch_translations_on_init']) {
      Tr8n.log("Fetching translations from the server...");

      Tr8n.api('language/translate', {
        'batch': true, 
        'source': self.source
      }, function(data) {
          Tr8n.log("Received response from the server");
          self.registerTranslationKeys(data['phrases']);
      });
    }
  },
    
  registerMissingTranslationKey: function(translation_key, token_values, options) {
    // if selected language is the same as the page language - do not submit the missing keys
    if (this.page_locale == this.selected_locale) return;

    if (!this.missing_translation_keys[translation_key.key]) {
      // Tr8n.log('Adding missing translation key to the queue: ' + translation_key.key);
      this.missing_translation_keys[translation_key.key] = {translation_key:translation_key, token_values:token_values, options:options};
    }
  },

  submitMissingTranslationKeys: function() {
    this.scheduler_enabled = false;

    var phrases = [];
    var count = 0;

    var keys = Object.keys(this.missing_translation_keys).sort();
    for (var i=0; i<keys.length; i++) {
      key = keys[i];
      var missing_translation_key_data = this.missing_translation_keys[key];
      var translation_key = missing_translation_key_data.translation_key;
      
      // when will this happen?
      if (translation_key == null) continue;

      // ignore lables that are too long
      if (translation_key.label.length > 200) continue;

      var phrase = {label: translation_key.label};
      if (translation_key.description && translation_key.description.length > 0) phrase.description = translation_key.description;

      phrases.push(phrase);

      var url_params = JSON.stringify(phrases);

      // Tr8n.log('Adding translation key ' + phrase.label + ' to the queue.');
      // Tr8n.log('Params size is ' + url_params.length);

      if (url_params.length > 200) { 
        phrases.pop();
        break;
      }
    }
    
    if (phrases.length == 0) {
      // Tr8n.log('No missing translation keys to submit...');
      this.scheduler_enabled = true;
      return;
    }
    
    var self = this;
    Tr8n.log("Submitting " + phrases.length + " translation keys...");
    
    var params = {
      phrases: JSON.stringify(phrases)
    };
    if (self.source) params['source'] = self.source;   // don't send it unless it is set

    Tr8n.api('language/translate', params, function(data) {
        // Tr8n.log("Received response from the server: " + JSON.stringify(data));
        self.updateMissingTranslationKeys(data['phrases']);
    });
  },
  
  updateMissingTranslationKeys: function(translations) {
    if (!Tr8n.Utils.isArray(translations)) {
      translations = translations['phrases'];
    }

    Tr8n.log("Received " + translations.length + " translation keys...");

    for (i = 0; i < translations.length; i++) {
       var translation_key_data = translations[i];

       // Tr8n.log("Registering new key " + JSON.stringify(translation_key_data));

       this.translations[translation_key_data.key] = translation_key_data;
       var missing_key_data = this.missing_translation_keys[translation_key_data.key];
       
       var tr8nElement = Tr8n.element(translation_key_data.key);
      
       if (tr8nElement && missing_key_data.translation_key) {
         tr8nElement.setAttribute('translation_key_id', translation_key_data['id']);
         tr8nElement.innerHTML = missing_key_data.translation_key.translate(this.language, missing_key_data.token_values);
       }
       
       delete this.missing_translation_keys[missing_key_data.translation_key.key];
    }

    var keys = Object.keys(this.missing_translation_keys);

    if (keys.length > 0) {
      this.submitMissingTranslationKeys();  
    } else {
      this.scheduler_enabled = true;
    }
  },  

  runScheduledTasks: function() {
    var self = this;
    
    if (this.scheduler_enabled) {
      this.submitMissingTranslationKeys();
    }
    
    window.setTimeout(function() {
      self.runScheduledTasks();
    }, this.options['scheduler_interval']);
  },

  initTml: function() {
    if (Tr8n.element('tr8n_status_node')) return;

    var tree_walker = document.createTreeWalker(document.body, NodeFilter.SHOW_ALL, function(node) {
      if (node.nodeName == 'TML:LABEL') {
        return NodeFilter.FILTER_ACCEPT;
      } else {
        return NodeFilter.FILTER_SKIP;
      }
    }, false);

    while (tree_walker.nextNode()) {
      new Tr8n.SDK.TML.Label(tree_walker.currentNode).translate();
    }

    this.submitMissingTranslationKeys();
  },

  translateTextNode: function(parent_node, text_node, label) {
    // we need to handle empty spaces better
    var sanitized_label = Tr8n.Utils.sanitizeString(label);

    if (Tr8n.Utils.isNumber(sanitized_label)) return;

    // no empty strings
    if (sanitized_label == null || sanitized_label.length == 0) return;

    var translated_node = null;
    var translation = this.translate(sanitized_label);

    if (/^\s/.test(label)) translation = " " + translation;
    if (/\s$/.test(label)) translation = translation + " ";

    if (this.inline_translations_enabled) {
      translated_node = document.createElement("span");
      translated_node.innerHTML = translation;
    } else {
      translated_node = document.createTextNode(translation);
    }

    // translated_node.style.border = '1px dotted red';
    parent_node.replaceChild(translated_node, text_node);
  },

  initText: function() {
    if (Tr8n.element('tr8n_status_node')) return;

    Tr8n.log("Initializing text nodes...");

    // add node to the document so it is not processed twice
    var tr8nStatusNode = document.createElement('div');
    tr8nStatusNode.id = 'tr8n_status_node';
    tr8nStatusNode.style.display = 'none';
    document.body.appendChild(tr8nStatusNode);

    var text_nodes = [];
    var tree_walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
    while (tree_walker.nextNode()) {
      text_nodes.push(tree_walker.currentNode);
    }
 
    Tr8n.log("Found " + text_nodes.length + " text nodes");

    var disable_sentences = false;

    for (var i = 0; i < text_nodes.length; i++) {
      var current_node = text_nodes[i];
      var parent_node = current_node.parentNode;
       
      if (!parent_node) continue;

      // no scripts 
      if (parent_node.tagName == "script" || parent_node.tagName == "SCRIPT") continue;
      
      var label = current_node.nodeValue || "";

      // no html image tags
      if (label.indexOf("<img") != -1) continue;

      // no comments
      if (label.indexOf("<!-") != -1) continue;

      var sentences = label.split(". ");

      if (disable_sentences || sentences.length == 1) {
        this.translateTextNode(parent_node, current_node, label);

      } else {
        var node_replaced = false;

        for (var i=0; i<sentences.length; i++) {
          var sanitized_sentence = Tr8n.Utils.sanitizeString(sentences[i]);
          if (sanitized_sentence.length == 0) continue;

          var sanitized_sentence = sanitized_sentence + ".";
          var translated_node = document.createElement("span");
          // translated_node.style.border = '1px dotted green';
          translated_node.innerHTML = this.translate(sanitized_sentence);

          if (node_replaced) {
            parent_node.appendChild(translated_node);
          } else {
            parent_node.replaceChild(translated_node, current_node);
            node_replaced = true;
          }
          parent_node.appendChild(document.createTextNode(" "));

        }
      }
    }

    this.submitMissingTranslationKeys();
  },

  debug: function() {
    var config = {
      settings: this.options,
      translations: this.translations,
      translation_queue: this.missing_translation_keys
    };
    Tr8n.UI.Lightbox.showHTML(Tr8n.Logger.objectToHtml(config), {width:700, height:600});
  },

  logSettings: function() {
    Tr8n.Logger.clear();
    Tr8n.Logger.logObject(this.options);
  },
  
  logTranslations: function() {
    Tr8n.Logger.clear();
    Tr8n.Logger.logObject(this.translations);
  },
  
  logMissingTranslations: function() {
    Tr8n.Logger.clear();
    Tr8n.Logger.logObject(this.missing_translation_keys);
  }
  
}

function reloadTranslations() { 
  Tr8n.SDK.Proxy.initTranslations(true); 
} 

function tr(label, description, tokens, options) { 
  return Tr8n.SDK.Proxy.tr(label, description, tokens, options); 
} 

function trl(label, description, tokens, options) { 
  return Tr8n.SDK.Proxy.trl(label, description, tokens, options); 
} 
