#--
# Copyright (c) 2010-2012 Michael Berkovich, Geni Inc
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
  unloadable
  
  def index
    @keys = Tr8n::TranslationKey.filter(:params => params, :filter => Tr8n::TranslationKeyFilter)
  end
  
  def view
    @key = Tr8n::TranslationKey.find_by_id(params[:key_id])
    unless @key
      trfe("Invalid key id")
      return redirect_to(:action => :index) 
    end

    filter = {"wf_c0" => "translation_key_id", "wf_o0" => "is", "wf_v0_0" => @key.id}
    extra_params = {:key_id => @key.id, :mode => params[:mode]}
    if params[:mode] == "sources"
      @sources = Tr8n::TranslationKeySource.filter(:params => params.merge(filter))
      @sources.wf_filter.extra_params.merge!(extra_params)
    elsif params[:mode] == "locks"
      @locks = Tr8n::TranslationKeyLock.filter(:params => params.merge(filter))
      @locks.wf_filter.extra_params.merge!(extra_params)
    elsif params[:mode] == "comments"
      @comments = Tr8n::TranslationKeyComment.filter(:params => params.merge(filter))
      @comments.wf_filter.extra_params.merge!(extra_params)
    else
      @translations = Tr8n::Translation.filter(:params => params.merge(filter))
      @translations.wf_filter.extra_params.merge!(extra_params)
    end
  end
  
  def delete
    params[:keys] = [params[:key_id]] if params[:key_id]
    if params[:keys]
      params[:keys].each do |key_id|
        key = Tr8n::TranslationKey.find_by_id(key_id)
        key.destroy if key
      end  
    end
    redirect_to_source
  end
  
  def lb_update
    @key = Tr8n::TranslationKey.find_by_id(params[:key_id]) unless params[:key_id].blank?
    @key = Tr8n::TranslationKey.new unless @key
    
    render :layout => false
  end

  def lb_import
    render :layout => false
  end

  def update
    key = Tr8n::TranslationKey.find_by_id(params[:translation_key][:id]) unless params[:translation_key][:id].blank?
    
    if key
      key.update_attributes(params[:translation_key])
    else
      key = Tr8n::TranslationKey.create(params[:translation_key])
    end

    key.reset_key!

    redirect_to_source
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
    
    render :layout => false
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
    
    redirect_to_source
  end
  
  def comments
    @comments = Tr8n::TranslationKeyComment.filter(:params => params, :filter => Tr8n::TranslationKeyCommentFilter)
  end
  
  def delete_comment
    params[:comments] = [params[:comment_id]] if params[:comment_id]
    if params[:comments]
      params[:comments].each do |comment_id|
        comment = Tr8n::TranslationKeyComment.find_by_id(comment_id)
        comment.destroy if comment
      end  
    end
    redirect_to_source
  end
  
  def locks
    @locks = Tr8n::TranslationKeyLock.filter(:params => params, :filter => Tr8n::TranslationKeyLockFilter)
  end
  
  def delete_lock
    params[:locks] = [params[:lock_id]] if params[:lock_id]
    if params[:locks]
      params[:locks].each do |lock_id|
        lock = Tr8n::TranslationKeyLock.find_by_id(lock_id)
        lock.destroy if lock
      end  
    end
    redirect_to_source
  end
  
  def reset_verification_flags
    Tr8n::TranslationKey.connection.execute("update tr8n_translation_keys set verified_at = null")
    redirect_to_source
  end
  
  def delete_unverified_keys
    Tr8n::TranslationKey.find(:all, :conditions => "verified_at is null").each do |key|
      next if key.translations.any?
      key.destroy
    end
    redirect_to_source
  end

  def update_translation_counts
    Tr8n::TranslationKey.connection.execute("update tr8n_translation_keys set translation_count = (select count(id) from tr8n_translations where tr8n_translations.translation_key_id = tr8n_translation_keys.id)")
    redirect_to_source
  end
  
end
