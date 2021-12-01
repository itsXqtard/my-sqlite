class Expression < String
  attr_accessor :column, :value
  def initialize(s)
    super(s)
    @s = s
  end

  def split(d)
    column, value = @s.split(d)
    @column = column
    @value = value
    self
  end

  def replace_and_drop
    delimiters = [/(\+)/, /(\;)/]
    split = @value.split(Regexp.union(delimiters)).reject {|key| key == "+" || key == "" || key ==";"}
    @value = split.join(" ").delete_prefix("'").delete_suffix("'")
  end

  def drop_delimiter
    @column = @column.delete_prefix("\+").delete_suffix("\+")
  end


  def drop_single_quote_from_rhs
    return [self.drop_delimiter, self.replace_and_drop]
  end
end
