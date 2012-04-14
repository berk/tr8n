class User < ActiveRecord::Base
  attr_accessible :email, :password, :first_name, :last_name, :gender, :mugshot, :link
  
  has_one :admin
  
  def guest?
    id.blank?
  end
  
  def admin?
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
