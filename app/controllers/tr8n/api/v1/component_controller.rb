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

###########################################################################
## API for getting translations from the main server
###########################################################################

class Tr8n::Api::V1::ComponentController < Tr8n::Api::V1::BaseController
  
  before_filter :ensure_component, :except => [:register]

  def index
    ensure_get
    ensure_application
    ensure_valid_signature
    render_response(component)
  end

  def languages
    ensure_get
    ensure_application
    ensure_valid_signature
    render_response(component.languages)
  end

  def sources
    ensure_get
    ensure_application
    ensure_valid_signature
    render_response(component.sources)
  end

  def translators
    ensure_get
    ensure_application
    ensure_valid_signature
    render_response(component.translators)
  end

  # registers a new source for the application
  def register
    ensure_post
    ensure_application
    ensure_authorized_call

    if params[:component]
      component_keys = [params[:component]]
    elsif params[:components]
      component_keys = params[:components].split(",").collect{|s| s.strip}
    end

    unless component_keys
      raise Tr8n::Exception.new("Component key must be provided.")
    end

    components = []
    component_keys.each do |key|
      components << Tr8n::Component.find_or_create(key, application)
    end
    
    return render_response(components.first) if components.size == 1
    render_response(components)
  end

  def register_source
    ensure_post
    ensure_application
    ensure_authorized_call

    component.register_source(params[:source])
  end

private

  def component
    @component ||= Tr8n::Component.where(:application_id => application.id, :key => params[:key]).first if params[:key]
  end

  def ensure_component
    unless component
      raise Tr8n::Exception.new("No valid source has been provided.")
    end
  end

end