module AnalyticService
  class IncrementalProperties
    attr_accessor :properties, :user

    def initialize(user)
      @user = user
      @properties = default_properties
    end

    def send_properties
      if changes?
        AnalyticService::API::Api.send_incremental_properties(user, properties)
      end
    end

    private

    def default_properties
      raise NotImplementedError
    end

    def changes?
      properties.values.select{ |v| v > 0 }.any?
    end
  end
end
