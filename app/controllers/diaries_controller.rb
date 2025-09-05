class DiariesController < ApplicationController
  before_action :authenticate_user!

  def my_diaries
    @diaries = current_user.diaries.order(created_at: :desc)
  end

  def public_diaries
    @diaries = Diary.is_public.includes(:user).order(created_at: :desc)
  end


  def new
    @diary_form = DiaryForm.new(user_id: current_user.id, posted_date: Date.current)
  end

  def create
    @diary_form = DiaryForm.new(diary_form_params)
    @diary_form.user_id = current_user.id

    if @diary_form.save
      redirect_to home_path, notice: "日記を投稿しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def diary_form_params
    params.require(:diary_form).permit(:status, :posted_date, happiness_items: []).merge(user_id: current_user.id)
  end
end
