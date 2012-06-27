require 'will_filter'

class AdminFilter < WillFilter::Filter

  def inner_joins
    [:user]
  end
      
end
