class DiariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary, only: %i[ edit update destroy ]

  def my_diaries
    @q = current_user.diaries.ransack(params[:q])
    @diaries = @q.result(distinct: true).order(created_at: :desc)
  end

  def public_diaries
    @q = Diary.is_public.ransack(params[:q])
    @diaries = @q.result(distinct: true).includes(:user).order(created_at: :desc)
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

      Rails.logger.info "🐛 diary_form_params: #{diary_form_params.inspect}"
  Rails.logger.info "🐛 valid_happiness_items: #{@diary_form.valid_happiness_items.inspect}"
  Rails.logger.info "🐛 valid_happiness_items.class: #{@diary_form.valid_happiness_items.class}"

    if @diary_form.save
      session[:new_happiness_count] = (session[:new_happiness_count] || 0) + @diary_form.happiness_count
      Rails.logger.info "🎯 セッションに保存: #{session[:new_happiness_count]}個の幸せ"
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
      session[:new_happiness_count] = @diary_form.diary.happiness_count
      Rails.logger.info "🎯 セッションに保存: #{session[:new_happiness_count]}個の幸せ"
      redirect_to home_path, notice: "日記を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @diary.destroy
    redirect_to my_diaries_path, notice: "日記を削除しました", status: :see_other
  end

  def autocomplete
    @tags = Tag.where("name like ?", "%#{params[:q]}%").limit(10)
    respond_to do |format|
      format.js
    end
  end

  private

  def set_diary
    @diary = current_user.diaries.find(params[:id])
  end

  def diary_form_params
    params.require(:diary_form).permit(:status, :posted_date, :tag_names, happiness_items: [], photos: [], delete_photo_ids: []).merge(user_id: current_user.id)
  end
end
