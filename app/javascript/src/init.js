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

var tr8nTranslator = null;
var tr8nLanguageSelector = null;
var tr8nLightbox = null;
var tr8nLanguageCaseManager = null;

function initializeTr8n() {
  var setup = function() {
    tr8nTranslator            = new Tr8n.Translator();
    tr8nLanguageSelector      = new Tr8n.LanguageSelector();
    tr8nLightbox              = new Tr8n.Lightbox();
    tr8nLanguageCaseManager   = new Tr8n.LanguageCaseManager();

    Tr8n.Utils.addEvent(document, "keyup", function(event) {
      if (event.keyCode == 27) { // Capture Esc key
        tr8nTranslator.hide();
        tr8nLanguageSelector.hide();
        tr8nLightbox.hide();
        tr8nLanguageCaseManager.hide();
      }
    });
  }

  Tr8n.Utils.addEvent(window, 'load', setup);
}