module Dateservice
    def Dateservice.get_month(mi)
        if(mi == 1)
            return 'January'
        elsif(mi == 2)
            return 'Febuary'
        elsif(mi == 3)
            return 'March'
        elsif(mi == 4)
            return 'April'
        elsif(mi == 5)
            return 'May'
        elsif(mi == 6)
            return 'June'
        elsif(mi == 7)
            return 'July'
        elsif(mi == 8)
            return 'August'
        elsif(mi == 9)
            return 'September'
        elsif(mi == 10)
            return 'October'
        elsif(mi == 11)
            return 'November'
        elsif(mi == 12)
            return 'December'
        else
            return 'INPUTERROR'
        end
    end
end