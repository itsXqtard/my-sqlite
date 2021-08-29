require 'csv'

class MySqliteRequest

    def initialize
        @type_of_request    = :none
        @select_columns     = []
        @where_params       = []
        @insert_attributes  = []
        @table_name         = nil
        @order              = :asc
    end

    def from(table_name)
        @table_name = table_name
        self
    end

    def select(columns)
        if(columns.is_a?(Array))
            @select_columns += columns.collect { |elem| elem.to_s}
        else
            @select_columns << columns.to_s
        end
        self._setTypeOfRequest(:select)
        self
    end

    def where(column_name, criteria)
        @where_params << [column_name, criteria]
        self
    end

    def join(column_on_db_a, filename_db_b, column_on_db_b)
        self
    end

    def order(order, column_name)
        self
    end

    def insert(table_name)
        self._setTypeOfRequest(:insert)
        @table_name = table_name
        self
    end

    def values(data)
        if (@type_of_request == :insert)
            @insert_attributes = data
        else
            raise 'Wrong type of request to call values()'
        end
        self
    end

    def update(table_name)
        self._setTypeOfRequest(:update)
        self
    end

    def set(data)
        self
    end

    def delete
        self._setTypeOfRequest(:delete)
        self
    end

    def print_select_type 
        puts "Select Attributes #{@select_columns}"
        puts "Where Attributes #{@where_params}"
    end

    def print_insert_type 
        puts "Insert Attributes #{@insert_attributes}"
    end



    def prints
        puts "Type of Request #{@type_of_request}"
        puts "Table Name #{@table_name}"
        if(@type_of_request == :select)
            print_select_type
        elsif (@type_of_request == :insert)
            print_insert_type
        end
    end



    def _setTypeOfRequest(new_type)
        if(@type_of_request == :none or @type_of_request == new_type)
            @type_of_request = new_type
        else
            raise "Invalid: typeof request aready set to #{type_of_request} (new type => #{new_type}"
        end

    end

    def _run_select
        result = []
        CSV.parse(File.read(@table_name), headers: true).each do |row|
            @where_params.each do |where_attr|
                if row[where_attr[0]] == where_attr[1]
                    result << row.to_hash.slice(*@select_columns)
                end
            end
        end
        result
    end

    def run
        prints
        if (@type_of_request == :select)
            _run_select
        end
    end

end

def _main()
    # request = MySqliteRequest.new
    # request = request.from('nba_player_data_lite.csv')
    # request = request.select('name')
    # request = request.where('name', 'Zaid Abdul-Aziz')
    # p request.run
    request = MySqliteRequest.new
    request = request.insert('nba_player_data.csv')
    request = request.values({"name" => "Alaa Abdelnaby", "year_start" => "1991", "year_end" => "1995", "position" => "F-C", "height" => "6-10", "weight" => "240", "birth_date" => "June 24, 1968", "college" => "Duke University"})
    request.run
end

_main()

# "name" => "Alaa Abdelnaby", "year_start" => "1991", "year_end" => "1995", "position" => "F-C", "height" => "6-10", "weight" => "240", "birth_date" => "June 24, 1968", "college" => "Duke University"
