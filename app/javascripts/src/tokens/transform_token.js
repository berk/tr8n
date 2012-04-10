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
    this.name = Tr8n.Utils.trim(this.getDeclaredName().split('|')[0].split(':')[0]); 
  }
  return this.name;
}

Tr8n.Proxy.TransformToken.prototype.getPipedParams = function() {
  if (!this.piped_params) {
    var temp = this.getDeclaredName().split('|');
    temp = temp[temp.length - 1].split(",");
    this.piped_params = [];
    for (i=0; i<temp.length; i++) {
      this.piped_params.push(Tr8n.Utils.trim(temp[i]));
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
  
  return Tr8n.Utils.replaceAll(label, this.getFullName(), transform_value);
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