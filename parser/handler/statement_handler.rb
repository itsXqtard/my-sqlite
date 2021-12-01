
require_relative './../action/select_action.rb'
require_relative './../action/delete_action.rb'
require_relative './../action/insert_action.rb'
require_relative './../action/update_action.rb'
require_relative './../select_parser.rb'
require_relative './../insert_parser.rb'
require_relative './../update_parser.rb'
require_relative './../delete_parser.rb'

class StatementHandler

  def handleSelectStatement(tail)
    begin
      sel_statement = ParseSelect.new.parseSelect(tail)
      action = SelectAction.new
      rows = action.fetchSelectResult(sel_statement)
      action.formatResult(rows)
    rescue Exception => e 
      p e.message
    end
  end

  def handleInsertStatement(tail)
    begin
      ins_statement = ParseInsert.new.parseInsert(tail)
      action = InsertAction.new
      action.performInsert(ins_statement)
    rescue Exception => e 
      p e.message
    end
  end

  def handleUpdateStatement(tail)
    begin
      upd_statement = ParseUpdate.new.parseUpdate(tail)
      p upd_statement
      action = UpdateAction.new
      action.performUpdate(upd_statement)
    rescue Exception => e 
      p e.message
    end
  end

  def handleDeleteStatement(tail)
    begin
      del_statement = ParseDelete.new.parseDelete(tail)
      action = DeleteAction.new
      action.performDelete(del_statement)
    rescue Exception => e 
      p e.message
    end
  end

end