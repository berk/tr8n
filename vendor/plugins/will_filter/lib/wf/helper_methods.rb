#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
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

module Wf::HelperMethods

  def will_filter(results)
    render(:partial => "/wf/filter/container", :locals => {:wf_filter => results.wf_filter})
  end

  def will_filter_scripts_tag
    render(:partial => "/wf/common/scripts")
  end
  
  def will_filter_table_tag(results, opts = {})
    filter = results.wf_filter
    opts[:columns] ||= filter.model_column_keys
    render(:partial => "/wf/common/results_table", :locals => {:results => results, :filter => filter, :opts => opts})
  end

  def will_filter_actions_bar_tag(results, actions, opts = {})
    filter = results.wf_filter
    opts[:class] ||= "wf_actions_bar_blue"
    opts[:style] ||= ""
    render(:partial => "/wf/common/actions_bar", :locals => {:results => results, :filter => filter, :actions => actions, :opts => opts})
  end
  
end
