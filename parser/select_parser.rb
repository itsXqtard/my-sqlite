require_relative './error/select_error.rb'
require_relative './statements/select.rb'
require_relative './../common.rb'


class ParseSelect
  attr_accessor :sel_statement

  def initialize()
    @sel_statement = SELECT.new
  end

  def parseOnCondition(sel_statement, rest)
    head, *tail = rest
    if rest.length < 3
      raise ERROR::MISSING_LHS_OR_RHS_CONDITION
    end
    if rest.length >= 3 && rest[2].upcase != "WHERE" || rest[2].upcase != "ORDER"
      lhs = rest[0]
      rhs = rest[2]

      sel_statement.on_col_a = lhs
      sel_statement.on_col_b = rhs
      return sel_statement
    else
      raise ERROR::INCORRECT_RHS_ON_CONDITION
    end
  end

  def splitConditions(rest)
    condition = []
    tail = []
    rest.each do |word|
      if word.upcase == "ORDER"
        tail << word
        next
      end
      if !tail.empty?
        tail << word
      else
        condition << word
      end
    end
    struct_condition = Struct.new(:where, :rest)
    return struct_condition.new(condition, tail)
  end

  def handleWhere(conditions)
    if conditions.length < 3
      raise ERROR::INCORRECT_WHERE_CONDITION
    end
    if conditions[1] == "="
      filtered = conditions[2, conditions.length].reject{|tk| tk == ";"}
      criteria = filtered.join(" ")
      #gets rid of the leading and trailing single quote
      print("CRITERIA: #{criteria}\n")
      criteria = criteria.delete_prefix("'").delete_suffix("'")
      where = Struct.new(:name, :criteria)
      return where.new(conditions[0], criteria)
    else
      raise ERROR::INCORRECT_RHS_WHERE_CONDITION
    end
  end

  def parseWhereCondition(sel_statement, rest)
    if rest.empty?
      raise ERROR::MISSING_WHERE_CONDITION
    end
    if rest.length < 3
      raise ERROR::INCORRECT_WHERE_CONDITION
    end
    
    condition = splitConditions(rest)
    where = handleWhere(condition.where)
    sel_statement.where = where

    if !condition.rest.empty?
      return parseOrderByCondition(sel_statement, condition.rest[1..-1])
    end
    return sel_statement
  end

  def parseOrderByCondition(sel_statement, rest)
    head, *tail = rest.reject{|tk| tk == ";"}
    order_by = Struct.new(:by, :col_name)
    if head == "BY" && tail.length == 2
      if tail[1].upcase == 'ASC'
        sel_statement.order = order_by.new(:asc, tail[0])
      elsif tail[1].upcase == 'DESC'
        sel_statement.order = order_by.new(:desc, tail[0])
      else
        raise ERROR::INCORRECT_ORDER_BY_KEY_WORD
      end
    else
      raise ERROR::INCORRECT_LENGTH_ORDER_BY
    end
    return sel_statement
  end

  def parseSelectConditions(sel_statement, rest)
    head = rest.first
    where_index = rest.find_index{|item| item.upcase == "WHERE" }
    order_index = rest.find_index{|item| item.upcase == "ORDER" }
    if where_index.nil? && order_index.nil?
      return parseOnCondition(sel_statement, rest)
    elsif (where_index && order_index.nil?)
      start_of_where = rest[where_index + 1, rest.length] 
      sel_statement = parseWhereCondition(sel_statement, start_of_where)
    elsif (order_index && where_index.nil?)
      start_of_order_by = rest[order_index + 1, rest.length] 
      sel_statement = parseOrderByCondition(sel_statement, start_of_order_by)
    elsif where_index < order_index 
      start_of_where = rest[where_index + 1, rest.length] 
      sel_statement = parseWhereCondition(sel_statement, start_of_where)
    else
      raise ERROR::IMPROPER_ORDERING_CONDITION
    end
    return parseOnCondition(sel_statement, rest)    
  end

  def parseJoinOn(sel_statement, rest)
    on, *tail = rest
    case on.upcase
    when "ON"
      return parseSelectConditions(sel_statement, tail)
    else
      raise ERROR::MISSING_ON_CLAUSE
    end

  end

  def parseJoin(sel_statement, rest)
    if rest.empty?
      raise ERROR::MISSING_JOIN_TABLE
    end
    table, *tail = rest
    
    case table.upcase
    when "ON"
      raise ERROR::INCORRECT_JOIN
    end
    sel_statement.join_table = table
    return parseJoinOn(sel_statement, tail)
  end

  def parseSelectFrom(sel_statement, rest)
    if rest.empty?
      raise ERROR::TABLE_MISSING
    end
    table, *tail = rest
    sel_statement.table = table
    if tail.empty?
      return sel_statement
    end
    head, *tail = tail
    delimiters = [/(\+)/, /(=)/, /(\;)/]
    tail = Common.new.validateTokens(tail, delimiters)
    case head.upcase
    when "JOIN"
      return parseJoin(sel_statement, tail)
    when "WHERE"
      return parseWhereCondition(sel_statement, tail)
    when "ORDER"
      return parseOrderByCondition(sel_statement, tail)
    else
      raise ERROR::WRONG_CONSTRAINTS
    end
    
    return sel_statement
  end

  def parseStar(sel_statement, rest)
    if rest.empty?
      raise ERROR::MISSING_FROM_CLAUSE
    end
    head, *tail = rest
    case head.upcase
    when "FROM"
      return parseSelectFrom(sel_statement, tail)
    end
    return sel_statement
  end

  def gatherColumns(columns, rest)
    if rest.empty?
      raise ERROR::MISSING_FROM_CLAUSE
    end
    head, *tail = rest
    if head.upcase == "FROM"
      return [columns, tail]
    end
    columns << head.delete_suffix(",")
    return gatherColumns(columns, tail)
  end

  def parseSelectColumns(sel_statement, rest)
    begin
      (columns, tail) = gatherColumns([], rest)
      sel_statement.columns = columns
      return parseSelectFrom(sel_statement, tail)
    rescue
      raise 
    end
    
  end

  def parseSelect(rest)
    if rest.empty?
      raise ERROR::BODY
    end
    head, *tail = rest
    
    case head.upcase
    when "*"
      @sel_statement.columns = []
      return parseStar(@sel_statement, tail)
    when "FROM"
      raise ERROR::COLUMN_FORMAT
    else
        return parseSelectColumns(@sel_statement, rest) 
    end
  end
  
end