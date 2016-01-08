module DuoLang
    module query_send
        def get_by_type()
            # Start a job and return it's ID
        end
        def get_page_count(query)
            # Get number of pages of results of given query
        end
    end
    module result_recieve
        def get_by_id(job_id)
            # Find output of job by its timestamp
        end
    end
end