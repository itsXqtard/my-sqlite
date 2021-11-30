require_relative './error/insert_error.rb'
require_relative './statements/insert.rb'

class ParseInsert
  attr_accessor :ins_statement

  def initialize()
    @ins_statement = INSERT.new
  end

  def gatherColumns(rest)
    stack = []
    columns = []
    is_values = false
    values = []

    rest.each do |token|
      if token == "("
        stack << token
      elsif token == ")"
        stack.pop.nil? == true ? (raise INS_ERROR::MISSING_PAREN) : stack.pop()
      else
        if token.upcase == "VALUES"
          is_values = true
          next
        end
        is_values ? values << token : columns << token
      end
    end

    if !stack.empty?
      raise INS_ERROR::MISSING_PAREN
    end
    columns = columns.reject { |keyword| keyword == "," }
    values = values.reject { |keyword| keyword == ";"}
    return [columns, values]
  end

  def combining_word(result, delimiter, rest)
    if rest.empty?
      raise "Missing single quote"
    end
    head, *tail = rest
    if head == delimiter
      return [result, tail]
    end
    #appends a comma to the previous element in result 
    if head == ","
      result[-1] += head
    else 
      result << head
    end
    
    combining_word(result, delimiter,tail)
  end

  def parseValues(values)
    words = []
    remaining = values
    while(!remaining.empty?)
      head, *tail = remaining
      if head == "'"
        separated, rest = combining_word([], "'", tail)
        words << separated.join(" ")
        remaining = rest
      else
        if head != ","
          words << head
        end
        remaining = tail
      end
    end
    return words

  end

  def parseColumnsForInsert(ins_statement, rest)
    if rest.empty?
      raise INS_ERROR::MISSING_TABLE
    end
    table, *tail = rest
    ins_statement.table = table
    # Does not handle case where values are apostrophes
    delimiters = [/(\+)/, /(\()/, /(,)/, /(\))/, /(\')/]
    formatted = Common.new.validateTokens(tail, delimiters)
    columns, values = gatherColumns(formatted)
    values = parseValues(values)
    if columns.length != values.length
      raise "Column count doesnt equal to value count"
    end
    ins_statement.attributes = Hash[columns.zip(values)]
    return ins_statement

  end


  def parseInsert(rest)
    if rest.empty?
      raise INS_ERROR::BODY
    end
    head, *tail = rest
    
    case head.upcase
    when "INTO"
      return parseColumnsForInsert(@ins_statement, tail)
    else
      raise INS_ERROR::MISSING_INTO_KEY_WORD
    end
  end

end

