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
