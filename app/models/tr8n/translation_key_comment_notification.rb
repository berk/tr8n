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

class Tr8n::TranslationKeyCommentNotification < Tr8n::Notification

  def self.distribute(comment)
    tkey = comment.translation_key

    # find translators for all other translations of the key in this language
    tanslations = Tr8n::Translation.find(:all, :conditions => ["translation_key_id = ? and language_id = ?", 
                                                 tkey.id, comment.language.id])

    translators = []
    tanslations.each do |t|
      translators << t.translator
    end

    translators += commenters(tkey, comment.language)
    translators += followers(tkey)

    # remove the current translator
    translators = translators.uniq - [comment.translator]

    translators.each do |t|
      create(:translator => t, :object => comment, :actor => comment.translator, :action => "commented_on_translation_key")
    end
  end

  def title
    if object.translation_key.followed?
      return tr("[link: {user}] commented on a translation to a phrase you are following.", nil, 
          :user => actor, :link => [actor.link]
      )
    end

    if object.translation_key.commented?(object.language)
      return tr("[link: {user}] replied to your comment.", nil, 
          :user => actor, :link => [actor.link]
      )
    end

    tr("[link: {user}] commented on a phrase you've translated.", nil, 
      :user => actor, :link => [actor.link]
    )
  end


end
