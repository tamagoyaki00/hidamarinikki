class DiariesController < ApplicationController

  def new
    @diary = Diary.new
  end

  def create
    @diary = current_user.diaries.new(diary_params)

    items_json = { items: params[:diary][:items] }.to_json
    @diary.body = items_json

    if @diary.save
      redirect_to home_path, notice: '日記を投稿しました'
    else
      render :new
    end
  end

  private

  def diary_params
    params.require(:diary).permit(:status, :posted_date, items: [])
  end
end
