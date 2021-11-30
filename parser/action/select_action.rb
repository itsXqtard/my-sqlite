require_relative './../../evaluator/my_sqlite_request.rb'
class SelectAction


  def printDivider(dash_length)
    print("\n")
    dash_length.each do |len|
      len.times{print("=")}
    end
    print("\n")
  end
  
  def printHeaders(headers)
    dash_length = []
    spacer = 12
    headers.keys.each do  |header|
      print("#{header}")
      spacer.times{print(" ")}
      #length for the header plus the space in between
      dash_length << header.to_s.length() + spacer
    end
    dash_length[-1] -= spacer
    printDivider(dash_length)
    return dash_length
  end

  def printRows(rows, dash)
    rows.each do |row|
      row.values.each_with_index do |value, index|
        if !value.nil?
          print("#{value}")
          (dash[index] - value.length).times{print(" ")}
        end
      end
      print("\n") 
    end
  end

  def formatResult(rows)
    if rows.empty?
      return "No Result"
    end
    
    dash_length = printHeaders(rows[0])
    printRows(rows, dash_length)
  end

  def fetchSelectResult(sel_statement)
    request = MySqliteRequest.new
    request = request.from(sel_statement.table)
    request = request.select(sel_statement.columns)
    join_table = sel_statement.join_table
    col_a = sel_statement.on_col_a
    col_b = sel_statement.on_col_b

    if join_table.nil? == false && col_a.nil? == false && col_b.nil? == false
      request = request.join(col_a, join_table, col_b)
    end

    if sel_statement.where.nil? == false
      request = request.where(sel_statement.where.name, sel_statement.where.criteria)
    end
    if sel_statement.order.nil? == false
      request = request.order(sel_statement.order.by, sel_statement.order.col_name)
    end
    request.run
  end

end