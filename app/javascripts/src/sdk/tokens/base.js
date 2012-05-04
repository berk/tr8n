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

Tr8n.SDK.Tokens.Base = function() {
}

Tr8n.SDK.Tokens.Base.prototype = {
  
  getExpression: function() {
    // must be implemented by the extending class
    return null;
  },

  parse: function(label, options) {
    if (this.getExpression() == null) {
      Tr8n.Logger.error("Token expression must be provided");
    }
      
    var tokens = label.match(this.getExpression());
    if (!tokens) return [];
    
    var objects = [];
    var uniq = {};
    for(i=0; i<tokens.length; i++) {
      if (uniq[tokens[i]]) continue;
      Tr8n.log("Registering data token: " + tokens[i]);
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
      this.name = Tr8n.Utils.trim(this.getDeclaredName().split(':')[0]); 
    }
    return this.name;
  },

  getLanguageRule: function() {
    
    return null;
  },

  substitute: function(label, token_values) {
    var value = token_values[this.getName()];
    
    if (value == null) {
      Tr8n.Logger.error("Value for token: " + this.getFullName() + " was not provided");
      return label;
    }

    return Tr8n.Utils.replaceAll(label, this.getFullName(), this.getTokenValue(value)); 
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
        this.language_rule = Tr8n.SDK.Proxy.getLanguageRuleForType(this.getType()); 
      } else {
        this.language_rule = Tr8n.SDK.Proxy.getLanguageRuleForTokenSuffix(this.getSuffix());
      }
    }
    return this.language_rule;
  }
}