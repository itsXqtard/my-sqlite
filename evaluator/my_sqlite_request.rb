
require 'csv'
require 'set'

require_relative './handler/query_handler.rb'

class MySqliteRequest
  attr_accessor :query
  def initialize
    @query = Query.new
  end


  #Creates an instance for the different types
  def set_statement(type)
    stmt = :none
    if type == :select
      stmt = @query.create_select
    elsif type == :update 
      stmt = @query.create_update
    elsif type == :insert
      stmt = @query.create_insert
    elsif type == :delete
      stmt = @query.create_delete
    else
      raise 'Wrong type for call to set_statement()'
    end
    @query.set_statement_type(type)
    @query.set_statement(stmt)
    
  end

  def from(table_name)
    @query.set_table(table_name)
    self
  end

  def select(columns)
    @query.set_columns(columns)
    self.set_statement(:select)
    self
  end

  def where(column_name, criteria)
    @query.set_where(column_name, criteria)
    self
  end

  def insert(table_name)
    @query.set_table(table_name)
    self.set_statement(:insert)
    self
  end

  def update(table_name)
    @query.set_table(table_name)
    self.set_statement(:update)
    self
  end

  def validate_values(columns)
    if @query.get_type == :insert
      headers_set = @query.get_headers_from_table
      columns.each do |column|
        if !headers_set.include?(column)
          return false
        end
      end
      return true
    else
      raise "Wrong type for call to validate_values()"
    end
  end

  def values(data)
    if @query.get_type == :insert
      if self.validate_values(data.keys)
        @query.set_values(data)
      else
        raise "One of the column name not in the csv header"
      end
      
    else
      raise 'Wrong type of request to call values()'
    end
    
    self
  end

  def set(data)
    if @query.get_type == :update
      @query.set_update(data)
    else
      raise 'Wrong type of request to call set()'
    end
    self
  end

  def join(column_on_db_a, filename_db_b, column_on_db_b)
    if @query.get_type == :select
      @query.set_join_values(column_on_db_a, filename_db_b, column_on_db_b)
    else
      raise 'Wrong type of request to call join()'
    end
    self
  end

  def order(order, column_name)
    if @query.get_type == :select
      @query.set_order_values(order, column_name)
    else
      raise 'Wrong type of request to call order()'
    end
    self
  end

  def delete
    if query.get_table == ""
      raise "Set table first before call to delete"
    end
    self.set_statement(:delete)
    self
  end


  def run
    if @query.get_type == :select
      @query.fetch_select
    elsif @query.get_type == :insert
      @query.perform_insert
    elsif @query.get_type == :update
      @query.perform_update
    elsif @query.get_type == :delete
      @query.perform_delete
    else
      raise "Cannot not make call to run with no type defined"
    end
  end

end


=begin 

BELOW ARE TEST FUNCTIONS TO TEST EACH FUNCTIONALITY. YOU MAY YOU THE MAIN I HAVE PROVIDED BELOW.
TEST THEME INDIVIDUALLY. NOT FOR testing all at once. Uncomment which test you want to test then comment it back when done.

=end





def test_select(request, whereEnabled)
  request = request.from("nba_players.csv")
  request = request.select([])
  if whereEnabled
    request = request.where('Player', 'Curly Armstrong')
  end
  return request
end

def test_insert(request)
  request = request.insert("nba_player_data.csv")
  request = request.values({"name" => "First Last", "year_start" => "1994", "year_end" => "2011", "position" => "F-C", "height" => "5-02", "weight" => "130", "birth_date" => "January 24, 1993", "college" => "Cal Poly"})
  return request
end

def test_update(request, whereEnabled)
  request = request.update("nba_player_data.csv")
  request = request.set({"name" => "Last First", "year_start" => "2021"})
  if whereEnabled
    request = request.where("name", "First Last")
  end
end


def test_join(request, whereEnabled, orderEnabled)
  request = request.from("nba_player_data.csv")
  request = request.select(['name', 'height'])
  request = request.join("name", "nba_players.csv", "Player")
  if whereEnabled
    request = request.where('name', 'Tom Abernethy')
  end
  
  #order by
  if orderEnabled
    request = request.order(:desc, "name")
  end

  return request
end

def test_delete(request, whereEnabled)
  request = request.from("nba_player_data.csv")
  request = request.delete
  if whereEnabled
    request = request.where('name', 'Last First')
  end
  
  return request
end




# def _main()
#   request = MySqliteRequest.new

#   ##select
#   # request = test_select(request, true)


#   ##insert 
#   # request = test_insert(request)


#   ## update
#   # request = test_update(request, true)


#   ##join
#   # request = test_join(request, false, true)


#   ## #delete
#   # request = test_delete(request, false)
#   request.run
# end

# _main()