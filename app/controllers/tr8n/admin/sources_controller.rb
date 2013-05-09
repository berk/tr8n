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

class Tr8n::Admin::SourcesController < Tr8n::Admin::BaseController

  def index
    @sources = Tr8n::TranslationSource.filter(:params => params, :filter => Tr8n::TranslationSourceFilter)
  end

  def view
    @source = Tr8n::TranslationSource.find_by_id(params[:id])
    unless @source
      trfe("Invalid source id")
      return redirect_to_source
    end

    if params[:mode] == "translation_keys"
      conditions = ["tks.translation_source_id = ?", @source.id]

      unless params[:q].blank?
        conditions[0] << " and (tr8n_translation_keys.label like ? or tr8n_translation_keys.description like ?)"
        conditions << "%#{params[:q]}%"
        conditions << "%#{params[:q]}%"
      end

      @results = Tr8n::TranslationKey.find(:all, 
          :select => "distinct tr8n_translation_keys.id, tr8n_translation_keys.created_at, label, description, locale, admin, level, translation_count",
          :order => "tr8n_translation_keys.created_at desc",
          :conditions => conditions,
          :joins => [
            "join tr8n_translation_key_sources as tks on tr8n_translation_keys.id = tks.translation_key_id",
          ]
      ).page(page).per(per_page)
    elsif params[:mode] == "translations"
      conditions = ["tks.translation_source_id = ?", @source.id]

      unless params[:q].blank?
        conditions[0] << " and (tr8n_translations.label like ?)"
        conditions << "%#{params[:q]}%"
      end

      @results = Tr8n::Translation.find(:all, 
          :order => "tr8n_translations.created_at desc",
          :conditions => conditions,
          :joins => [
            "join tr8n_translation_keys as tk on tr8n_translations.translation_key_id = tk.id",
            "join tr8n_translation_key_sources as tks on tk.id = tks.translation_key_id",
          ]
      ).uniq.page(page).per(per_page)
    else
      filter = {"wf_c0" => "translation_source_id", "wf_o0" => "is", "wf_v0_0" => @source.id}
      @metrics = Tr8n::TranslationSourceMetric.filter(:params => params.merge(filter))
      @metrics.wf_filter.extra_params.merge!({:id => @source.id})
    end
  end

  def recalculate_metric
    metric = Tr8n::TranslationSourceMetric.find_by_id(params[:metric_id])
    unless metric
      trfe("Invalid metric id")
      return redirect_to_source
    end

    metric.update_metrics!
    trfn("The metric has been updated")
    redirect_to_source
  end

  def recalculate_source
    source = Tr8n::TranslationSource.find_by_id(params[:id])
    unless source
      trfe("Invalid source id")
      return redirect_to_source
    end

    source.translation_source_metrics.each do |metric|
      metric.update_metrics!
    end

    trfn("All metrics have been updated")
    redirect_to_source
  end

  def remove_keys_from_source
    source = Tr8n::TranslationSource.find_by_id(params[:id])
    unless source
      trfe("Invalid source id")
      return redirect_to_source
    end

    params[:keys] = [params[:key_id]] if params[:key_id]

    if params[:all] == "true"
      source.translation_key_sources.each do |tks|
        tks.destroy
      end
    elsif params[:keys]
      params[:keys].each do |key_id|
        tks = Tr8n::TranslationKeySource.find(:first, 
          :conditions => ["translation_key_id = ? and translation_source_id = ?", key_id, source.id])
        tks.destroy if tks
      end  
    end
    
    trfn("Keys have been removed")

    source.translation_source_metrics.each do |metric|
      metric.update_metrics!
    end
    
    redirect_to_source
  end

  def lb_update
    @source = Tr8n::TranslationSource.find_by_id(params[:id]) unless params[:id].blank?
    @source = Tr8n::TranslationSource.new unless @source
    @apps = Tr8n::Application.options
    
    if request.post?
      if @source
        @source.update_attributes(params[:source])
      else
        @source = Tr8n::TranslationSource.create(params[:source])
      end
      return dismiss_lightbox
    end  

    render :layout => false
  end
  
  def key_sources
    @key_sources = Tr8n::TranslationKeySource.filter(:params => params, :filter => Tr8n::TranslationKeySourceFilter)
  end

  def lb_caller
    @key_source = Tr8n::TranslationKeySource.find(params[:key_source_id])
    @caller = @key_source.details[params[:caller_key]]
    render_lightbox
  end  

  def lb_add_to_component
    if request.post?
      if params[:comp][:key].strip.blank?
        component = Tr8n::Component.find_by_id(params[:comp_id]) 
      else
        component = Tr8n::Component.create(params[:comp])
      end

      sources = (params[:sources] || '').split(',')
      if sources.any?
        sources = Tr8n::TranslationSource.find(:all, :conditions => ["id in (?)", sources])
        sources.each do |source|
          Tr8n::ComponentSource.find_or_create(component, source) 
        end
      end

      translators = (params[:translators] || '').split(',')
      if translators.any?
        translators = Tr8n::Translator.find(:all, :conditions => ["id in (?)", translators]) 
        translators.each do |translator|
          Tr8n::ComponentTranslator.find_or_create(component, translator) 
        end
      end

      languages = (params[:languages] || '').split(',')
      if languages.any?
        languages = Tr8n::Language.find(:all, :conditions => ["id in (?)", languages]) 
        languages.each do |language|
          Tr8n::ComponentLanguage.find_or_create(component, language) 
        end
      end

      return dismiss_lightbox
    end

    @apps = Tr8n::Application.options
    @components = Tr8n::Component.find(:all, :order => "name asc, key asc").collect{|c| [c.name_and_key, c.id]}
    render_lightbox
  end

end