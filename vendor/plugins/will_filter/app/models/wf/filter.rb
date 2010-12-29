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

class Wf::Filter < ActiveRecord::Base
  
  JOIN_NAME_INDICATOR = '>'

  set_table_name :wf_filters
  serialize   :data
  
  #############################################################################
  # Basics 
  #############################################################################
  def initialize(model_class)
    super()
    self.model_class_name = model_class.to_s
  end
  
  def dup
    super.tap {|ii| ii.conditions = self.conditions.dup}
  end
  
  def before_save
    self.data = serialize_to_params
    self.type = self.class.name
  end
  
  def after_find
    @errors = {}
    deserialize_from_params(self.data)
  end
  
  #############################################################################
  # Defaults 
  #############################################################################
  def show_export_options?
    Wf::Config.exporting_enabled?
  end

  def show_save_options?
    Wf::Config.saving_enabled?
  end

  def match 
    @match ||= :all
  end

  def key 
    @key ||= ''
  end

  def errors 
    @errors ||= {}
  end
  
  def format
    @format ||= :html
  end

  def fields
    @fields ||= []
  end
  
  #############################################################################
  # a list of indexed fields where at least one of them has to be in a query
  # otherwise the filter may hang the database
  #############################################################################
  def required_condition_keys
    []
  end
  
  def model_class
    return nil unless model_class_name
    @model_class ||= model_class_name.constantize
  end
  
  def table_name
    model_class.table_name
  end
  
  def key=(new_key)
    @key = new_key
  end
  
  def match=(new_match)
    @match = new_match
  end
  
  #############################################################################
  # Inner Joins come in a form of 
  # [[joining_model_name, column_name], [joining_model_name, column_name]]
  #############################################################################
  def inner_joins
    []
  end
  
  def model_columns
    model_class.columns
  end

  def model_column_keys
    model_columns.collect{|col| col.name.to_sym}
  end
  
  def contains_column?(key)
    model_column_keys.index(key) != nil
  end
  
  def definition
    @definition ||= begin
      defs = {}
      model_columns.each do |col|
        defs[col.name.to_sym] = default_condition_definition_for(col.name, col.sql_type)
      end
      
      inner_joins.each do |inner_join|
        join_class = inner_join.first.to_s.camelcase.constantize
        join_class.columns.each do |col|
          defs[:"#{join_class.to_s.underscore}.#{col.name.to_sym}"] = default_condition_definition_for(col.name, col.sql_type)
        end
      end
      
      defs
    end
  end

  def container_by_sql_type(type)
    raise Wf::FilterException.new("Unsupported data type #{type}") unless Wf::Config.data_types[type]
    Wf::Config.data_types[type]
  end
  
  def default_condition_definition_for(name, sql_data_type)
    type = sql_data_type.split(" ").first.split("(").first.downcase
    containers = container_by_sql_type(type)
    operators = {}
    containers.each do |c|
      raise Wf::FilterException.new("Unsupported container implementation for #{c}") unless Wf::Config.containers[c]
      container_klass = Wf::Config.containers[c].constantize
      container_klass.operators.each do |o|
        operators[o] = c
      end
    end
    
    if name == "id"
      operators[:is_filtered_by] = :filter_list 
    elsif "_id" == name[-3..-1]
      begin
        name[0..-4].camelcase.constantize
        operators[:is_filtered_by] = :filter_list 
      rescue  
      end
    end
    
    operators
  end
  
  def sorted_operators(opers)
    (Wf::Config.operator_order & opers.keys.collect{|o| o.to_s})
  end
  
  def first_sorted_operator(opers)
    sorted_operators(opers).first.to_sym
  end

  def default_order
    'id'
  end
  
  def order
    @order ||= default_order
  end
  
  def default_order_type
    'desc'
  end

  def order_type
    @order_type ||= default_order_type
  end

  def order_model
    @order_model ||= begin
      order_parts = order.split('.')
      if order_parts.size > 1
        order_parts.first.camelcase
      else
        model_class_name
      end
    end  
  end

  def order_clause
    @order_clause ||= begin
      order_parts = order.split('.')
      if order_parts.size > 1
        "#{order_parts.first.camelcase.constantize.table_name}.#{order_parts.last} #{order_type}"
      else
        "#{model_class_name.constantize.table_name}.#{order_parts.first} #{order_type}"
      end
    end  
  end

  def column_sorted?(key)
    key.to_s == order
  end

  def default_per_page
    30
  end
  
  def per_page
    @per_page ||= default_per_page
  end

  def page
    @page ||= 1
  end
  
  def default_per_page_options
    [10, 20, 30, 40, 50, 100]
  end
  
  def per_page_options
    @per_page_options ||= default_per_page_options.collect{ |n| [n.to_s, n.to_s] }
  end
  
  def match_options
    [["all", "all"], ["any", "any"]]
  end
  
  def order_type_options
    [["desc", "desc"], ["asc", "asc"]]
  end

  #############################################################################
  # Can be overloaded for custom titles
  #############################################################################
  def condition_title_for(key)
    title_parts = key.to_s.split('.')
    title = key.to_s.gsub(".", ": ").gsub("_", " ")
    title = title.split(" ").collect{|part| part.split("/").last.capitalize}.join(" ")
    
    if title_parts.size > 1
      "#{JOIN_NAME_INDICATOR} #{title}"
    else
      title  
    end
  end
  
  def condition_options
    @condition_options ||= begin
      opts = []
      definition.keys.each do |cond|
        opts << [condition_title_for(cond), cond.to_s]
      end
      opts = opts.sort_by{|opt| opt.first.gsub(JOIN_NAME_INDICATOR, 'zzz') }
      
      separated = []
      opts.each_with_index do |opt, index|
        if index > 0
          prev_opt_parts = opts[index-1].first.split(":")
          curr_opt_parts = opt.first.split(":")
          
          if (prev_opt_parts.size != curr_opt_parts.size) or (curr_opt_parts.size > 1 and (prev_opt_parts.first != curr_opt_parts.first))
            key_parts = opt.last.split('.')
            separated << ["-------------- #{curr_opt_parts.first.gsub("#{JOIN_NAME_INDICATOR} ", '')} --------------", "#{key_parts.first}.id"]
          end
        end
        separated << opt
      end
      separated
    end
  end
  
  def operator_options_for(condition_key)
    condition_key = condition_key.to_sym if condition_key.is_a?(String)
    
    opers = definition[condition_key]
    raise Wf::FilterException.new("Invalid condition #{condition_key} for filter #{self.class.name}") unless opers
    sorted_operators(opers).collect{|o| [o.to_s.gsub('_', ' '), o]}
  end
  
  # called by the list container, should be overloaded in a subclass
  def value_options_for(condition_key)
    []
  end
  
  def container_for(condition_key, operator_key)
    condition_key = condition_key.to_sym if condition_key.is_a?(String)

    opers = definition[condition_key]
    raise Wf::FilterException.new("Invalid condition #{condition_key} for filter #{self.class.name}") unless opers
    oper = opers[operator_key]
    
    # if invalid operator_key was passed, use first operator
    oper = opers[first_sorted_operator(opers)] unless oper
    oper
  end
  
  def add_condition(condition_key, operator_key, values = [])
    add_condition_at(size, condition_key, operator_key, values)
  end

  def add_condition!(condition_key, operator_key, values = [])
    add_condition(condition_key, operator_key, values)
    self
  end

  def clone_with_condition(condition_key, operator_key, values = [])
    dup.add_condition!(condition_key, operator_key, values)
  end

  def valid_operator?(condition_key, operator_key)
    condition_key = condition_key.to_sym if condition_key.is_a?(String)
    opers = definition[condition_key]
    return false unless opers
    opers[operator_key]!=nil
  end
  
  def add_condition_at(index, condition_key, operator_key, values = [])
    values = [values] unless values.instance_of?(Array)
    values = values.collect{|v| v.to_s}

    condition_key = condition_key.to_sym if condition_key.is_a?(String)
    
    unless valid_operator?(condition_key, operator_key)
      opers = definition[condition_key]
      operator_key = first_sorted_operator(opers)
    end
    
    condition = Wf::FilterCondition.new(self, condition_key, operator_key, container_for(condition_key, operator_key), values)
    @conditions.insert(index, condition)
  end
  
  #############################################################################
  # options always go in [NAME, KEY] format
  #############################################################################
  def default_condition_key
    condition_options.first.last
  end
  
  #############################################################################
  # options always go in [NAME, KEY] format
  #############################################################################
  def default_operator_key(condition_key)
    operator_options_for(condition_key).first.last
  end
  
  def conditions=(new_conditions) 
    @conditions = new_conditions
  end
  
  def conditions
    @conditions ||= []
  end
  
  def condition_at(index)
    conditions[index]
  end
  
  def condition_by_key(key)
    conditions.each do |c|
      return c if c.key==key
    end
    nil
  end
  
  def size
    conditions.size
  end
  
  def add_default_condition_at(index)
    add_condition_at(index, default_condition_key, default_operator_key(default_condition_key))
  end
  
  def remove_condition_at(index)
    conditions.delete_at(index)
  end
  
  def remove_all
    @conditions = []
  end

  #############################################################################
  # Serialization 
  #############################################################################
  def serialize_to_params(merge_params = {})
    params = {}
    params[:wf_type]        = self.class.name
    params[:wf_match]       = match
    params[:wf_model]       = model_class_name
    params[:wf_order]       = order
    params[:wf_order_type]  = order_type
    params[:wf_per_page]    = per_page
    
    0.upto(size - 1) do |index|
      condition = condition_at(index)
      condition.serialize_to_params(params, index)
    end
    
    params.merge(merge_params)
  end
  
  def to_url_params
    params = []
    serialize_to_params.each do |name, value|
      params << "#{name.to_s}=#{ERB::Util.url_encode(value)}"
    end
    params.join("&")
  end
  
  def to_s
    to_url_params
  end
  
  #############################################################################
  # allows to create a filter from params only
  #############################################################################
  def self.deserialize_from_params(params)
    params[:wf_type] = self.name unless params[:wf_type]
    params[:wf_type].constantize.new(params[:wf_model]).deserialize_from_params(params)
  end
  
  def deserialize_from_params(params)
    @conditions = []
    @match                = params[:wf_match]       || :all
    @key                  = params[:wf_key]         || self.id.to_s
    self.model_class_name = params[:wf_model]       if params[:wf_model]
    
    @per_page             = params[:wf_per_page]    || default_per_page
    @page                 = params[:page]           || 1
    @order_type           = params[:wf_order_type]  || default_order_type
    @order                = params[:wf_order]       || default_order
    
    self.id   =  params[:wf_id].to_i  unless params[:wf_id].blank?
    self.name =  params[:wf_name]     unless params[:wf_name].blank?
    
    @fields = []
    unless params[:wf_export_fields].blank?
      params[:wf_export_fields].split(",").each do |fld|
        @fields << fld.to_sym
      end
    end

    if params[:wf_export_format].blank?
      @format = :html
    else  
      @format = params[:wf_export_format].to_sym
    end
    
    i = 0
    while params["wf_c#{i}"] do
      conditon_key = params["wf_c#{i}"]
      operator_key = params["wf_o#{i}"]
      values = []
      j = 0
      while params["wf_v#{i}_#{j}"] do
        values << params["wf_v#{i}_#{j}"]
        j += 1
      end
      i += 1
      add_condition(conditon_key, operator_key.to_sym, values)
    end

    if params[:wf_submitted] == 'true'
      validate!
    end

    return self
  end
  
  #############################################################################
  # Validations 
  #############################################################################
  def errors?
   (@errors and @errors.size > 0)
  end
  
  def empty?
    size == 0
  end

  def has_condition?(key)
    condition_by_key(key) != nil
  end

  def valid_format?
    Wf::Config.default_export_formats.include?(format.to_s)
  end

  def required_conditions_met?
    return true if required_condition_keys.blank?
    sconditions = conditions.collect{|c| c.key.to_s}
    rconditions = required_condition_keys.collect{|c| c.to_s}
    not (sconditions & rconditions).empty?
  end
  
  def validate!
    @errors = {}
    0.upto(size - 1) do |index|
      condition = condition_at(index)
      err = condition.validate
      @errors[index] = err if err
    end
    
    unless required_conditions_met?
      @errors[:filter] = "Filter must contain at least one of the following conditions: #{required_condition_keys.join(", ")}"
    end
    
    errors?
  end
  
  #############################################################################
  # SQL Conditions 
  #############################################################################
  def sql_conditions
    @sql_conditions  ||= begin

      if errors? 
        all_sql_conditions = [" 1 = 2 "] 
      else
        all_sql_conditions = [""]
        0.upto(size - 1) do |index|
          condition = condition_at(index)
          sql_condition = condition.container.sql_condition
          
          unless sql_condition
            raise Wf::FilterException.new("Unsupported operator #{condition.operator_key} for container #{condition.container.class.name}")
          end
          
          if all_sql_conditions[0].size > 0
            all_sql_conditions[0] << ( match.to_sym == :all ? " AND " : " OR ")
          end
          
          all_sql_conditions[0] << sql_condition[0]
          sql_condition[1..-1].each do |c|
            all_sql_conditions << c
          end
        end
      end
      
      all_sql_conditions
    end
  end
  
  def condition_models
    @condition_models ||= begin 
      models = [] 
      conditions.each do |condition|
        key_parts = condition.key.to_s.split('.')
        if key_parts.size > 1
          models << key_parts.first.camelcase
        else
          models << model_class_name
        end
      end
      models << order_model
      models.uniq
    end  
  end
  
  def debug_conditions(conds)
    all_conditions = []
    conds.each_with_index do |c, i|
      cond = ""
      if i == 0
        cond << "\"<b>#{c}</b>\""
      else  
        cond << "<br>&nbsp;&nbsp;&nbsp;<b>#{i})</b>&nbsp;"
        if c.is_a?(Array)
          cond << "["
          cond << (c.collect{|v| "\"#{v.to_s.strip}\""}.join(", "))
          cond << "]"
        elsif c.is_a?(Date)  
          cond << "\"#{c.strftime("%Y-%m-%d")}\""
        elsif c.is_a?(Time)  
          cond << "\"#{c.strftime("%Y-%m-%d %H:%M:%S")}\""
        elsif c.is_a?(Integer)  
          cond << c.to_s
        else  
          cond << "\"#{c}\""
        end
      end
      
      all_conditions << cond
    end
    all_conditions
  end

  def debug_sql_conditions
    debug_conditions(sql_conditions)
  end

  #############################################################################
  # Saved Filters 
  #############################################################################
  def saved_filters(include_default = true)
    @saved_filters ||= begin
      filters = []
    
      if include_default
        filters = default_filters
        if (filters.size > 0)
          filters.insert(0, ["-- Select Default Filter --", "-1"])
        end
      end

      if include_default
        conditions = ["type = ? and model_class_name = ?", self.class.name, self.model_class_name]
      else
        conditions = ["model_class_name = ?", self.model_class_name]
      end

      if Wf::Config.user_filters_enabled?
        conditions[0] << " and user_id = ? "
        if Wf::Config.current_user and Wf::Config.current_user.id
          conditions << Wf::Config.current_user.id
        else
          conditions << "0"
        end
      end

      user_filters = Wf::Filter.find(:all, :conditions => conditions)
      
      if user_filters.size > 0
        filters << ["-- Select Saved Filter --", "-2"] if include_default
        
        user_filters.each do |filter|
          filters << [filter.name, filter.id.to_s]
        end
      end
        
      filters
    end
  end
  
  #############################################################################
  # overload this method if you don't want to allow empty filters
  #############################################################################
  def default_filter_if_empty
    nil
  end
    
  def handle_empty_filter!
    return unless empty?
    return if default_filter_if_empty.nil?
    load_filter!(default_filter_if_empty)
  end
  
  def default_filters
    []
  end

  def default_filter_conditions(key)
    []
  end
  
  def load_default_filter(key)
    default_conditions = default_filter_conditions(key)
    return if default_conditions.nil? or default_conditions.empty?
    
    unless default_conditions.first.is_a?(Array)
      add_condition(*default_conditions)
      return
    end
    
    default_conditions.each do |default_condition|
      add_condition(*default_condition)
    end
  end
  
  def reset!
    remove_all
    @sql_conditions = nil
    @results = nil
  end
  
  def load_filter!(key_or_id)
    reset!
    @key = key_or_id.to_s
    
    load_default_filter(key)
    return self unless empty?
    
    filter = Wf::Filter.find_by_id(key_or_id.to_i)
    raise Wf::FilterException.new("Invalid filter key #{key_or_id.to_s}") if filter.nil?
    filter
  end

  #############################################################################
  # Export Filter Data
  #############################################################################
  def export_formats
    formats = []
    formats << ["-- Generic Formats --", -1]
    Wf::Config.default_export_formats.each do |frmt|
      formats << [frmt, frmt]
    end
    if custom_formats.size > 0
      formats << ["-- Custom Formats --", -2]
      custom_formats.each do |frmt|
        formats << frmt
      end
    end
    formats
  end

  def custom_format?
    custom_formats.each do |frmt|
      return true if frmt[1].to_sym == format
    end
    false
  end
  
  def custom_formats
    []
  end
  
  def process_custom_format
    ""
  end
  
  def joins
    @joins ||= begin
      required_joins = []
      return nil if inner_joins.empty?
      inner_joins.each do |inner_join|
        join_model_name = inner_join.first.to_s.camelcase
        next unless condition_models.include?(join_model_name)
        
        join_table_name = join_model_name.constantize.table_name
        join_on_field = inner_join.last.to_s
        required_joins << "INNER JOIN #{join_table_name} ON #{join_table_name}.id = #{table_name}.#{join_on_field}"
      end
      required_joins
    end 
  end
  
  def results
    @results ||= begin
      handle_empty_filter! 
      recs = model_class.paginate(:order => order_clause, :page => page, :per_page => per_page, :conditions => sql_conditions, :joins => joins)
      recs.wf_filter = self
      recs
    end
  end
  
  # sums up the column for the given conditions
  def sum(column_name)
    model_class.sum(column_name, :conditions => sql_conditions)
  end
  
end
