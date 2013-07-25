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

namespace :dev do

# <ActiveRecord::ConnectionAdapters::SQLiteColumn:0x007fdffc77bee0
#  @coder=nil,
#  @default=nil,
#  @limit=nil,
#  @name="id",
#  @null=false,
#  @precision=nil,
#  @primary=true,
#  @scale=nil,
#  @sql_type="INTEGER",
#  @type=:integer>

# <struct ActiveRecord::ConnectionAdapters::IndexDefinition
#  table="will_filter_filters",
#  name="index_will_filter_filters_on_user_id",
#  unique=false,
#  columns=["user_id"],
#  lengths=nil>

  desc "Annotates tr8n models"
  task :annotate => :environment do
    if ENV["app"]
      files = Dir[File.expand_path("#{Rails.root}/app/models/*.rb")]
    else
      files = Dir[File.expand_path("#{File.dirname(__FILE__)}/../../app/models/tr8n/*.rb")]
    end

    files.sort.each do |file|
      if file.rindex('tr8n')
        class_name = file[file.rindex('tr8n')..-1].gsub('.rb', '').camelcase
      else
        class_name = file.split('/').last.gsub('.rb', '').camelcase
      end
      klass = class_name.constantize
      lines = []
      lines << "#--"
      lines << "# Copyright (c) 2010-2013 Michael Berkovich, tr8nhub.com"
      lines << "#"
      lines << "# Permission is hereby granted, free of charge, to any person obtaining"
      lines << "# a copy of this software and associated documentation files (the"
      lines << "# \"Software\"), to deal in the Software without restriction, including"
      lines << "# without limitation the rights to use, copy, modify, merge, publish,"
      lines << "# distribute, sublicense, and/or sell copies of the Software, and to"
      lines << "# permit persons to whom the Software is furnished to do so, subject to"
      lines << "# the following conditions:"
      lines << "#"
      lines << "# The above copyright notice and this permission notice shall be"
      lines << "# included in all copies or substantial portions of the Software."
      lines << "#"
      lines << "# THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND,"
      lines << "# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF"
      lines << "# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND"
      lines << "# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE"
      lines << "# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION"
      lines << "# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION"
      lines << "# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
      lines << "#++"
      lines << "#"
      lines << "#-- #{class_name} Schema Information"
      lines << "#"
      lines << "# Table name: #{klass.table_name}"
      lines << "#"

      name_width = 0
      type_width = 0
      sql_type_width = 0

      klass.columns.each do |column|
        name_width = [column.name.to_s.length, name_width].max
        type_width = [column.type.to_s.length, type_width].max
        sql_type_width = [column.sql_type.to_s.length, sql_type_width].max
      end

      klass.columns.each do |column|
        line = ["#  "]
        line << column.name
        line << (" " * (name_width - column.name.length + 4))
        # line << column.type.to_s
        # line << (" " * (type_width - column.type.to_s.length + 4))
        line << column.sql_type
        line << (" " * (sql_type_width - column.sql_type.to_s.length + 4))

        meta = []
        meta << "not null" if !column.null
        meta << "primary key" if column.primary
        meta << "default = #{column.default.to_s}" if column.default
        line << meta.join(', ')

        lines << line.join('')
      end

      lines << "#"
      lines << "# Indexes"
      lines << "#"

      indexes = ActiveRecord::Base.connection.indexes(klass.table_name)

      name_width = 0

      indexes.each do |index|
        name_width = [index.name.to_s.length, name_width].max
      end

      indexes.each do |index|
        line = ["#  "]
        line << index.name
        line << (" " * (name_width - index.name.length + 4))
        line << "(#{index.columns.join(', ')})"
        line << " "
        line << "UNIQUE" if index.unique
        lines << line.join('')
      end

      lines << "#"
      lines << "#++"

      pp "Updating #{file}..."

      model_file = File.open(file, "r+")
      old_lines = model_file.readlines
      model_file.close
      
      model_file = File.new(file, "w")
      lines.each do |line|
        model_file.write(line + "\r\n")
      end

      in_class = false
      old_lines.each do |line|
        in_class = true unless line.index("#") == 0

        next unless in_class
        model_file.write(line)
      end
      model_file.close      

      # file_name = file[file.rindex('tr8n')+5..-1].gsub('.rb', '')
      # path = File.expand_path("#{File.dirname(__FILE__)}/../../app") + "/data"
      # FileUtils.mkdir_p(path) unless File.exist?(path)

      # File.open("#{path}/#{file_name}.txt", 'w') do |f|
      #   f.write(lines.join("\r\n"))
      # end
    end
  end

end