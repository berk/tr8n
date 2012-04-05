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

Tr8n.Tml.Label = function(node, proxy) {
  this.node = node;
  this.label = "";
  this.description = "";
  this.tokens = {};
  this.options = {};
  this.proxy = proxy;

  for (var i=0; i < this.node.childNodes.length; i++) {
    var childNode = this.node.childNodes[i];

    // text should just be added to the label
    if (childNode.nodeType == 3) {
      this.label = this.label + " " + Tr8n.Utils.trim(childNode.nodeValue);
    } else if (childNode.nodeName == "TML:TOKEN") {
      var token = new Tr8n.Tml.Token(childNode, this.tokens);
      this.label = Tr8n.Utils.trim(this.label) + " " + token.toTokenString();
    }
    
  }

  this.description = this.node.attributes['desc'] || this.node.attributes['description']; 
  this.description = this.description ? this.description.value : null;

  this.label = this.label.replace(/\n/g, '');
  this.label = Tr8n.Utils.trim(this.label);

  // console.log(this.label + " : " + this.description);
}

Tr8n.Tml.Label.prototype = {
  translate: function() {
    this.node.innerHTML = this.proxy.translate(this.label, this.description, this.tokens, this.options);
  }
}
