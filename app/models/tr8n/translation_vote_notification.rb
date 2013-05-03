#--
# Copyright (c) 2010-2013 Michael Berkovich, Geni Inc
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

class Tr8n::TranslationVoteNotification < Tr8n::Notification

  def self.distribute(vote)
    return if vote.translation.translator == vote.translator

    last_notification = Tr8n::TranslationVoteNotification.find(:first, 
        :conditions => ["object_type = ? and object_id = ?", vote.class.name, vote.id],
        :order => "updated_at desc")

    return if last_notification and last_notification.updated_at > Time.now - 5.minutes

    tkey = vote.translation.translation_key
    translators = translators_for_translation(vote.translation)

    # find all translators who follow the key
    translators += followers(tkey)
    translators += followers(vote.translator)

    # remove the current translator
    translators = translators.uniq - [vote.translator]

    translators.each do |t|
     create(:translator => t, :object => vote, :actor => vote.translator, :action => "voted_on_translation")
    end
  end

  def verb(vote)
    return "likes" if vote.vote > 0
    "does not like"
  end

  def title
    if object.translation.translation_key.followed?
      return tr("[link: {user}] #{verb(object)} a translation to a phrase you are following.", nil, 
          :user => actor, :link => [actor.url]
      )
    end

    if object.translation.translator == Tr8n::Config.current_translator
      return tr("[link: {user}] #{verb(object)} your translation.", nil, 
        :user => actor, :link => [actor.url]
      )
    end

    if self.class.translators_for_translation(object.translation).include?(translator)
      return tr("[link: {user}] #{verb(object)} an alternative translation to a phrase you've translated.", nil, 
        :user => actor, :link => [actor.url]
      )
    end

    tr("[link: {user}] #{verb(object)} a translation.", nil, 
      :user => actor, :link => [actor.url]
    )
  end
end
