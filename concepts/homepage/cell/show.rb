require 'core_ext/time'
require 'formular'

module Homepage
  module Cell
    class Show < Trailblazer::Cell
      include Formular::Helper
      Formular::Helper.builder= :bootstrap4

      def signators
        [['Mickael', 'Mickael Kurmann'], ['André', 'Andre Kurmann']]
      end

      def dates(nb_of_weeks: 15)
        week_list = {}
        ( Date.today..nb_of_weeks.weeks.from_now.to_date ).select { |d| d.cwday == 1 }.each do |w|
          week_list[return_display_name_from_date(w)] = w.to_s
        end
        week_list
      end

      def return_display_name_from_date(date)
        "#{self.weeknb(date)} (#{short_day(date.beginning_of_week)} - #{short_day(date.beginning_of_week+4)})"
      end

      def short_day(date)
        date.strftime('%d.%m')
      end

      def weeknb(date)
        "#{date.year.to_s.last(2)}.#{'%02d' % date.cweek}"
      end
    end
  end
end
