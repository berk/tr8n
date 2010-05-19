module Tr8n::CommonMethods

  def self.included(base)
    if 'ApplicationController' == base.name
      base.append_before_filter :init_tr8n
    end
  end

  def init_tr8n
    session[:locale] = 'en-US' unless session[:locale]
    session[:locale] = params[:locale] if params[:locale]

    if self.respond_to?(Tr8n::Config.enable_tr8n_method)
      self.send(Tr8n::Config.enable_tr8n_method) ? Tr8n::Config.enable! : Tr8n::Config.disable!
    end

    Tr8n::Config.init(session[:locale], self.send(Tr8n::Config.current_user_method))
  end

  # translation functions
  def tr(label, desc = "", tokens = {}, options = {})
    begin
      if self.respond_to?(:controller)
        source = "#{controller.controller_name}/#{controller.action_name}"
      else
        source = "#{controller_name}/#{action_name}"
      end
    rescue Exception => ex
      source = self.class.name
    end

    options.merge!(:source => source) unless options[:source]
    return Tr8n::TranslationKey.substitute_tokens(label, tokens, options) unless Tr8n::Config.enabled?
    Tr8n::Config.current_language.translate(label, desc, tokens, options)
  end

  # for translating labels
  def trl(label, desc = "", tokens = {}, options = {})
    tr(label, desc, tokens, options.merge(:skip_decorations => true))
  end

  # flash notice
  def trfn(label, desc = "", tokens = {}, options = {})
    flash[:trfn] = tr(label, desc, tokens, options)
  end

  # flash error
  def trfe(label, desc = "", tokens = {}, options = {})
    flash[:trfe] = tr(label, desc, tokens, options)
  end
  # end translation helper methods
  
end
