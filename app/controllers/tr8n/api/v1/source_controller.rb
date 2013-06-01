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

class Tr8n::Api::V1::SourceController < Tr8n::Api::V1::BaseController
  
  # shows a source
  def index
    ensure_get
    ensure_application
    ensure_sources

    return render_response(sources.first) if sources.size == 1
    render_response(source)
  end

  def reset
    ensure_post
    ensure_application
    ensure_application_admin
    ensure_sources

    sources.each do |source|
      source.reset
    end

    return render_response(sources.first) if sources.size == 1
    render_response(sources)
  end

  def delete
    ensure_post
    ensure_application
    ensure_application_admin
    ensure_sources

    sources.each do |source|
      source.delete
    end

    render_success
  end

  # registers a new source for the application
  def register
    ensure_post
    ensure_application
    ensure_authorized_call

    if params[:source]
      source_names = [params[:source]]
    elsif params[:sources]
      source_names = params[:source].split(",").collect{|s| s.strip}
    end

    unless source_names
      raise Tr8n::Exception.new("Source name must be provided.")
    end

    sources = []
    source_names.each do |name|
      sources << Tr8n::TranslationSource.find_or_create(name, application)
    end
    
    return render_response(sources.first) if sources.size == 1
    render_response(sources)
  end

  def register_keys
    ensure_post
    ensure_application
    ensure_authorized_call

    if params[:source_keys].blank?
      raise Tr8n::Exception.new("Source keys must be provided.")
    end

    source_keys = JSON.parse(params[:source_keys])  
    source_keys.each do |data|
      source = Tr8n::TranslationSource.find_or_create(data["source"], application)
      data["keys"].each do |key|
        Tr8n::TranslationKey.find_or_create(key["label"], key["description"], {:source => source})
      end
    end
    
    render_success
  end

  # returns only the keys, without translations
  def translation_keys
    ensure_get
    ensure_application
    ensure_sources

    source_ids = sources.collect{|src| src.id}
    keys = Tr8n::TranslationKey.joins(:translation_sources).where("tr8n_translation_sources.id in (?)", source_ids).order("created_at asc").uniq
    results = keys.collect{|tkey| tkey.to_api_hash(:translations => false)}
    render_response(results)
  end

  # returns keys with translations and context rules
  def translations
    ensure_get
    ensure_application
    ensure_sources

    source_ids = sources.collect{|src| src.id}
    keys = Tr8n::TranslationKey.joins(:translation_sources).where("tr8n_translation_sources.id in (?)", source_ids).uniq
    results = []
    keys.each do |tkey|
      translations = tkey.valid_translations_with_rules(language)
      results << tkey.to_api_hash(:translations => translations)
    end
    render_response(results)
  end  

private

  def ensure_sources
    if sources.empty?
      raise Tr8n::Exception.new("No valid source has been provided.")
    end
  end

  def sources
    @sources ||= begin
      if params[:sources] or params[:source]
        source_names = params[:sources] ? params[:sources].split(',').collect{|s| s.strip} : [params[:source]]
        Tr8n::TranslationSource.where("application_id = ? and source in (?)", application.id, source_names).all
      elsif params[:ids] or params[:id]
        source_ids = params[:ids] ? params[:ids].split(',').collect{|s| s.strip} : [params[:id]]
        Tr8n::TranslationSource.where("application_id = ? and id in (?)", application.id, source_ids).all
      else
        []  
      end  
    end  
  end

end