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

  def self.dates(nb_of_weeks: 15)
    week_list = {}
    limit = Date.today + nb_of_weeks * 7
    Date.today.step(limit, 7).select { |d| d.cwday == 1 }.each do |w|
      week_list[return_display_name_from_date(w)] = w.to_s
    end
    week_list
  end

  def self.return_display_name_from_date(date)
    date = date.to_date
    weeknb = date.strftime('%g.%V')
    # weekstart_date = date.beginning_of_week
    weekstart = date.strftime('%d.%m')
    weekend = (date + 5).strftime('%d.%m')
    "#{weeknb} (#{weekstart}-#{weekend})"
  end
end
