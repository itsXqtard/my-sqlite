class Insert

  attr_accessor :table, :attributes

  def initialize(table, attributes = {})
    @table = table
    @attributes = attributes
  end

  def get_insert_attributes
    return @attributes
  end

  def set_insert_attributes(attributes)
    @attributes = attributes
  end

  def add_quotation(str)
    return "\"#{str}\""
  end 

  def update_rows(attributes)
    rows = []
    attributes.each do |key, value|
      #check for values that have "," which indicates a date.
      #maintain quotations if date
      if value.match(",")
        rows << add_quotation(value)
      else
        rows << value
      end
    end
    return rows
  end

  def post
    File.open(@table, 'a') do |f|
      row = update_rows(@attributes)
      f << row.join(',') + "\n"
    end
  end

end