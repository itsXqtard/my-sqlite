class DELETE
  attr_accessor :table, :where
  
  def initialize(table = "")
    @table = table
  end

  def set_where(col_name, criteria)
    @where = {}
    @where[:col_name] = col_name
    @where[:criteria] = criteria
  end
end