module AnalyticService
  class PersonAttributes
    attr_reader :person, :community

    def initialize(person:, community_id:)
      @person = person
      @community = Community.find_by(id: community_id)
    end

    def attributes
      result = {}
      if community
        result[INFO_MARKETPLACE_IDENT] = community.ident
        result[ADMIN_CREATED_FILTER] =  community.custom_fields.any?
        result[ADMIN_CREATED_LISTING] = person.listings.where(community_id: community.id).any?
        result[ADMIN_INVITED_USER] = person.invitations.where(community_id: community.id).any?
        result[ADMIN_CONFIGURED_FACEBOOK_CONNECT] = community.facebook_connect_id.present? &&
                                                    community.facebook_connect_secret.present?
        result[ADMIN_CONFIGURED_OUTGOING_EMAIL] = community.marketplace_sender_emails.verified.any?
      end
      result[ADMIN_CONFIRMED_EMAIL] = person.emails.confirmed.any?
      result[ADMIN_DELETED_MARKETPLACE] = Community.where(id: person.community_memberships.accepted.admin
                                                          .pluck(:community_id)).where(deleted: true).any?
      result.stringify_keys
    end
  end
end
