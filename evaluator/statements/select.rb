class Select

  attr_accessor :table, :columns, :join, :where, :tableB, :col_a, :col_b

  def initialize(table, columns, where= nil, order_by = nil, join = false)
    @table = table
    @columns = columns
    @where = where
    @join = join
    @order_by = order_by
  end

  def set_order_by(order, column_name)
    order_by = Struct.new(:order, :column)
    if order.nil?
      @order_by = order_by.new(:asc, column_name)
    else
      @order_by = order_by.new(order, column_name)
    end
  end

  def set_where(where)
    @where = where
  end

  def join_on(tableB = nil, col_a = nil, col_b = nil, join = false)
    @join = join
    @tableB = tableB
    @col_a = col_a
    @col_b = col_b
    self
  end

  def is_join
    return @join
  end

  def get_rows(table)
    rows = []
    CSV.parse(File.read(table), headers: true).each do |row|
      rows << row
    end

  end

  def slice(row, all)
    if (all)
      if @columns.empty?
        return row.to_hash
      end
      return row.to_hash.slice(*@columns)
    end
    if row[where.name] == where.criteria
      if @columns.empty?
        return row.to_hash
      end
      return row.to_hash.slice(*@columns)
    end
    return {}
  end

  def filter(rows)
   return rows.reject { |row| row == {} }
  end

  def to_csv_row(match)
    values = match.tableA_row.fields + match.tableB_row.fields
    headers = match.tableA_row.headers + match.tableB_row.headers
    CSV::Row.new(headers, values)
  end

  def map_matches_to_csv_row(matches)
    return matches.map { |match| to_csv_row(match) }
  end

  def map_slice_to_row(rows)
    return rows.map { |row| slice(row, @where.nil?) }
  end

  def sort_result(rows)
    #sorts by the column name if there is a value. If there is a nil value it gets put towards the front
    sorted = rows.sort_by { |hsh| [hsh[@order_by.column] ? 1 : 0, hsh[@order_by.column]] }
    if @order_by.order == :desc
      return sorted.reverse
    end
    return sorted
  end

  def gather_matches(tableA, tableB)
    matching = Struct.new(:tableA_row, :tableB_row)
    matches = []
    tableA.each do |tableA_row|
      tableB.each do |tableB_row|
        if tableA_row[@col_a] == tableB_row[@col_b]
          match = matching.new(tableA_row, tableB_row)
          matches << match
        end
      end
    end
    return matches
  end


  def join_and_get
    tableA = self.get_rows(@table)
    tableB = self.get_rows(@tableB)

    rows = gather_matches(tableA, tableB)
    rows = self.map_matches_to_csv_row(rows)
    rows = self.map_slice_to_row(rows)
    if @order_by.nil?
      return filter(rows)
    end
    return sort_result(filter(rows))
  end



  def get
    result = []
    CSV.parse(File.read(@table), headers: true).each do |row|
      result << slice(row, @where.nil?)
    end
    if @order_by.nil?
      return filter(result)
    end
    return sort_result(filter(result))
  end
end