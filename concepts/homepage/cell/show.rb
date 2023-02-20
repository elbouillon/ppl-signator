# frozen_string_literal: true

require 'core_ext/time'
require 'formular'

module Homepage
  module Cell
    class Show < Trailblazer::Cell
      include Formular::Helper
      Formular::Helper.builder = :bootstrap4

      def signators
        [['Mickael', 'Mickael Kurmann'], ['André', 'Andre Kurmann'], ['Vitor', 'Vitor Da Rocha'],
         ['JX', 'Jean-Xavier Porikian']]
      end

      def dates(nb_of_weeks: 15)
        week_list = {}
        (Date.today..nb_of_weeks.weeks.from_now.to_date).select { |d| d.cwday == 1 }.each do |w|
          week_list[return_display_name_from_date(w)] = w.to_s
        end
        week_list
      end

      def return_display_name_from_date(date)
        date = date.to_date
        weeknb = date.strftime('%g.%V')
        # weekstart_date = date.beginning_of_week
        weekstart = date.strftime('%d.%m')
        weekend = (date + 5).strftime('%d.%m')
        "#{weeknb} (#{weekstart}-#{weekend})"
      end
    end
  end
end
