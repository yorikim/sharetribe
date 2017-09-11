module AnalyticService
  class CommunityLookAndFeel < IncrementalProperties

    def process(_community, params)
      community = Community.find(_community.id)
      community.assign_attributes(params)
      properties[ADMIN_CHANGED_COVER_PHOTO] += 1 if community.cover_photo_file_name_changed?
      properties[ADMIN_CHANGED_COVER_PHOTO] += 1 if community.small_cover_photo_file_name_changed?
    end

    private

    def default_properties
      {
        ADMIN_CHANGED_COVER_PHOTO => 0
      }
    end
  end
end
