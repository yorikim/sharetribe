module AnalyticService
  module API
    class Api
      class << self
        def send_event(current_user, event_data)
          AnalyticService::API::Intercom.send_event(current_user, event_data)
        end

        def send_incremental_properties(current_user, properties)
          AnalyticService::API::Intercom.send_incremental_properties(current_user, properties)
        end
      end
    end
  end
end
