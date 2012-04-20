class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :gender, :mugshot, :link

  attr_accessor :password
  before_save :encrypt_password

  validates_presence_of :name
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create

  validates :email,   :presence => true, 
                      :length => {:minimum => 3, :maximum => 254},
                      :uniqueness => true,
                      :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}        


  has_one :admin
  
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.crypted_password == BCrypt::Engine.hash_secret(password, user.salt)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.salt = BCrypt::Engine.generate_salt
      self.crypted_password = BCrypt::Engine.hash_secret(password, salt)
    end
  end

  def guest?
    id.blank?
  end
  
  def admin?
    return true if Rails.env == 'development'
    not admin.nil? 
  end
  
  def name
    return first_name if last_name.blank?
    [first_name, last_name].join(" ")
  end
  
  def gender
    super || 'unknown'
  end
  
  def make_admin!
    return if admin?
    
    Admin.create(:user => self, :level => 0)
  end
  
  def to_s
    name
  end
  
end
