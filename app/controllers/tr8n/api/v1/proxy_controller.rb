#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8n.net
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

class Tr8n::Api::V1::ProxyController < Tr8n::Api::V1::BaseController

  def boot
    uri = URI.parse(request.url)

    script = []
    script << "function addTr8nCSS(doc, src) {"
    script << "var css = doc.createElement('link');"
    script << "css.setAttribute('type', 'application/javascript');"
    script << "css.setAttribute('href', src);"
    script << "css.setAttribute('type', 'text/css');"
    script << "css.setAttribute('rel', 'stylesheet');"
    script << "css.setAttribute('media', 'screen');"
    script << "doc.getElementsByTagName('head')[0].appendChild(css);"
    script << "};"
    script << "function addTr8nScript(doc, id, src, onload) {"
    script << "var script = doc.createElement('script');"
    script << "script.setAttribute('id', id);"
    script << "script.setAttribute('type', 'application/javascript');"
    script << "script.setAttribute('src', src);"
    script << "script.setAttribute('charset', 'UTF-8');"
    script << "if (onload) script.onload = onload;"
    script << "doc.getElementsByTagName('head')[0].appendChild(script);"
    script << "};"
    script << "(function(doc) {if (doc.getElementById('tr8n-jssdk')) return;"

    uri.path = "/assets/tr8n/tr8n.css"
    script << "addTr8nCSS(doc, '#{uri.to_s}');"

    if params[:debug]
      uri.path = "/assets/tr8n/tr8n.js"    
    else
      uri.path = "/assets/tr8n/tr8n-compiled.js"    
    end  
    script << "addTr8nScript(doc, 'tr8n-jssdk', '#{uri.to_s}', function() {"

    uri.path = "/tr8n/api/v1/proxy/init.js"    
    script << "addTr8nScript(doc, 'tr8n-proxy', '#{uri.to_s}', function() {});"

    script << "});}(document));"
    render(:text => script.join(''), :content_type => "text/javascript")
  end

  def init
    script = []

    opts = {}
    opts[:scheduler_interval]         = Tr8n::Config.default_client_interval
    opts[:enable_inline_translations] = (Tr8n::Config.current_user_is_translator? and Tr8n::Config.current_translator.enable_inline_translations? and (not Tr8n::Config.current_language.default?))
    opts[:default_decorations]        = Tr8n::Config.default_decoration_tokens
    opts[:default_tokens]             = Tr8n::Config.default_data_tokens
    opts[:locale]                     = Tr8n::Config.current_language.locale

    if params[:ext]
      opts[:enable_text]              = true
    else
      opts[:enable_tml]               = Tr8n::Config.enable_tml?
    end

    opts[:rules]                      = { 
      :number => Tr8n::Config.rules_engine[:numeric_rule],      :gender => Tr8n::Config.rules_engine[:gender_rule],
      :list   => Tr8n::Config.rules_engine[:gender_list_rule],  :date   => Tr8n::Config.rules_engine[:date_rule]
    }

    uri = URI.parse(request.url)
    host_url = "#{uri.scheme}://#{uri.host}#{uri.port ? ":#{uri.port}" : ''}"

    script << "Tr8n.host = '#{host_url}';"

    script << "Tr8n.SDK.Proxy.init(#{opts.to_json});"

    params[:source] ||= request.env['HTTP_REFERER']

    source_ids = Tr8n::TranslationSource.where(:source => params[:source]).all.collect{|source| source.id}
    
    if source_ids.empty?
      conditions = ["1=2"]
    else
      conditions = ["(id in (select distinct(translation_key_id) from tr8n_translation_key_sources where translation_source_id in (?)))"]
      conditions << source_ids.uniq
    end

    translations = []
    Tr8n::TranslationKey.where(conditions).all.each do |tkey|
      translations << tkey.translate(Tr8n::Config.current_language, {}, {:api => true})
    end

    script << "Tr8n.SDK.Proxy.registerTranslationKeys(#{translations.to_json});"

    if Tr8n::Config.enable_google_suggestions? and Tr8n::Config.current_user_is_translator?
      script << "Tr8n.google_api_key = '#{Tr8n::Config.google_api_key}';"
    end

    if Tr8n::Config.enable_keyboard_shortcuts?
      Tr8n::Config.default_shortcuts.each do |key, data|       
        script << "shortcut.add('#{key}', function() {#{data['script']}});"
      end
    end

    render(:text => script.join(''), :content_type => "text/javascript")
  end
  
end