require_relative './../../evaluator/my_sqlite_request.rb'
class DeleteAction
  
  def performDelete(del_statement)
    request = MySqliteRequest.new
    request = request.from(del_statement.table)
    request = request.delete
    if del_statement.where.nil? == false
      request = request.where(del_statement.where[:col_name], del_statement.where[:criteria])
    end
    request.run
  end

end