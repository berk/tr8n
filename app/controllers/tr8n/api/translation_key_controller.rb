#--
# Copyright (c) 2010-2013 Michael Berkovich, tr8nhub.com
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

class Tr8n::Api::TranslationKeyController < Tr8n::Api::BaseController

  def index
    ensure_get

    unless params[:id].blank?
      tkey = Tr8n::TranslationKey.find_by_id(params[:id])
      raise Tr8n::Exception.new("Translation key not found") unless tkey
      return render_response(tkey)
    end

    unless params[:key].blank?
      tkey = Tr8n::TranslationKey.find_by_key(params[:key])
      raise Tr8n::Exception.new("Translation key not found") unless tkey
      return render_response(tkey)
    end

    unless params[:ids].blank?
      tkeys = Tr8n::TranslationKey.where("id in (?)", params[:ids]).all
      return render_response(tkeys)
    end

    unless params[:keys].blank?
      tkeys = Tr8n::TranslationKey.where("key in (?)", params[:keys]).all
      return render_response(tkeys)
    end

    raise Tr8n::Exception.new("Id(s) or key(s) must be provided")
  end

  def lookup
    ensure_get

    if params[:query].nil?
      return render_error("Query must be provided")
    end

    params[:query] = params[:query].strip
    if params[:query].length < 3
      return render_error("Query must be at least 3 characters long")
    end

    results = Tr8n::TranslationKey.where("tr8n_translation_keys.label like ?", "%#{params[:query]}%")
    results = results.order("created_at desc").limit(limit).offset(offset).all
    render_response(results)
  end

  def delete
    ensure_post 
    ensure_application_admin

    if params[:keys]
      tkeys = Tr8n::TranslationKey.where("key in (?)", params[:keys].split(",").collect{|k| k.strip}).all
    elsif params[:ids]
      tkeys = Tr8n::TranslationKey.where("id in (?)", params[:ids].split(",").collect{|k| k.strip}).all
    end

    tkeys.each do |tkey|
      tkey.destroy
    end

    render_success
  end

  # registers keys for a specific source
  def register
    ensure_post
    ensure_application
    ensure_valid_signature

    unless params[:source].blank?
      source = Tr8n::TranslationSource.find_or_create(params[:source], application)
    end

    phrases = []
    if params[:phrases]
      begin
        phrases = HashWithIndifferentAccess.new({:data => JSON.parse(params[:phrases])})[:data]
      rescue Exception => ex
        raise Tr8n::Exception.new("Invalid request. JSON parsing failed: #{ex.message}")
      end
    elsif params[:label]
      phrases << {:label => params[:label], :description => params[:description]}
    end

    keys = []
    phrases.each do |phrase|
      phrase = {:label => phrase} if phrase.is_a?(String)
      next if phrase[:label].strip.blank?
      opts = {:source => source, :locale => (language || Tr8n::Config.default_language).locale, :application => application}
      keys << Tr8n::TranslationKey.find_or_create(phrase[:label], phrase[:description], opts).to_api_hash(:translations => false)
    end

    render_response(keys)
  end

  def comments
  end

  def translations
    ensure_post
    ensure_application
    ensure_valid_signature

    if params[:id]
      tkey = Tr8n::TranslationKey.find_by_id(params[:id])
    else
      tkey = Tr8n::TranslationKey.find_or_create(params[:label], params[:description]) 
    end

    locales = params[:locales].split(',') if params[:locales] 
    locales ||= [params[:locale]] if params[:locale]

    languages = []
    locales.each do |locale| 
      l = Tr8n::Language.for(locale)
      next unless l
      languages << l
    end

    if languages.empty?
      raise Tr8n::Exception.new("At lease one valid locale must be provided")
    end

    translations = {}      
    languages.each do |lang|
      translations[lang.locale] = tkey.valid_translations_with_rules(lang)
    end

    render_response(tkey.to_api_hash(:translations => translations))
  end

  def sources
  end
  
private

  def key_ids
    @key_ids ||= begin
      if params[:keys] or params[:key]
        keys = params[:keys] ? params[:keys].split(',').collect{|k| k.strip} : [params[:key]]
        keys = Tr8n::TranslationKey.where("key in (?)", keys).all
        keys.collect{|key| key.id}
      elsif params[:ids] or params[:id]
        keys = params[:ids] ? params[:ids].split(',').collect{|k| k.strip} : [params[:id]]
        keys = Tr8n::TranslationKey.where("key in (?)", keys).all
        keys.collect{|key| key.id}
      else
        []  
      end  
    end  
  end

end