require_relative './../../evaluator/my_sqlite_request.rb'
class UpdateAction

  def performUpdate(upd_statement)
    request = MySqliteRequest.new
    request = request.update(upd_statement.table)
    request = request.set(upd_statement.attributes)
    if upd_statement.where.nil? == false 
      request = request.where(upd_statement.where[:col_name], upd_statement.where[:criteria])
    end
    request.run
  end
end