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

require 'bcrypt'

class User < ActiveRecord::Base
  
  include BCrypt

  attr_accessible :email, :name, :first_name, :last_name, :password, :password_confirmation, :gender, :locale

  attr_accessor :password, :password_confirmation
  before_save :encrypt_password

  validates_presence_of :name

  validates :email,   :presence => true, 
                      :length => {:minimum => 3, :maximum => 254},
                      :uniqueness => true,
                      :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}        

  has_many :sent_requests, :class_name => "Request", :foreign_key => :from_id, :dependent => :destroy
  has_many :recieved_requests, :class_name => "Request", :foreign_key => :to_id, :dependent => :destroy

  def self.authenticate(email, password)
    user = find_by_email(email)
    return nil if user.nil? 
    return user if user.crypted_password.nil?
    if user.crypted_password == BCrypt::Engine.hash_secret(password, user.salt)
      user
    else
      nil
    end
  end

  def set_password(new_password)
    self.password = new_password
    encrypt_password
    save!
  end

  def password_set?
    not password_set_at.nil?
  end

  def encrypt_password
    if password.present?
      self.salt = BCrypt::Engine.generate_salt
      self.crypted_password = BCrypt::Engine.hash_secret(password, salt)
      self.password_set_at = Time.now
    end
  end
    
  def mugshot(size = :medium)
    gravatar_id = Digest::MD5.hexdigest(email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=48"
  end

  def to_s
    name
  end
  
  def guest?
    id.nil?
  end

  def admin?
    true
  end

  def link
    ""
  end
end
