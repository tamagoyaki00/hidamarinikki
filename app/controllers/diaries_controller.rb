class DiariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary, only: %i[ edit update]

  def my_diaries
    @diaries = current_user.diaries.order(created_at: :desc)
  end

  def public_diaries
    @diaries = Diary.is_public.includes(:user).order(created_at: :desc)
  end


  def new
    @diary_form = DiaryForm.for_new_diary(current_user)
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

  def edit
    @diary_form = DiaryForm.from_diary(@diary)
  end

  def update
    @diary_form = DiaryForm.from_diary(@diary)
    @diary_form.assign_attributes(diary_form_params)
    if @diary_form.update(@diary)
      redirect_to home_path, notice: "日記を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_diary
    @diary = current_user.diaries.find(params[:id])
  end

  def diary_form_params
    params.require(:diary_form).permit(:status, :posted_date, happiness_items: []).merge(user_id: current_user.id)
  end
end
