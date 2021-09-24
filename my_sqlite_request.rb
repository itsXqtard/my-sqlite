require 'csv'
require 'tempfile'
require 'fileutils'

class JoinOn
    attr_accessor :col_name, :rows

    def initialize(col_name)
        @col_name = col_name
        @rows = []
        self
    end

    def append(row)
        @rows << row
        self
    end

    def length
        rows.length()
    end

    def inspect
        print "BEGIN\n"
        @rows.each do |row|
            print row.class
        end
        print "END\n"
    end
end
    


class MySqliteRequest

    def initialize
        @type_of_request    = :none
        @select_columns     = []
        @where_params       = []
        @insert_attributes  = {}
        @update_attributes  = {}
        @join_attributes    = {}
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
        @join_attributes[:table] = filename_db_b
        @join_attributes[:left_on] = column_on_db_a
        @join_attributes[:right_on] = column_on_db_b
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
        @table_name = table_name
        self
    end

    def set(data)
        if (@type_of_request == :update)
            @update_attributes = data
        end
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

    def print_update_type 
        puts "Update Attributes #{@update_attributes}"
    end

    def print_join_type
        puts "Join Attributes #{@join_attributes}"
    end

    def prints
        puts "Type of Request #{@type_of_request}"
        puts "Table Name #{@table_name}"
        if(@type_of_request == :select)
            print_select_type
            if(@join_attributes.empty? == false)
                print_join_type
            end
        elsif (@type_of_request == :insert)
            print_insert_type
        elsif (@type_of_request == :update)
            print_update_type
        elsif (@type_of_request == :join)
            print_join_type
        end
    end



    def _setTypeOfRequest(new_type)
        if(@type_of_request == :none or @type_of_request == new_type)
            @type_of_request = new_type
        else
            raise "Invalid: typeof request aready set to #{type_of_request} (new type => #{new_type}"
        end

    end

    def _run_insert
        File.open(@table_name, 'a') do |f|
            f << @insert_attributes.values.join(',')
        end
    end

    def _run_select
        result = []
        CSV.parse(File.read(@table_name), headers: true).each do |row|
            if (@where_params.empty? == true)
                result << row.to_hash.slice(*@select_columns)
                next
            end
            @where_params.each do |where_attr|
                if row[where_attr[0]] == where_attr[1]
                    result << row.to_hash.slice(*@select_columns)
                end
            end
        end
        p result
        result
    end


    def _run_update
        result = []
        temp = Tempfile.new
        old_csv = CSV.open(@table_name, "r", headers: true, return_headers: true)
        old_csv.readline
        new_csv = CSV.open(temp, "w", headers: old_csv.headers, write_headers: true)
        old_csv.each do |row|
            @update_attributes.each do |set_attr|
                row[set_attr[0]] = set_attr[1]
            end
            new_csv << row
        end
        old_csv.close
        new_csv.close
        FileUtils.move(temp.path, @table_name)
    end

    def create_table_lookup()
        table_lookup = {}
        CSV.parse(File.read(@join_attributes[:table]), headers: true).each do |row|
            key = @join_attributes[:right_on]
            if table_lookup.key?(row[key])
                join_on = table_lookup[row[key]]
                join_on.append(row)
            else
                join_on = JoinOn.new(row[key]).append(row)
                table_lookup[row[key]] = join_on
            end
        end
        table_lookup
    end

    def rename_colliding_headers(table, headers)
        headers.map do |header| 
            if (header == @join_attributes[:right_on])
                "#{table}.#{header}"
            else
                header 
            end
        end
    end

    def join_tables()

    end

    def get_table(table_name)
        CSV.open(table_name, "r", headers: true, return_headers: true)
    end

    def _run_join
        left_table = []
        right_table = []
        temp = Tempfile.new
        table_lookup = create_table_lookup()
        left_table = get_table(@table_name)
        right_table = get_table(@join_attributes[:table])

        left_table_header = rename_colliding_headers(@table_name, left_table.readline.headers)
        right_table_header = rename_colliding_headers(@join_attributes[:table], right_table.readline.headers) 


        csv_string = ""
        left_table.each do |row|
            key = row[@join_attributes[:right_on]]
            matching = table_lookup[key]
            matching_rows = matching.rows
            matching_rows.each do |matching_row|
                csv_string += row.to_s.strip + "," + matching_row.to_s
            end
        end
        new_csv = CSV.parse(csv_string, headers: left_table_header + right_table_header)
        
        result = []
        formated_select_columns = []
        @select_columns.each do |column|
            if (column == @join_attributes[:left_on])
                formated_select_columns.append("#{@table_name}.#{column}")
                formated_select_columns.append("#{@join_attributes[:table]}.#{column}")
            else
                formated_select_columns.append(column)
            end
        end   
        new_csv.each do |row|
            if (@where_params.empty? == true)
                result << row.to_hash.slice(*formated_select_columns)
                next
            end
            @where_params.each do |where_attr|
                if row["#{@table_name}.#{where_attr[0]}"] == where_attr[1]
                    result << row.to_hash.slice(*formated_select_columns)
                end
            end
        end
        p result
    end

    def run
        prints
        if (@type_of_request == :select)
            if(@join_attributes.empty? == true)
                _run_select
            else
                _run_join
            end
        elsif (@type_of_request == :insert)
            _run_insert
        elsif (@type_of_request == :update)
            _run_update
        end
    end

end

def _main()
    # request = MySqliteRequest.new
    # request = request.from('nba_player_data_lite.csv')
    # request = request.select('name')
    
    # p request.run
    request = MySqliteRequest.new
    request = request.from("nba_player_data_lite.csv")
    request = request.select(['name', 'year_start'])
    request = request.where('name', 'Mark Acres')
    request = request.join("name", "nba_player_data_lite_join.csv", "name")
    # request = request.update("nba_player_data_lite.csv")
    # request = request.set({"name" => "HI", "year_start" => "1991"})
    # request = request.insert('nba_player_data_lite.csv')
    # request = request.values({"name" => "Alaa Abdelnaby", "year_start" => "1991", "year_end" => "1995", "position" => "F-C", "height" => "6-10", "weight" => "240", "birth_date" => "June 24, 1968", "college" => "Duke University"})
    request.run
end

_main()

# "name" => "Alaa Abdelnaby", "year_start" => "1991", "year_end" => "1995", "position" => "F-C", "height" => "6-10", "weight" => "240", "birth_date" => "June 24, 1968", "college" => "Duke University"
