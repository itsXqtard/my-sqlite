require_relative './statement_handler.rb'
require_relative './../statements/select.rb'
require_relative './../statements/update.rb'
require_relative './../statements/insert.rb'
require_relative './../statements/delete.rb'

class Query
  attr_accessor :statement, :table, :columns
  def initialize
    @table = ""
    @columns = []

    statement = Statement.new
    statement.set_type(:none)
    @statement = statement
  end

  def get_type
    return @statement.get_type
  end

  def get_headers_from_table
    headers_set = Set.new
    headers = CSV.parse(File.read(table), headers: true).headers
    headers.each do |header|
      headers_set << header

    end
    return headers_set
  end

  def set_statement_type(type)
    @statement.set_type(type)
  end

  def set_statement(stmt)
    @statement.set_statement_instance(stmt)
  end

  def get_table
    return @table
  end

  def set_table(name)
    @table = name
  end
  
  def get_values()
    return @values
  end

  def set_columns(columns)
    if(columns.is_a?(Array))
      @columns += columns.collect { |elem| elem.to_s}
    else
        @columns << columns.to_s
    end
  end

  def set_where(column_name, criteria)
    where = Struct.new(:name, :criteria)
    where = where.new(column_name, criteria)
    if @statement.get_type == :select
      @statement.get_select.set_where(where)
    elsif @statement.get_type == :update
      @statement.get_update.set_where(where)
    elsif @statement.get_type == :delete
      @statement.get_delete.set_where(where)
    else
      raise "Where clause is not allowed with this statement type"
    end
  end

  def set_values(data)
    @statement.get_insert.set_insert_attributes(data)
  end

  def set_update(attributes)
    @statement.get_update.set_update_attributes(attributes)
  end

  def set_join_values(column_on_db_a, filename_db_b, column_on_db_b)
    @statement.get_select.join_on(filename_db_b, column_on_db_a, column_on_db_b, true)
  end

  def set_order_values(order, column_name)
    @statement.get_select.set_order_by(order, column_name)
  end

  def create_select
    return Select.new(@table, @columns)
  end

  def create_insert
    return Insert.new(@table)
  end

  def create_update
    return Update.new(@table)
  end

  def create_delete
    return Delete.new(@table)
  end
=begin
    This section of code executes the sql statements
=end
  
  def fetch_select
    if @statement.get_select.is_join
      return @statement.get_select.join_and_get
    else
      return @statement.get_select.get
    end
  end

  def perform_insert
    @statement.get_insert.post
  end

  def perform_update
    @statement.get_update.put
  end

  def perform_delete
    @statement.get_delete.delete
  end
  
end