#--
# Copyright (c) 2010-2011 Michael Berkovich
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

class Tr8n::Admin::DomainController < Tr8n::Admin::BaseController
  unloadable

  def index
    @domains = Tr8n::TranslationDomain.filter(:params => params, :filter => Tr8n::TranslationDomainFilter)
  end

  def delete
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

end
