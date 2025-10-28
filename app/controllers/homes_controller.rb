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

    # Chart.jsに渡す情報
    today = Date.today
    start_of_week = today.beginning_of_week(:monday)

    diaries = Diary.where(posted_date: start_of_week..(start_of_week + 6))

    @happiness_data = (0..6).map do |i|
      date = start_of_week + i
      diary = diaries.find { |d| d.posted_date == date }
      {
        date: date,
        label: date.strftime("%-d"),         # X軸用（日のみ）
        full_label: date.strftime("%-m/%-d"), # ツールチップ用
        count: diary&.happiness_count || 0
      }
    end
  end
end
