class Pagination
    ##
    # Default constructor for Pagination object.
   def initialize(count, page)
        @start_index = 0
        if(!page)
            @start_index = 0
            @current_page = 1
        else
            @start_index = page.to_i * 10
            @current_page = page.to_i
            @start_index -= 10
        end
        @num_pages = count / 10
        if(count % 10 > 0)
            @num_pages += 1
        end
   end
   ##
   # Gets the starting ID within the internal database.
   def get_start_index()
       return @start_index
   end
   ##
   # Gets the currently selected page to load from the database.
   def get_current_page()
       return @current_page
   end
   ##
   # Gets the total number of pages worth of data within the database.
   def get_num_pages()
       return @num_pages
   end
end