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

Tr8n.SDK.Rules.NumericRule = function(definition, options) {
  this.definition = definition;
  this.options = options;
}

Tr8n.SDK.Rules.NumericRule.prototype = new Tr8n.SDK.Rules.Base();

/////////////////////////////////////////////////////////////////////////////////
// English based transform method
// FORM: [singular, plural]
// {count | message, messages}
// {count | person, people}
/////////////////////////////////////////////////////////////////////////////////

Tr8n.SDK.Rules.NumericRule.transform = function(count, values) {
  if (count == 1) return values[0];
  if (values.length == 2) {
    return values[1];
  }
  return values[0].pluralize();  
}

/////////////////////////////////////////////////////////////////////////////////
//  "count":{"value1":"2,3,4","operator":"and","type":"number","multipart":true,"part2":"does_not_end_in","value2":"12,13,14","part1":"ends_in"}
/////////////////////////////////////////////////////////////////////////////////

Tr8n.SDK.Rules.NumericRule.prototype.evaluate = function(token_name, token_values) {
  
  var object = this.getTokenValue(token_name, token_values);
  if (object == null) return false;

  var token_value = null;
  if (typeof object == 'string' || typeof object == 'number') {
    token_value = "" + object;
  } else if (typeof object == 'object' && object['subject']) { 
    token_value = "" + object['subject'];
  } else {
    Tr8n.Logger.error("Invalid token value for numeric token: " + token_name);
    return false;
  }
  
  Tr8n.log("Rule value: '" + token_value + "' for definition: " + this.getDefinitionDescription());
  
  var result1 = this.evaluatePartialRule(token_value, this.definition['part1'], this.sanitizeArrayValue(this.definition['value1']));
  if (this.definition['multipart'] == 'false' || this.definition['multipart'] == false || this.definition['multipart'] == null) return result1;
  Tr8n.log("Part 1: " + result1 + " Processing part 2...");

  var result2 = this.evaluatePartialRule(token_value, this.definition['part2'], this.sanitizeArrayValue(this.definition['value2']));
  Tr8n.log("Part 2: " + result2 + " Completing evaluation...");
  
  if (this.definition['operator'] == "or") return (result1 || result2);
  return (result1 && result2);
}


Tr8n.SDK.Rules.NumericRule.prototype.evaluatePartialRule = function(token_value, name, values) {
  if (name == 'is') {
    if (Tr8n.Utils.indexOf(values, token_value)!=-1) return true; 
    return false;
  }
  if (name == 'is_not') {
    if (Tr8n.Utils.indexOf(values, token_value)==-1) return true; 
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