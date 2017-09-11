module AnalyticService
  module API
    class Intercom
      TRACK_EVENTS = [
        EVENT_LOGOUT
      ].freeze

      def event(person_id:, event_data:)
        person = Person.find_by(id: person_id)
        if person
          client.events.create(
            event_name: event_data.try(:[], :event_name),
            created_at: Time.current.to_i,
            email: person_email(person),
            metadata: event_data
          )
        end
      end
      handle_asynchronously :event

      def create_or_update_user(person_id:, community_id:)
        person = Person.find_by(id: person_id)
        if person
          intercom_user = client.users.create(
            user_id: person.uuid_object.to_s,
            email: person_email(person),
            signed_up_at: person.created_at.to_i,
            name: PersonViewUtils.person_display_name_for_type(person, nil),
            last_seen_ip: person.current_sign_in_ip.to_s
          )
          intercom_user.custom_attributes.merge!(
            AnalyticService::PersonAttributes.new(
              person: person, community_id: community_id).attributes
          )
          client.users.save(intercom_user)
        end
      end
      handle_asynchronously :create_or_update_user

      def update_user_incremental_properties(person_id:, properties:)
        person = Person.find_by(id: person_id)
        if person
          intercom_user = client.users.create(
            user_id: person.uuid_object.to_s,
            email: person_email(person)
          )
          properties.each do |property, value|
            intercom_user.increment(property, value) if value > 0
          end
          client.users.save(intercom_user)
        end
      end
      handle_asynchronously :update_user_incremental_properties

      private

      def client
        @client ||= ::Intercom::Client.new(token: APP_CONFIG.admin_intercom_access_token)
      end

      def person_email(person)
        person && (person.primary_email || person.emails.first).address
      end

      class << self
        def enabled?
          APP_CONFIG.admin_intercom_app_id.present? &&
            APP_CONFIG.admin_intercom_access_token.present?
        end

        def send_event(person, event_data)
          event_name = event_data.try(:[], :event_name)
          if enabled? && track_event?(event_name)
            new.event(
              person_id: person.id,
              event_data: event_data
            )
          end
        end

        def track_event?(event_name)
          TRACK_EVENTS.include?(event_name)
        end

        def setup_person(person:, community:)
          if person && enabled?
            new.create_or_update_user(person_id: person.id, community_id: community.try(:id))
          end
        end

        def send_incremental_properties(person, properties)
          if enabled?
            new.update_user_incremental_properties(
              person_id: person.id,
              properties: properties.stringify_keys
            )
          end
        end
      end
    end
  end
end
