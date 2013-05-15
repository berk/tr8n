#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8nhub.com
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
    render(:partial => "/tr8n/common/js/boot", :formats => [:js], :locals => {:uri => URI.parse(request.url)}, :content_type => "text/javascript")
  end

  def init
    script = []

    opts = {}

    opts[:scheduler_interval]         = Tr8n::Config.default_client_interval
    opts[:enable_inline_translations] = (Tr8n::Config.current_user_is_translator? and Tr8n::Config.current_translator.enable_inline_translations? and (not Tr8n::Config.current_language.default?))
    opts[:default_decorations]        = Tr8n::Config.default_decoration_tokens
    opts[:default_tokens]             = Tr8n::Config.default_data_tokens
    opts[:locale]                     = Tr8n::Config.current_language.locale

    if params[:text]
      opts[:enable_text]              = (not params[:text].blank?)
    else
      opts[:enable_tml]               = (not params[:tml].blank?) and Tr8n::Config.enable_tml?
    end

    opts[:rules]                      = { 
      :number => Tr8n::Config.rules_engine[:numeric_rule],      :gender => Tr8n::Config.rules_engine[:gender_rule],
      :list   => Tr8n::Config.rules_engine[:gender_list_rule],  :date   => Tr8n::Config.rules_engine[:date_rule]
    }

    domain = Tr8n::TranslationDomain.find_or_create(request.env['HTTP_REFERER'])
    Tr8n::Config.set_application(domain.application)

    source = params[:source] || Tr8n::TranslationSource.normalize_source(request.env['HTTP_REFERER']) || 'undefined'
    Tr8n::Config.set_source(Tr8n::TranslationSource.find_or_create(source, domain.application))

    language = Tr8n::Language.for(params[:language] || params[:locale]) || Tr8n::Config.current_language
    Tr8n::Config.set_language(language)

    source_ids = Tr8n::TranslationSource.where(:source => source).all.collect{|src| src.id}
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

    render(:partial => "/tr8n/common/js/init", :formats => [:js], :locals => {:uri => URI.parse(request.url), :opts => opts, :translations => translations, :source => source.to_s}, :content_type => "text/javascript")
  end
  
end