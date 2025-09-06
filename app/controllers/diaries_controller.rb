class DiariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary, only: %i[ edit update destroy ]

  def my_diaries
    @diaries = current_user.diaries.order(created_at: :desc)
  end

  def public_diaries
    @diaries = Diary.is_public.includes(:user).order(created_at: :desc)
  end

  # 日記の新規作成時、同日の日記がすでに作成されていたら編集フォームに遷移
  def new
    posted_date = params[:posted_date].present? ? Date.parse(params[:posted_date]) : Date.current
    @diary = current_user.diaries.find_by(posted_date: posted_date)

    if @diary.present?
      @diary_form = DiaryForm.from_diary(@diary)
    else
      @diary_form = DiaryForm.for_new_diary(current_user)
      @diary_form.posted_date = posted_date
    end

  rescue ArgumentError
    redirect_to new_diary_path, alert: "日付の形式が正しくありません。"
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

    if params[:diary_form][:remove_photos].present?
      params[:diary_form][:remove_photos].each do |photo_id|
        photo_to_remove = @diary.photos.find(photo_id)
        photo_to_remove.purge
      end
    end
    
    @diary_form.assign_attributes(diary_form_params)
    if @diary_form.update(@diary)
      redirect_to home_path, notice: "日記を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @diary.destroy
    redirect_to my_diaries_path, notice: "日記を削除しました", status: :see_other
  end


  private

  def set_diary
    @diary = current_user.diaries.find(params[:id])
  end

  def diary_form_params
    params.require(:diary_form).permit(:status, :posted_date, happiness_items: [], photos: []).merge(user_id: current_user.id)
  end
end
