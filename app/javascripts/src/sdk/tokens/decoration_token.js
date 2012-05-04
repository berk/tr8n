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

Tr8n.SDK.Tokens.DecorationToken = function(label, token, options) {
  this.label = label;
  this.full_name = token;
  this.options = options;
}

Tr8n.SDK.Tokens.DecorationToken.prototype = new Tr8n.SDK.Tokens.Base();

Tr8n.SDK.Tokens.DecorationToken.parse = function(label, options) {
  var tokens = label.match(/(\[\w+:[^\]]+\])/g);
  if (!tokens) return [];
  
  var objects = [];
  var uniq = {};
  for(i=0; i<tokens.length; i++) {
    if (uniq[tokens[i]]) continue;
    Tr8n.log("Registering decoration token: " + tokens[i]);
    objects.push(new Tr8n.SDK.Tokens.DecorationToken(label, tokens[i], options));
    uniq[tokens[i]] = true;
  }
  return objects;
}

Tr8n.SDK.Tokens.DecorationToken.prototype.getDecoratedValue = function() {
  if (!this.decorated_value) {
    var value = this.getFullName().replace(/[\]]/g, '');
    value = value.substring(value.indexOf(':') + 1, value.length);
    this.decorated_value = Tr8n.Utils.trim(value);
  }
  return this.decorated_value;
}

Tr8n.SDK.Tokens.DecorationToken.prototype.substitute = function(label, token_values) {
  var object = token_values[this.getName()];
  var decoration = object;
  
  if (!object || typeof object == 'object') {
    // look for the default decoration
    decoration = Tr8n.SDK.Proxy.getDecorationFor(this.getName());
    if (!decoration) {
      Tr8n.Logger.error("Default decoration is not defined for token " + this.getName());
      return label;
    }
    
    decoration = Tr8n.Utils.replaceAll(decoration, '{$0}', this.getDecoratedValue());
    if (object) {
      for (var key in object) {
        decoration = Tr8n.Utils.replaceAll(decoration, '{$' + key + '}', object[key]);
      }
    }
  } else if (typeof object == 'string') {
    decoration = Tr8n.Utils.replaceAll(decoration, '{$0}', this.getDecoratedValue());
  } else {
    Tr8n.Logger.error("Unknown type of decoration token " + this.getFullName());
    return label;
  }
  
  return Tr8n.Utils.replaceAll(label, this.getFullName(), decoration);
}
