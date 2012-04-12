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

Tr8n.Tml = Tr8n.Tml || {};

Tr8n.Tml.Token = function(node, tokens) {
  this.node = node;
  
  this.type = this.node.attributes['type'];
  this.type = this.type ? this.type.value : 'data';

  this.name = this.node.attributes['name'];
  this.name = this.name ? this.name.value : 'unknown';
  this.name = this.name.toLowerCase();

  this.context = this.node.attributes['context'];
  this.context = this.context ? this.context.value : null;

  this.content = "";

  for (var i=0; i < this.node.childNodes.length; i++) {
    var childNode = this.node.childNodes[i];
    // console.log(childNode.nodeType + " " + childNode.nodeValue);
    var token_type = this.node.attributes['type'] ? this.node.attributes['type'].nodeValue : 'data';
    // console.log(this.name + " " + token_type);

    if (childNode.nodeType == 3) {
      // text should just be added to the label
      // <tml:label>You have <tml:token type="data" name="count" context="number">2</tml:token> messages.</tml:label>    
      
      if (node.attributes['context'] && node.attributes['context'].nodeValue == 'gender') {
        tokens[this.name] = {subject: node.attributes['value'].nodeValue, value: Tr8n.Utils.trim(childNode.nodeValue)};
      } else {
        tokens[this.name] = Tr8n.Utils.trim(childNode.nodeValue);
      }

    } else {
      // the first element inside the token must be a decoration span, bold, etc...
      // <tml:label>Hello 
      //   <tml:token type="decoration" name="span">
      //     <span style='color:brown;font-weight:bold;'>
      //       World
      //     </span>
      //   </tml:token> 
      // </tml:label>

      var html_tag = childNode.nodeName.toLowerCase();
      var attributes = [];
      if (childNode.attributes['style']) {
        attributes.push("style='" + childNode.attributes['style'].nodeValue + "'");
      }
      if (childNode.attributes['class']) {
        attributes.push("class='" + childNode.attributes['class'].nodeValue + "'");
      }

      tokens[this.name] = "<" + html_tag + " " + attributes.join(' ') + ">{$0}</" + html_tag + ">";

      // console.log(this.name + " has value of " + tokens[this.name]);

      this.content = "";

      for (var j=0; j<childNode.childNodes.length; j++) {
        var grandChildNode = childNode.childNodes[j];
        if (grandChildNode.nodeType == 3) {
          this.content = Tr8n.Utils.trim(this.content) + " " + Tr8n.Utils.trim(grandChildNode.nodeValue);
        } else if (grandChildNode.nodeName == "TML:TOKEN") {
          var token = new Tr8n.Tml.Token(grandChildNode, tokens);
          this.content = Tr8n.Utils.trim(this.content) + " " + token.toTokenString();
        }    
      }
    }
  }

  this.content = this.content.replace(/\n/g, '');
  this.content = Tr8n.Utils.trim(this.content);
}

Tr8n.Tml.Token.prototype = {
  toTokenString: function() {
    if (this.type == "data") {
      // TODO: we may need to add dependencies here: gender, number and language cases
      return "{" + this.name + "}";
    } else {
      return "[" + this.name + ": " + this.content + "]";
    }
  }
}