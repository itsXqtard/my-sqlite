require_relative './insert.rb'
class UPDATE < INSERT
  attr_accessor :where

  def set_where(col_name, criteria)
    @where = {}
    @where[:col_name] = col_name
    @where[:criteria] = criteria
  end
end