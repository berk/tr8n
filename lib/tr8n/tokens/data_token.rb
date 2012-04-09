#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8n.net
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
# {user1:user::pos}
#
# Data tokens can be associated with any rules through the :dependency
# notation or using the nameing convetnion of the token suffix, defined
# in the tr8n configuration file
#
####################################################################### 

module Tr8n
  module Tokens
    class DataToken < Tr8n::Token
      def self.expression
        /(\{[^_:][\w]*(:[\w]+)?(::[\w]+)?\})/
      end
    end
  end
end
