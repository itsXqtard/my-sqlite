require_relative './error/delete_error.rb'
require_relative './statements/delete.rb'
require_relative './expression/expression_array.rb'

class ParseDelete

  attr_accessor :del_statement

  def initialize()
    @del_statement = DELETE.new
  end

  def parseWhere(del_statement, rest)
    tk, *tail = rest
    case tk.upcase
    when "WHERE"
      expression = Expression_Array.new(tail).combine_with_delimiter.split("=")
      column, criteria = expression.drop_single_quote_from_rhs
      del_statement.set_where(column, criteria)
      return del_statement
    else
      raise "Incorrect token to start WHERE clause"
    end
  end

  def parseDelete(rest)
    if rest.empty?
      raise DEL_ERROR::MISSING_TABLE
    end
    tk, *tail = rest
    @del_statement.table = tk
    if !tail.empty?
      return parseWhere(@del_statement, tail)
    end
    return @del_statement
  end

end

