####################################################################### 
# 
# Data Token Forms:
#
# {count} 
# {count:number} 
# {user:gender}
# {today:date} 
# {user_list:list}
# {long_token_name} 
# {user1}
# {user1:user}
#
# Data tokens can be associated with any rules through the :dependency
# notation or using the nameing convetnion of the token suffix, defined
# in the tr8n configuration file
#
####################################################################### 

class Tr8n::DataToken < Tr8n::Token
  
  def self.expression
    /(\{[^_][\w]+(:[\w]+)?\})/
  end

end
