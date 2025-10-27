class HomesController < ApplicationController
  before_action :authenticate_user!

  def index
    @happiness_image_urls = DiaryContent::HAPPINESS_IMAGES.map { |img| view_context.asset_path(img) }
    @diary_contents = DiaryContent
      .joins(:diary)
      .where(diaries: { user_id: current_user.id })
      .select(:id, :happiness_image)
      .order(created_at: :asc)


    animation_data = flash[:happiness_animation] || {}

    if animation_data.present?
      @added_ids   = animation_data["added_ids"] || animation_data[:added_ids] || []
      @deleted_ids = animation_data["deleted_ids"] || animation_data[:deleted_ids] || []
    else
      @added_ids = []
      @deleted_ids = []
    end
  end
end
