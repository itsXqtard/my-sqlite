class SELECT
  attr_accessor :table, :columns, :join_table, :on_col_a, :on_col_b, :where, :order
  def initialize(table = "", columns = [])
    @table = table
    @columns = columns
  end

  def put
    p "#{@table}, #{columns.to_s}, #{join_table}, #{on_col_a}, #{on_col_b}, #{where.to_s} #{order_by.to_s}"
  end
end