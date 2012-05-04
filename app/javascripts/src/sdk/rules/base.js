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

Tr8n.SDK.Rules.Base = function() {

}

Tr8n.SDK.Rules.Base.prototype = {

  getTokenValue: function(token_name, token_values) {
    var object = token_values[token_name];
    if (object == null) { 
      Tr8n.Logger.error("Invalid token value for token: " + token_name);
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
      results.push(Tr8n.Utils.trim(arr[index]));
    }   
    return results;
  }
}
