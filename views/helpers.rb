require 'date'

class Helpers
  def self.signators
    [
      ['Mickael', 'Mickael Kurmann'],
      ['André', 'Andre Kurmann'],
      ['Yanick', 'Yanick Kurmann'],
      ['Vitor', 'Vitor Da Rocha'],
      ['JX', 'Jean-Xavier Porikian']
    ]
  end

  def self.dates(nb_of_weeks = 15)
    week_list = {}
    today = Date.today
    monday_this_week = Date.commercial(today.year, today.cweek, 1)
    limit = monday_this_week + nb_of_weeks * 7
    monday_this_week.step(limit, 7).each do |w|
      week_list[return_display_name_from_date(w)] = w.to_s
    end
    week_list
  end

  def self.return_display_name_from_date(date)
    weeknb = date.strftime('%g.%V')
    # weekstart_date = date.beginning_of_week
    weekstart = date.strftime('%d.%m')
    weekend = (date + 5).strftime('%d.%m')
    "#{weeknb} (#{weekstart}-#{weekend})"
  end
end
