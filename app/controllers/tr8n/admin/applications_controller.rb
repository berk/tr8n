#--
# Copyright (c) 2010-2013 Michael Berkovich
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

class Tr8n::Admin::ApplicationsController < Tr8n::Admin::BaseController
  unloadable

  def index
    @apps = Tr8n::Application.filter(:params => params, :filter => Tr8n::ApplicationFilter)
  end
  
  def lb_update
    @app = Tr8n::Application.find_by_id(params[:app_id]) unless params[:app_id].blank?
    @app = Tr8n::Application.new unless @app
    
    render :layout => false
  end

  def update
    app = Tr8n::Application.find_by_id(params[:app][:id]) unless params[:app][:id].blank?
    
    if app
      app.update_attributes(params[:app])
    else
      app = Tr8n::Application.create(params[:app])
    end
    
    redirect_to_source
  end

  def delete
    params[:apps] = [params[:app_id]] if params[:app_id]
    if params[:apps]
      params[:apps].each do |app_id|
        app = Tr8n::Application.find_by_id(app_id)
        app.destroy if app
      end  
    end
    redirect_to_source
  end  


  def application
    @app = Tr8n::Application.find_by_id(params[:app_id])

    unless @app
      trfe("Invalid application id")
      return redirect_to_source
    end

    params[:mode] ||= "metrics"

    if params[:mode] == "metrics"
      @results = @app.components
    elsif params[:mode] == "translation_keys"
      @results = Tr8n::TranslationKey.find(:all, 
          :select => "distinct tr8n_translation_keys.id, tr8n_translation_keys.created_at, tr8n_translation_keys.label, tr8n_translation_keys.description, tr8n_translation_keys.locale, tr8n_translation_keys.admin, tr8n_translation_keys.level, tr8n_translation_keys.translation_count",
          :order => "tr8n_translation_keys.created_at desc",
          :conditions => ["c.application_id = ?", @app.id],
          :joins => [
            "join tr8n_translation_key_sources as tks on tr8n_translation_keys.id = tks.translation_key_id",
            "join tr8n_component_sources as cs on tks.translation_source_id = cs.translation_source_id",
            "join tr8n_components as c on cs.component_id = c.id"
          ]
      ).paginate(:page => page, :per_page => per_page)
    elsif params[:mode] == "translations"
      @results = Tr8n::Translation.find(:all, 
          :order => "tr8n_translations.created_at desc",
          :conditions => ["c.application_id = ?", @app.id],
          :joins => [
            "join tr8n_translation_keys as tk on tr8n_translations.translation_key_id = tk.id",
            "join tr8n_translation_key_sources as tks on tk.id = tks.translation_key_id",
            "join tr8n_component_sources as cs on tks.translation_source_id = cs.translation_source_id",
            "join tr8n_components as c on cs.component_id = c.id"
          ]
      ).uniq.paginate(:page => page, :per_page => per_page)
    else
      klass = {
        :components => Tr8n::Component
      }[params[:mode].to_sym] if params[:mode]
      klass ||= Tr8n::Component

      filter = {"wf_c0" => "application_id", "wf_o0" => "is", "wf_v0_0" => @app.id}
      extra_params = {:app_id => @app.id, :mode => params[:mode]}
      @results = klass.filter(:params => params.merge(filter))
      @results.wf_filter.extra_params.merge!(extra_params)      
    end
  end

  def change_component_language_state
    component_language = Tr8n::ComponentLanguage.find_by_id(params[:component_language_id])
    component_language.state = params[:state]
    component_language.save
    redirect_to_source
  end

  def components
    @comps = Tr8n::Component.filter(:params => params, :filter => Tr8n::ComponentFilter)
  end

  def lb_update_component
    @comp = Tr8n::Component.find_by_id(params[:comp_id]) unless params[:comp_id].blank?
    @comp = Tr8n::Component.new unless @comp
    @apps = Tr8n::Application.options
    
    render :layout => false
  end

  def lb_add_objects_to_component
    @type = params[:type] || component_link_types.first
    @type = component_link_types.first unless component_link_types.include?(@type)

    @comp = Tr8n::Component.find_by_id(params[:comp_id])
    if @type == "language"
      @languages = Tr8n::Language.enabled_languages
    elsif @type == "source"   
      @sources = Tr8n::TranslationSource.find(:all, :order => "source asc")
    elsif @type == "translator"   
    end
    
    render :partial => "lb_add_#{@type.pluralize}_to_component"
  end

  def add_objects_to_component
    unless component_link_types.include?(params[:type])
      trfe("Invalid object type")
      return redirect_to_source
    end
    type = params[:type].capitalize
    model_class_name = (type == "Source" ? "TranslationSource" : type)

    comp = Tr8n::Component.find(params[:comp_id])
    params[:ids].each do |id|
      next if id.blank?
      lang = "Tr8n::#{model_class_name}".constantize.find_by_id(id)
      "Tr8n::Component#{type}".constantize.find_or_create(comp, lang) if lang
    end

    redirect_to_source
  end

  def remove_objects_from_component
    unless component_link_types.include?(params[:type])
      trfe("Invalid object type")
      return redirect_to_source
    end
    type = params[:type].capitalize

    params[:component_objects] = [params[:component_object_id]] if params[:component_object_id]
    if params[:component_objects]
      params[:component_objects].each do |id|
        csrc = "Tr8n::Component#{type}".constantize.find_by_id(id)
        csrc.destroy if csrc
      end  
    end
    redirect_to_source
  end

  def update_component
    comp = Tr8n::Component.find_by_id(params[:comp][:id]) unless params[:comp][:id].blank?
    
    if comp
      comp.update_attributes(params[:comp])
    else
      comp = Tr8n::Component.create(params[:comp])
    end
    
    redirect_to_source
  end

  def component
    @comp = Tr8n::Component.find_by_id(params[:comp_id])

    unless @comp
      trfe("Invalid component id")
      return redirect_to_source
    end

    if params[:mode] == "translation_keys"
      @results = Tr8n::TranslationKey.find(:all, 
          :select => "distinct tr8n_translation_keys.id, tr8n_translation_keys.created_at, label, description, locale, admin, level, translation_count",
          :order => "tr8n_translation_keys.created_at desc",
          :conditions => ["cs.component_id = ?", @comp.id],
          :joins => [
            "join tr8n_translation_key_sources as tks on tr8n_translation_keys.id = tks.translation_key_id",
            "join tr8n_component_sources as cs on tks.translation_source_id = cs.translation_source_id"
          ]
      ).paginate(:page => page, :per_page => per_page)
    elsif params[:mode] == "translations"
      @results = Tr8n::Translation.find(:all, 
          :order => "tr8n_translations.created_at desc",
          :conditions => ["cs.component_id = ?", @comp.id],
          :joins => [
            "join tr8n_translation_keys as tk on tr8n_translations.translation_key_id = tk.id",
            "join tr8n_translation_key_sources as tks on tk.id = tks.translation_key_id",
            "join tr8n_component_sources as cs on tks.translation_source_id = cs.translation_source_id"
          ]
      ).uniq.paginate(:page => page, :per_page => per_page)
    else
      klass = {
        :metrics => Tr8n::ComponentSource,
        :sources => Tr8n::ComponentSource,
        :charts => Tr8n::ComponentSource,
        :translators => Tr8n::ComponentTranslator,
        :languages => Tr8n::ComponentLanguage,
      }[params[:mode].to_sym] if params[:mode]
      klass ||= Tr8n::ComponentSource

      filter = {"wf_c0" => "component_id", "wf_o0" => "is", "wf_v0_0" => @comp.id}
      extra_params = {:comp_id => @comp.id, :mode => params[:mode]}
      @results = klass.filter(:params => params.merge(filter))
      @results.wf_filter.extra_params.merge!(extra_params)      
    end
  end

  def delete_component
    params[:comps] = [params[:comp_id]] if params[:comp_id]
    if params[:comps]
      params[:comps].each do |comp_id|
        comp = Tr8n::Component.find_by_id(comp_id)
        comp.destroy if comp
      end  
    end
    redirect_to_source
  end

  def domains
    @domains = Tr8n::TranslationDomain.filter(:params => params, :filter => Tr8n::TranslationDomainFilter)
  end

  def delete_domain
    params[:domains] = [params[:domain_id]] if params[:domain_id]
    if params[:domains]
      params[:domains].each do |domain_id|
        domain = Tr8n::TranslationDomain.find_by_id(domain_id)
        domain.destroy if domain
      end  
    end
    redirect_to_source
  end

  def sources
    @sources = Tr8n::TranslationSource.filter(:params => params, :filter => Tr8n::TranslationSourceFilter)
  end

  def source
    @source = Tr8n::TranslationSource.find_by_id(params[:source_id])

    unless @source
      trfe("Invalid source id")
      return redirect_to_source
    end

    if params[:mode] == "translation_keys"
      @results = Tr8n::TranslationKey.find(:all, 
          :select => "distinct tr8n_translation_keys.id, tr8n_translation_keys.created_at, label, description, locale, admin, level, translation_count",
          :order => "tr8n_translation_keys.created_at desc",
          :conditions => ["tks.translation_source_id = ?", @source.id],
          :joins => [
            "join tr8n_translation_key_sources as tks on tr8n_translation_keys.id = tks.translation_key_id",
          ]
      ).paginate(:page => page, :per_page => per_page)
    elsif params[:mode] == "translations"
      @results = Tr8n::Translation.find(:all, 
          :order => "tr8n_translations.created_at desc",
          :conditions => ["tks.translation_source_id = ?", @source.id],
          :joins => [
            "join tr8n_translation_keys as tk on tr8n_translations.translation_key_id = tk.id",
            "join tr8n_translation_key_sources as tks on tk.id = tks.translation_key_id",
          ]
      ).uniq.paginate(:page => page, :per_page => per_page)
    else
      filter = {"wf_c0" => "translation_source_id", "wf_o0" => "is", "wf_v0_0" => @source.id}
      @metrics = Tr8n::TranslationSourceMetric.filter(:params => params.merge(filter))
      @metrics.wf_filter.extra_params.merge!({:source_id => @source.id})
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
    source = Tr8n::TranslationSource.find_by_id(params[:source_id])
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
    source = Tr8n::TranslationSource.find_by_id(params[:source_id])
    unless source
      trfe("Invalid source id")
      return redirect_to_source
    end

    params[:keys] = [params[:key_id]] if params[:key_id]
    if params[:keys]
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

  def lb_update_source
    @source = Tr8n::TranslationSource.find_by_id(params[:source_id]) unless params[:source_id].blank?
    @source = Tr8n::TranslationSource.new unless @source
    
    render :layout => false
  end

  def update_source
    source = Tr8n::TranslationSource.find_by_id(params[:source][:id]) unless params[:source][:id].blank?
    
    if source
      source.update_attributes(params[:source])
    else
      source = Tr8n::TranslationSource.create(params[:source])
    end
    
    redirect_to_source
  end
  
  def delete_source
    params[:sources] = [params[:source_id]] if params[:source_id]
    if params[:sources]
      params[:sources].each do |source_id|
        source = Tr8n::TranslationSource.find_by_id(source_id)
        source.destroy if source
      end  
    end
    redirect_to_source
  end

  def key_sources
    @key_sources = Tr8n::TranslationKeySource.filter(:params => params, :filter => Tr8n::TranslationKeySourceFilter)
  end

  def delete_key_source
    params[:key_sources] = [params[:key_source_id]] if params[:key_source_id]
    if params[:key_sources]
      params[:key_sources].each do |key_source_id|
        key_source = Tr8n::TranslationKeySource.find_by_id(key_source_id)
        key_source.destroy if key_source
      end  
    end
    redirect_to_source
  end

  def lb_caller
    @key_source = Tr8n::TranslationKeySource.find(params[:key_source_id])
    @caller = @key_source.details[params[:caller_key]]
    render :layout => false
  end  

  private

  def component_link_types
    ["language", "source", "translator"]
  end

end