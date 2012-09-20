module VacationsHelper
  def show_to_csv
    decimal_separator = l(:general_csv_decimal_separator)
    export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      # csv header fields
      csv << [ 
        l(:field_vacation_status), 
        l(:field_description),        
        l(:field_vacation_start_date), 
        l(:field_vacation_end_date)
      ] 
      
      # csv lines
      @scope.all(:order => :start_date).each do |vacation_range|
        csv << [
          vacation_range.vacation_status.name,
          vacation_range.description,          
          format_date(vacation_range.start_date), 
          format_date(vacation_range.end_date)
        ]
      end
    end
    export    
  end
end
