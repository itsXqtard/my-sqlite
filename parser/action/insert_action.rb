require_relative './../../evaluator/my_sqlite_request.rb'

class InsertAction

  def performInsert(ins_statement)
    request = MySqliteRequest.new
    request = request.insert(ins_statement.table)
    request = request.values(ins_statement.attributes)
    request.run
  end
end