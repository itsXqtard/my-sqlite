class MySqliteRequest

    def initialize
        @type_of_request  = :none
        @select_columns   = []
        @table_name       = nil
        @order            = :asc
    end

    def from(table_name)
        self
    end

    def select(array)
        self._setTypeOfRequest(:select)
        self
    end

    def where(column_name, criteria)
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
        self
    end

    def values(data)
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

    def prints
        puts "Type of Request #{@type_of_request}"
    end

    def _setTypeOfRequest(new_type)
        if(@type_of_request == :none or @type_of_request == new_type)
            @type_of_request = new_type
        else
            raise "Invalid: typeof request aready set to #{type_of_request} (new type => #{new_type}"
        end

    end

    def run
        prints
    end

end

def _main()
    request = MySqliteRequest.new
    request = request.from('nba_player_data.csv')
    request = request.select('name')
    request = request.where('birth_state', 'Indiana')
    request.run
end

_main()