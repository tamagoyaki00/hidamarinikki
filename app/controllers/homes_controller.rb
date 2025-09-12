class HomesController < ApplicationController
  before_action :authenticate_user!

  def index
    @new_happiness_count = session[:new_happiness_count] || 0
    @total_happiness_count = current_user.diaries.sum(:happiness_count)
    @existing_happiness_count = @total_happiness_count - @new_happiness_count
    session[:new_happiness_count] = 0

    @happiness_image_urls = [
      view_context.asset_path("green.png"), 
      view_context.asset_path("star.png"), 
      view_context.asset_path("heart.png")
    ]

    Rails.logger.info "🏠 Homeページ表示"
    Rails.logger.info "🏠 セッション値: #{session[:new_happiness_count]}"
    Rails.logger.info "🏠 @new_happiness_count: #{@new_happiness_count}"
    Rails.logger.info "🏠 @total_happiness_count: #{@total_happiness_count}"
    Rails.logger.info "🏠 @existing_happiness_count: #{@existing_happiness_count}"
  end
end
