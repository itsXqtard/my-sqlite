class Update

  attr_accessor :table, :set, :where

  def initialize(table, set = nil, where = nil)
    @table = table
    @set = set
    @where = where
  end

  def set_where(where)
    @where = where
  end

  def set_update_attributes(attributes)
    @set = attributes
  end

  def set_attributes(row, set)
    set.each do |column_name, attribute|
      row[column_name] = attribute
    end
  end

  def write_to_file(rows, headers)
    CSV.open(@table, "w") do |csv|
      csv << headers
      rows.each do |row|
        csv << row
      end
    end
  end

  def set_rows(rows, set, where)
    rows.each do |row|
      if where.nil?
        self.set_attributes(row, set)
        next
      end
      if row[where.name] == where.criteria
        self.set_attributes(row, set)
      end
    end
  end

  def get_contents_from_file(table)
    contents = Struct.new(:header, :rows)
    rows = []
    old_table = CSV.parse(File.read(table), headers: true).each do |row|
      rows << row
    end
    headers = old_table.headers
    return contents.new(headers, rows)
  end

  def put
    content = self.get_contents_from_file(@table)
    self.set_rows(content.rows, @set, @where)    
    self.write_to_file(content.rows, content.header)
  end

end