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

class Tr8n::Api::V1::LanguageController < Tr8n::Api::V1::BaseController

  # for ssl access to the translator - using ssl_requirement plugin  
  ssl_allowed :translate  if respond_to?(:ssl_allowed)

  def index
    if params[:locale].blank?
      return render_error("Locale must be provided")
    end

    lang = Tr8n::Language.for(params[:locale])
    unless lang
      return render_error("Unknown language locale")
    end

    render_response(lang)
  end

  def all
    render_response(Tr8n::Language.order('english_name asc').all)
  end

  def enabled
    render_response(Tr8n::Language.enabled_languages)
  end

  def featured
    render_response(Tr8n::Language.featured_languages)
  end
  
  # deprecated - has been moved to proxy API  
  def translate
    domain = Tr8n::TranslationDomain.find_or_create(request.env['HTTP_REFERER'])
    language = Tr8n::Language.for(params[:language] || params[:locale]) || tr8n_current_language
    Tr8n::Config.set_application(domain.application)
    Tr8n::Config.set_language(language)

    return render_response(translate_phrase(language, params, {:source => source, :api => :translate, :application => domain.application})) if params[:label]
    
    # API signature
    # {:source => "", :language => "", :phrases => [{:label => ""}]}
    
    # get all phrases for the specified source 
    # this can be used by a parallel application or a JavaScript Client SDK that needs to build a page cache
    if params[:batch] == "true" or params[:cache] == "true"
      if params[:sources].blank? and params[:source].blank?
        return render_response({"error" => "No source/sources have been provided for the batch request."})
      end
      
      source_names = params[:sources] || [params[:source]]
      sources = Tr8n::TranslationSource.find(:all, :conditions => ["source in (?)", source_names])
      source_ids = sources.collect{|source| source.id}
      
      if source_ids.empty?
        conditions = ["1=2"]
      else
        conditions = ["(id in (select distinct(translation_key_id) from tr8n_translation_key_sources where translation_source_id in (?)))"]
        conditions << source_ids.uniq
      end
      
      translations = []
      Tr8n::TranslationKey.find(:all, :conditions => conditions).each_with_index do |tkey, index|
        trn = tkey.translate(language, {}, {:source => source, :url => source, :api => :cache})
        translations << trn 
      end
      
      return render_response({:phrases => translations})
    elsif params[:phrases]

      if params[:phrases].is_a?(String)
        phrases = []
        begin
          phrases = HashWithIndifferentAccess.new({:data => JSON.parse(params[:phrases])})[:data]
        rescue Exception => ex
          return render_error("Invalid request. JSON parsing failed: #{ex.message}")
        end
      else
        phrases = params[:phrases]
      end

      translations = []
      phrases.each do |phrase|
        phrase = {:label => phrase} if phrase.is_a?(String)
        language = phrase[:locale].blank? ? Tr8n::Config.default_language.locale : (Tr8n::Language.for(phrase[:locale]) || Tr8n::Language.find_by_google_key(phrase[:locale]))

        translations << translate_phrase(language, phrase, {:source => source, :url => request.env['HTTP_REFERER'], :api => :translate, :locale => language.locale, :application => domain.application})
      end

      return render_response({:phrases => translations})    
    end
    
    render_response(:phrases => [])
  rescue Tr8n::KeyRegistrationException => ex
    render_response({"error" => ex.message})
  end

private

  def translate_phrase(language, phrase, opts = {})    
    return "" if phrase[:label].strip.blank?
    translation_key = Tr8n::TranslationKey.find_or_create(phrase[:label], phrase[:description], opts)
    translation_key.translate(language, {}, opts)
  end
  
end