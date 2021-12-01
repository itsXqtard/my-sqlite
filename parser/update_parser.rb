require_relative './error/update_error.rb'
require_relative './expression/expression.rb'
require_relative './expression/expression_array.rb'
require_relative './statements/update.rb'

class ParseUpdate
  attr_accessor :upd_statement

  def initialize()
    @upd_statement = UPDATE.new
  end

  def filter_commas_and_semi(conditions)
    return conditions.reject { |keyword| keyword == ',' || keyword == ';'}
  end

  def splitByComma(rest)
    delimiters = [/(\,)/, /(\;)/]
    index_where = rest.find_index{|item| item.upcase == "WHERE" }
    #default to length of rest for `index_where` not finding WHERE in arr
    index_where = index_where.nil? == false ? index_where : rest.length
    sliced = rest[0, index_where]
    #This allows for easy splitting of white space
    joined = sliced.join("+")
    split_conditions = joined.split(Regexp.union(delimiters))
    tail = rest[index_where,rest.length - 1]
    return [filter_commas_and_semi(split_conditions), tail]
  end


  def parseWhere(upd_statement, rest)
    head, *tail = rest
    if head.upcase != "WHERE"
      raise UPD::MISSING_WHERE_KEY_WORD
    end
    expression = Expression_Array.new(tail).combine_with_delimiter.split("=")
    print("EXPRESSION: #{expression}\n")
    column, criteria = expression.drop_single_quote_from_rhs
    upd_statement.set_where(column, criteria)
    return upd_statement
  end

  def parseColumnsAndValues(attributes)
    columns = []
    values = []
    attributes.each do |attribute|
      expression = Expression.new(attribute).split("=")
      column, value = expression.drop_single_quote_from_rhs
      columns << column
      values << value
    end
    return Hash[columns.zip(values)]
  end

  def parseColumnsForUpdate(upd_statement, rest)
    if rest.empty?
      raise UPD_ERROR::MISSING_CONDITIONS
    end
    split_attributes, tail = splitByComma(rest)
    attributes = parseColumnsAndValues(split_attributes)
    upd_statement.attributes = attributes
    if !tail.empty?
      return parseWhere(upd_statement, tail)
    end
    return upd_statement
  end

  def parseUpdate(rest)
    if rest.empty?
      raise UPD_ERROR::MISSING_TABLE
    end
    table, *tail = rest
    @upd_statement.table = table
    tk, *tail = tail
    case tk.upcase
    when "SET"
      return parseColumnsForUpdate(@upd_statement, tail)
    else
      raise UPD_ERROR::MISSING_SET_KEY_WORD
    end
  end

end