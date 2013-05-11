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

class Tr8n::Admin::TranslationKeyController < Tr8n::Admin::BaseController

  def index
    @keys = Tr8n::TranslationKey.filter(:params => params, :filter => Tr8n::TranslationKeyFilter)
  end
  
  def view
    @key = Tr8n::TranslationKey.find_by_id(params[:id])
    unless @key
      trfe("Invalid key id")
      return redirect_to(:action => :index) 
    end

    klass = {
      :sources => Tr8n::TranslationKeySource,
      :locks => Tr8n::TranslationKeyLock,
      :comments => Tr8n::TranslationKeyComment,
      :translations => Tr8n::Translation,
    }[params[:mode].to_sym] if params[:mode]
    klass ||= Tr8n::Translation

    filter = {"wf_c0" => "translation_key_id", "wf_o0" => "is", "wf_v0_0" => @key.id}
    extra_params = {:id => @key.id, :mode => params[:mode]}
    @results = klass.filter(:params => params.merge(filter))
    @results.wf_filter.extra_params.merge!(extra_params)
  end
  
  def delete
    params[:keys] = [params[:id]] if params[:id]
    if params[:keys]
      params[:keys].each do |id|
        key = Tr8n::TranslationKey.find_by_id(id)
        key.destroy if key
      end  
    end
    redirect_to_source
  end
  
  def lb_update
    @key = Tr8n::TranslationKey.find_by_id(params[:id]) unless params[:id].blank?
    @key = Tr8n::TranslationKey.new unless @key

    if request.post?    
      if @key.id
        @key.update_attributes(params[:translation_key])
      else
        @key = Tr8n::TranslationKey.create(params[:translation_key])
      end

      @key.reset_key!

      return dismiss_lightbox      
    end

    render_lightbox
  end

  def lb_import
    render_lightbox
  end

  def lb_add_to_source
    if request.post?
      if params[:source][:source].strip.blank?
        source = Tr8n::TranslationSource.find_by_id(params[:source_id]) 
      else
        source = Tr8n::TranslationSource.create(params[:source])
      end

      keys = params[:keys] || ''
      keys = keys.split(',')
      keys = Tr8n::TranslationKey.find(:all, :conditions => ["id in (?)", keys])
      keys.each do |key|
        Tr8n::TranslationKeySource.find_or_create(key, source) 
      end

      return dismiss_lightbox
    end

    @sources = Tr8n::TranslationSource.find(:all, :order => "name asc, source asc").collect{|s| [s.name_and_source, s.id]}
    render_lightbox
  end
  
  def update_lock
    lock = Tr8n::TranslationKeyLock.find(params[:lock_id])

    if params[:locked] == "true"
      lock.lock!
    else
      lock.unlock!
    end

    redirect_to_source
  end

  def lb_merge
    @keys = params[:keys] || ''
    @keys = @keys.split(',')
    @keys = Tr8n::TranslationKey.find(:all, :conditions => ["id in (?)", @keys])
    @key = @keys.first
    
    render_lightbox
  end

  def merge
    master_key = Tr8n::TranslationKey.find_by_id(params[:translation_key].delete(:id))
    
    keys = params[:keys] || ''
    keys = keys.split(',')
    keys = Tr8n::TranslationKey.find(:all, :conditions => ["id in (?)", keys])
    keys.each do |key|
      next if key.id == master_key.id
      key.translations.each do |translation|
        translation.clear_cache
        translation.update_attributes(:translation_key => master_key)
      end
      key.translation_key_comments.each do |comment|
        comment.update_attributes(:translation_key => master_key)
      end
      key.translation_key_sources.each do |source|
        source.update_attributes(:translation_key => master_key)
      end
      
      key.reload
      key.destroy
    end
    
    params[:translation_key][:label].strip!
    params[:translation_key][:description].strip!
    master_key.update_attributes(params[:translation_key])
    master_key.reset_key!
    master_key.update_translation_count!
    master_key.unlock_all!
    
    dismiss_lightbox
  end
  
  def comments
    @results = Tr8n::TranslationKeyComment.filter(:params => params, :filter => Tr8n::TranslationKeyCommentFilter)
  end
  
  def locks
    @results = Tr8n::TranslationKeyLock.filter(:params => params, :filter => Tr8n::TranslationKeyLockFilter)
  end
  
  def update_translation_counts
    Tr8n::TranslationKey.connection.execute("update tr8n_translation_keys set translation_count = (select count(id) from tr8n_translations where tr8n_translations.translation_id = tr8n_translation_keys.id)")
    redirect_to_source
  end
  
end
