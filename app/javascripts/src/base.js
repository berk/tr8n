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

document.createElement('tr8n');
document.createElement('tml');

var Tr8n = Tr8n || {
  element:function(element_id) {
    if (typeof element_id == 'string') return document.getElementById(element_id);
    return element_id;
  },

  value:function(element_id) {
    return Tr8n.element(element_id).value;
  },

  postMessage: function(msg, origin) {
    if (top.Tr8n) {
      top.Tr8n.onMessage(msg);
    } else {
      if (window.postMessage) {
        window.postMessage(msg, origin);
      } else {
        alert("Failed to deliver a tr8n message: " + msg + " to origin: " + origin);
      }       
    }
  },

  onMessage:function(event) {
    var msg = '';
    if (typeof event == 'string') {
      msg = event;
    } else {
      msg = event.data;
    }

    var elements = msg.split(':');
    if (elements[0] != 'tr8n') {
      alert("Received an unkown message: " + msg);
      return;
    }

    if (elements[1] == 'reload') {
      window.location.reload();
      return;
    }

    if (elements[1] == 'translation') {
      if (elements[2] == 'report') {
        tr8nTranslator.hide();
        tr8nLightbox.show('/tr8n/translator/lb_report?translation_id=' + elements[3], {width:600, height:360});
        return;
      } 
    }

    if (elements[1] == 'translator') {
      if (elements[2] == 'resize') {
        tr8nTranslator.resize(elements[3]);
        return;
      } 

      if (elements[2] == 'hide') {
        tr8nTranslator.hide();
        return;
      }
    } 

    alert("Unknown message: " + msg);
  }

};