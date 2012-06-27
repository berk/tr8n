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

module Tr8n
  module ActionControllerExtension
    def self.included(base)
      base.send(:include, InstanceMethods) 
      base.before_filter :init_tr8n
    end

    module InstanceMethods
      ######################################################################
      # Author: Iain Hecker
      # reference: http://github.com/iain/http_accept_language
      ######################################################################
      def tr8n_browser_accepted_locales
        @accepted_languages ||= request.env['HTTP_ACCEPT_LANGUAGE'].split(/\s*,\s*/).collect do |l|
          l += ';q=1.0' unless l =~ /;q=\d+\.\d+$/
          l.split(';q=')
        end.sort do |x,y|
          raise Tr8n::Exception.new("Not correctly formatted") unless x.first =~ /^[a-z\-]+$/i
          y.last.to_f <=> x.last.to_f
        end.collect do |l|
          l.first.downcase.gsub(/-[a-z]+$/i) { |x| x.upcase }
        end
      rescue 
        []
      end

      def tr8n_user_preffered_locale
        tr8n_browser_accepted_locales.each do |locale|
          lang = Tr8n::Language.for(locale)
          return locale if lang and lang.enabled?
        end
        Tr8n::Config.default_locale
      end

      def tr8n_request_remote_ip
        @remote_ip ||= if request.env['HTTP_X_FORWARDED_FOR']
          request.env['HTTP_X_FORWARDED_FOR'].split(',').first
        else
          request.remote_ip
        end
      end
      
      def tr8n_init_current_source
        "#{self.class.name.underscore.gsub("_controller", "")}/#{self.action_name}"
      rescue
        self.class.name
      end

      def tr8n_init_current_locale
        eval(Tr8n::Config.current_locale_method)
      rescue
        # fallback to the default session based locale implementation
        # choose the first language from the accepted languages header
        session[:locale] = tr8n_user_preffered_locale unless session[:locale]
        session[:locale] = params[:locale] if params[:locale]
        session[:locale]
      end

      def tr8n_init_current_user
        eval(Tr8n::Config.current_user_method)
      end

      def init_tr8n
        # initialize request thread variables
        Tr8n::Config.init(tr8n_init_current_locale, tr8n_init_current_user, tr8n_init_current_source)
        
        # invalidate source for the current page
        Tr8n::Cache.invalidate_source(Tr8n::Config.current_source)

        # track user's last ip address  
        if Tr8n::Config.enable_country_tracking? and Tr8n::Config.current_user_is_translator?
          Tr8n::Config.current_translator.update_last_ip(tr8n_request_remote_ip)
        end
      end

      ############################################################
      # There are two ways to call the tr method
      #
      # tr(label, desc = "", tokens = {}, options = {})
      # or 
      # tr(label, {:desc => "", tokens => {},  ...})
      ############################################################
      def tr(label, desc = "", tokens = {}, options = {})

        return label if label.tr8n_translated?

        if desc.is_a?(Hash)
          options = desc
          tokens  = options[:tokens] || {}
          desc    = options[:desc] || ""
        end

        options.merge!(:caller => caller)
        options.merge!(:url => request.url)
        options.merge!(:host => request.env['HTTP_HOST'])

        unless Tr8n::Config.enabled?
          return Tr8n::TranslationKey.substitute_tokens(label, tokens, options)
        end

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

      # flash error
      def trfw(label, desc = "", tokens = {}, options = {})
        flash[:trfw] = tr(label, desc, tokens, options)
      end
    end
  end
end
