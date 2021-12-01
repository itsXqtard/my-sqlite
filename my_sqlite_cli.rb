
require "readline"
require 'csv'
require_relative './parser/handler/statement_handler.rb'
require_relative './parser/error/statement_error.rb'


class MySqliteCLI

  def parseInput(inputs, tokens)
    if inputs.empty?
      return
    end
    head, *tail = inputs
    stmtHandler = StatementHandler.new
    case head.upcase
    when "SELECT"
      stmtHandler.handleSelectStatement(tail)
    when "INSERT"
      stmtHandler.handleInsertStatement(tail)
    when "UPDATE"
      stmtHandler.handleUpdateStatement(tail)
    when "DELETE"
      stmtHandler.handleDeleteStatement(tail)
    else
      raise ERROR::STATEMENT
    end
  end



  def tokenize(buf)
    command_line_inputs = buf.split
    tokens = []
    begin
      parseInput(command_line_inputs, tokens)
    rescue Exception => e 
      p e.message
    end
  end

  def run!
    prompt = "my_sqlite_cli> "
    while buf = Readline.readline(prompt, true)
      if buf == 'quit'
        break
      end
      self.tokenize(buf)
    end
  end

end

mysqlcli = MySqliteCLI.new
mysqlcli.run!