class Delete
  attr_accessor :table, :where

  def initialize(table, where = nil)
    @table = table
    @where = where
  end

  def set_where(where)
    @where = where
  end

    
  def write_to_file(rows, headers)
    CSV.open(@table, "w") do |csv|
      csv << headers
      rows.each do |row|
        csv << row
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

  def delete_rows(rows, headers)
    removed_content = []
    rows.each do |row|
      if row[@where.name] != @where.criteria
        removed_content << row
      end
    end
    write_to_file(removed_content, headers)
  end

  def delete
    contents = get_contents_from_file(@table)
    if @where.nil?
      write_to_file([], contents.header)
    else
      self.delete_rows(contents.rows, contents.header)
    end
  end

end