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

Tr8n.Effects = {
  toggle: function(element_id) {
    if (Tr8n.element(element_id).style.display == "none")
      Tr8n.element(element_id).show();
    else
      Tr8n.element(element_id).hide();
  },
  hide: function(element_id) {
    Tr8n.element(element_id).style.display = "none";
  },
  show: function(element_id) {
    var style = (Tr8n.element(element_id).tagName == "SPAN") ? "inline" : "block";
    Tr8n.element(element_id).style.display = style;
  },
  blindUp: function(element_id) {
    Tr8n.Effects.hide(element_id);
  },
  blindDown: function(element_id) {
    Tr8n.Effects.show(element_id);
  },
  appear: function(element_id) {
    Tr8n.Effects.show(element_id);
  },
  fade: function(element_id) {
    Tr8n.Effects.hide(element_id);
  },
  submit: function(element_id) {
    Tr8n.element(element_id).submit();
  },
  focus: function(element_id) {
    Tr8n.element(element_id).focus();
  },
  scrollTo: function(element_id) {
    var theElement = Tr8n.element(element_id);
    var selectedPosX = 0;
    var selectedPosY = 0;
    while(theElement != null){
      selectedPosX += theElement.offsetLeft;
      selectedPosY += theElement.offsetTop;
      theElement = theElement.offsetParent;
    }
    window.scrollTo(selectedPosX,selectedPosY);
  }
}