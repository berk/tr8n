# encoding: utf-8
#--
# Copyright (c) 2010-2011 Michael Berkovich
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module Tr8n
  module KeyboardMapping

    def self.current_1_36
      [{:key => "Arabic", :name => "Arabic"},
      {:key => "Armenian East", :name => "Armenian"},
      {:key => "Armenian West", :name => "Armenian"},
      {:key => "Belarusian", :name => "Belarusian"},
      {:key => "Belgian", :name => "Belgian"},
      {:key => "Bengali", :name => "Bengali"},
      {:key => "Bulgarian Ph", :name => "Bulgarian"},
      {:key => "Burmese", :name => "Burmese"},
      {:key => "Czech", :name => "Czech"},
      {:key => "Danish", :name => "Danish"},
      {:key => "Dutch", :name => "Dutch"},
      {:key => "Dvorak", :name => "Dvorak"},
      {:key => "Farsi", :name => "Farsi"},
      {:key => "French", :name => "French"},
      {:key => "German", :name => "German"},
      {:key => "Greek", :name => "Greek"},
      {:key => "Hebrew", :name => "Hebrew"},
      {:key => "Hindi", :name => "Hindi"},
      {:key => "Hungarian", :name => "Hungarian"},
      {:key => "Italian", :name => "Italian"},
      {:key => "日本語", :name => "Japanese"},
      {:key => "Kazakh", :name => "Kazakh"},
      {:key => "Lithuanian", :name => "Lithuanian"},
      {:key => "Macedonian", :name => "Macedonian"},
      {:key => "Norwegian", :name => "Norwegian"},
      {:key => "Numpad", :name => "Numpad"},
      {:key => "Pashto", :name => "Pashto"},
      {:key => "Pinyin", :name => "Pinyin"},
      {:key => "Polish Prog", :name => "Polish"},
      {:key => "Portuguese Br", :name => "Portuguese"},
      {:key => "Portuguese Pt", :name => "Portuguese"},
      {:key => "Romanian", :name => "Romanian"},
      {:key => "Russian", :name => "Russian"},
      {:key => "SerbianCyr", :name => "Serbian"},
      {:key => "SerbianLat", :name => "Serbian"},
      {:key => "Slovak", :name => "Slovak"},
      {:key => "Slovenian", :name => "Slovenian"},
      {:key => "Spanish Es", :name => "Spanish"},
      {:key => "Swedish", :name => "Swedish"},
      {:key => "Turkish-F", :name => "Turkish"},
      {:key => "Turkish-Q", :name => "Turkish"},
      {:key => "UK", :name => "English"},
      {:key => "Ukrainian", :name => "Ukrainian"},
      {:key => "US", :name => "English"},
      {:key => "US Int'l", :name => "US Int'l"}].each do |pair|
        return pair[:key] if pair[:name] == Tr8n::Config.current_language.english_name.split(" ").first
      end
    
      return "US Int'l"
    end  
  
    def self.current_1_44
      [
        {:key => '\u0627\u0644\u0639\u0631\u0628\u064a\u0629', :name => 'Arabic', :locale => ''},
        {:key => '\u0985\u09b8\u09ae\u09c0\u09df\u09be', :name => 'Assamese', :locale => ''},
        {:key => '\u0410\u0437\u04d9\u0440\u0431\u0430\u0458\u04b9\u0430\u043d\u04b9\u0430', :name => 'Azerbaijani Cyrillic', :locale => ''},
        {:key => 'Az\u0259rbaycanca', :name => 'Azerbaijani Latin', :locale => ''},
        {:key => '\u0411\u0435\u043b\u0430\u0440\u0443\u0441\u043a\u0430\u044f', :name => 'Belarusian', :locale => ''},
        {:key => 'Belgische / Belge', :name => 'Belgian', :locale => ''},
        {:key => '\u0411\u044a\u043b\u0433\u0430\u0440\u0441\u043a\u0438 \u0424\u043e\u043d\u0435\u0442\u0438\u0447\u0435\u043d', :name => 'Bulgarian Phonetic', :locale => ''},
        {:key => '\u0411\u044a\u043b\u0433\u0430\u0440\u0441\u043a\u0438', :name => 'Bulgarian BDS', :locale => ''},
        {:key => '\u09ac\u09be\u0982\u09b2\u09be', :name => 'Bengali', :locale => ''},
        {:key => 'Bosanski', :name => 'Bosnian', :locale => ''},
        {:key => 'Canadienne-fran\u00e7aise', :name => 'Canadian French', :locale => ''},
        {:key => '\u010cesky', :name => 'Czech', :locale => ''},
        {:key => 'Dansk', :name => 'Danish', :locale => ''},
        {:key => 'Deutsch', :name => 'German', :locale => ''},
        {:key => 'Dingbats', :name => 'Dingbats', :locale => ''},
        {:key => '\u078b\u07a8\u0788\u07ac\u0780\u07a8\u0784\u07a6\u0790\u07b0', :name => 'Divehi', :locale => ''},
        {:key => 'Dvorak', :name => 'Dvorak', :locale => ''},
        {:key => '\u0395\u03bb\u03bb\u03b7\u03bd\u03b9\u03ba\u03ac', :name => 'Greek', :locale => ''},
        {:key => 'Eesti', :name => 'Estonian', :locale => ''},
        {:key => 'Espa\u00f1ol', :name => 'Spanish', :locale => ''},
        {:key => '\u062f\u0631\u06cc', :name => 'Dari', :locale => ''},
        {:key => '\u0641\u0627\u0631\u0633\u06cc', :name => 'Farsi', :locale => ''},
        {:key => 'F\u00f8royskt', :name => 'Faeroese', :locale => ''},
        {:key => 'Fran\u00e7ais', :name => 'French', :locale => ''},
        {:key => 'Gaeilge', :name => 'Irish / Gaelic', :locale => ''},
        {:key => '\u0a97\u0ac1\u0a9c\u0ab0\u0abe\u0aa4\u0ac0', :name => 'Gujarati', :locale => ''},
        {:key => '\u05e2\u05d1\u05e8\u05d9\u05ea', :name => 'Hebrew', :locale => ''},
        {:key => '\u0939\u093f\u0902\u0926\u0940', :name => 'Hindi', :locale => ''},
        {:key => 'Hrvatski', :name => 'Croatian', :locale => ''},
        {:key => '\u0540\u0561\u0575\u0565\u0580\u0565\u0576 \u0561\u0580\u0565\u0582\u0574\u0578\u0582\u057f\u0584', :name => 'Western Armenian', :locale => ''},
        {:key => '\u0540\u0561\u0575\u0565\u0580\u0565\u0576 \u0561\u0580\u0565\u0582\u0565\u056c\u0584', :name => 'Eastern Armenian', :locale => ''},
        {:key => '\u00cdslenska', :name => 'Icelandic', :locale => ''},
        {:key => 'Italiano', :name => 'Italian', :locale => ''},
        {:key => '\u65e5\u672c\u8a9e', :name => 'Japanese Hiragana/Katakana', :locale => ''},
        {:key => '\u10e5\u10d0\u10e0\u10d7\u10e3\u10da\u10d8', :name => 'Georgian', :locale => ''},
        {:key => '\u049a\u0430\u0437\u0430\u049b\u0448\u0430', :name => 'Kazakh', :locale => ''},
        {:key => '\u1797\u17b6\u179f\u17b6\u1781\u17d2\u1798\u17c2\u179a', :name => 'Khmer', :locale => ''},
        {:key => '\u0c95\u0ca8\u0ccd\u0ca8\u0ca1', :name => 'Kannada', :locale => ''},
        {:key => '\ud55c\uad6d\uc5b4', :name => 'Korean', :locale => ''},
        {:key => 'Kurd\u00ee', :name => 'Kurdish', :locale => ''},
        {:key => '\u041a\u044b\u0440\u0433\u044b\u0437\u0447\u0430', :name => 'Kyrgyz', :locale => ''},
        {:key => 'Latvie\u0161u', :name => 'Latvian', :locale => ''},
        {:key => 'Lietuvi\u0173', :name => 'Lithuanian', :locale => ''},
        {:key => 'Magyar', :name => 'Hungarian', :locale => ''},
        {:key => 'Malti', :name => 'Maltese 48', :locale => ''},
        {:key => '\u041c\u0430\u043a\u0435\u0434\u043e\u043d\u0441\u043a\u0438', :name => 'Macedonian Cyrillic', :locale => ''},
        {:key => '\u0d2e\u0d32\u0d2f\u0d3e\u0d33\u0d02', :name => 'Malayalam', :locale => ''},
        {:key => 'Misc. Symbols', :name => 'Misc. Symbols', :locale => ''},
        {:key => '\u041c\u043e\u043d\u0433\u043e\u043b', :name => 'Mongolian Cyrillic', :locale => ''},
        {:key => '\u1019\u103c\u1014\u103a\u1019\u102c\u1018\u102c\u101e\u102c', :name => 'Burmese', :locale => ''},
        {:key => 'Nederlands', :name => 'Dutch', :locale => ''},
        {:key => 'Norsk', :name => 'Norwegian', :locale => ''},
        {:key => '\u067e\u069a\u062a\u0648', :name => 'Pashto', :locale => ''},
        {:key => '\u0a2a\u0a70\u0a1c\u0a3e\u0a2c\u0a40', :name => 'Punjabi (Gurmukhi)', :locale => ''},
        {:key => '\u62fc\u97f3 (Pinyin)', :name => 'Pinyin', :locale => ''},
        {:key => 'Polski', :name => 'Polish (214)', :locale => ''},
        {:key => 'Polski Programisty', :name => 'Polish Programmers', :locale => ''},
        {:key => 'Portugu\u00eas Brasileiro', :name => 'Portuguese (Brazil)', :locale => ''},
        {:key => 'Portugu\u00eas', :name => 'Portuguese', :locale => ''},
        {:key => 'Rom\u00e2n\u0103', :name => 'Romanian', :locale => ''},
        {:key => '\u0420\u0443\u0441\u0441\u043a\u0438\u0439', :name => 'Russian', :locale => ''},
        {:key => 'Schweizerdeutsch', :name => 'Swiss German', :locale => ''},
        {:key => 'Shqip', :name => 'Albanian', :locale => ''},
        {:key => 'Sloven\u010dina', :name => 'Slovak', :locale => ''},
        {:key => 'Sloven\u0161\u010dina', :name => 'Slovenian', :locale => ''},
        {:key => '\u0441\u0440\u043f\u0441\u043a\u0438', :name => 'Serbian Cyrillic', :locale => ''},
        {:key => 'Srpski', :name => 'Serbian Latin', :locale => ''},
        {:key => 'Suomi', :name => 'Finnish', :locale => ''},
        {:key => 'Svenska', :name => 'Swedish', :locale => ''},
        {:key => 'Swiss Fran\u00e7ais', :name => 'Swiss French', :locale => ''},
        {:key => '\u0723\u0718\u072a\u071d\u071d\u0710', :name => 'Syriac', :locale => ''},
        {:key => '\u0ba4\u0bae\u0bbf\u0bb4\u0bcd', :name => 'Tamil', :locale => ''},
        {:key => '\u0c24\u0c46\u0c32\u0c41\u0c17\u0c41', :name => 'Telugu', :locale => ''},
        {:key => 'Ti\u1ebfng Vi\u1ec7t', :name => 'Vietnamese', :locale => ''},
        {:key => '\u0e44\u0e17\u0e22 Kedmanee', :name => 'Thai Kedmane', :locale => ''},
        {:key => '\u0e44\u0e17\u0e22 Pattachote', :name => 'Thai Pattachote', :locale => ''},
        {:key => '\u0422\u0430\u0442\u0430\u0440\u0447\u0430', :name => 'Tatar', :locale => ''},
        {:key => 'T\u00fcrk\u00e7e F', :name => 'Turkish F', :locale => ''},
        {:key => 'T\u00fcrk\u00e7e Q', :name => 'Turkish Q', :locale => ''},
        {:key => '\u0423\u043a\u0440\u0430\u0457\u043d\u0441\u044c\u043a\u0430', :name => 'Ukrainian', :locale => ''},
        {:key => 'United Kingdom', :name => 'United Kingdom', :locale => ''},
        {:key => '\u0627\u0631\u062f\u0648', :name => 'Urdu', :locale => ''},
        {:key => 'US Standard', :name => 'US Standard', :locale => ''},
        {:key => 'US International', :name => 'US International', :locale => ''},
        {:key => '\u040e\u0437\u0431\u0435\u043a\u0447\u0430', :name => 'Uzbek Cyrillic', :locale => ''},
        {:key => '\u4e2d\u6587\u6ce8\u97f3\u7b26\u53f7', :name => 'Chinese Bopomofo IME', :locale => ''},
        {:key => '\u4e2d\u6587\u4ed3\u9889\u8f93\u5165\u6cd5', :name => 'Chinese Cangjie IME', :locale => ''}
      ].each do |kb|
        return kb[:key] if kb[:name].index(Tr8n::Config.current_language.english_name.split(" ").first)
      end
    
      return "US International"
    end    
  end
end
