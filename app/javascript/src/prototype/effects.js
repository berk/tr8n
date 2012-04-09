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

/****************************************************************************
**** Tr8n Prototype Effects Functions
****************************************************************************/

Tr8n.Effects = {
  hide: function(element_id) {
    $(element_id).hide();
  },
  show: function(element_id) {
    $(element_id).show();
  },
  blindUp: function(element_id) {
    Effect.BlindUp(element_id, { duration: 0.2 });    
  },
  blindDown: function(element_id) {
    Effect.BlindDown(element_id, { duration: 0.2 });    
  },
  appear: function(element_id) {
    Effect.Appear(element_id, { duration: 0.2 });
  },
  fade: function(element_id) {
    Effect.Fade(element_id, { duration: 0.2 });
  },
  submit: function(element_id) {
    $(element_id).submit();
  },
  focus: function(element_id) {
    $(element_id).focus();
  },  
  scrollTo: function(element_id) {
    var theElement = $(element_id);
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

