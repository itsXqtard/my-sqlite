class INSERT
  attr_accessor :table, :attributes

  def initialize(table = "", attributes = {})
    @table = table
    @attributes = attributes
  end

  def put
    p "#{@table}, #{attributes.to_s}"
  end
end