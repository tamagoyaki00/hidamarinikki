class HomesController < ApplicationController
  before_action :authenticate_user!

  def index
    @happiness_image_urls = [
      view_context.asset_path("green.png"),
      view_context.asset_path("star.png"),
      view_context.asset_path("heart.png"),
      view_context.asset_path("clover.png"),
      view_context.asset_path("orange.png")

    ]

    @existing_happiness_count = current_user.total_happiness_count

    animation_data = flash[:happiness_animation] || {}
    if animation_data.present?
      @animation_type  = animation_data["type"] || animation_data[:type] || ""
      @animation_count = animation_data["count"] || animation_data[:count] || 0
      @previous_total  = animation_data["previous_total"] || animation_data[:previous_total] || @existing_happiness_count
    else
      @animation_type  = nil
      @animation_count = 0
      @previous_total  = @existing_happiness_count
    end
  end
end
