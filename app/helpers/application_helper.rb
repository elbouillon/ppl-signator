module ApplicationHelper
  def future_week_list(nb_of_weeks = 15)
    week_list = {}
    ( Date.today..nb_of_weeks.weeks.from_now.to_date ).select { |d| d.cwday == 1 }.each do |w|
      week_list[return_display_name_from_date(w)] = w.to_s
    end
    week_list
  end

  def return_display_name_from_date(date)
    OrderFile.display_name_from_date(date)
  end
end
