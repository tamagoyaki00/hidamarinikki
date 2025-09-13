class HomesController < ApplicationController
  before_action :authenticate_user!

  def index
    @happiness_image_urls = [
      view_context.asset_path("green.png"), 
      view_context.asset_path("star.png"), 
      view_context.asset_path("heart.png")
    ]
    
        @existing_happiness_count = current_user.diary_contents.count
    Rails.logger.info "🏠 現在の幸せ数: #{@existing_happiness_count}"

    # 💡 flash からアニメーション情報を取得
    animation_data = flash[:happiness_animation] || {}
    Rails.logger.info "🎭 フラッシュデータ: #{animation_data}"
    if animation_data.present?
      @animation_type  = animation_data["type"] || animation_data[:type] || ""
      @animation_count = animation_data["count"] || animation_data[:count] || 0
      @previous_total  = animation_data["previous_total"] || animation_data[:previous_total] || @existing_happiness_count

      Rails.logger.info "🎬 アニメーション準備: #{@previous_total}個 → #{@existing_happiness_count}個"
      Rails.logger.info "🎬 アニメーション種類: #{@animation_type}, 変更数: #{@animation_count}"
    else
      @animation_type  = nil
      @animation_count = 0
      @previous_total  = @existing_happiness_count
    end
  end

  def reset_session
    session[:new_happiness_count] = 0
    render json: { success: true }
  end
end
