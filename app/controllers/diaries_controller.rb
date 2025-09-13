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

    if @diary_form.save
    new_happiness_count = @diary_form.happiness_count
    
      if new_happiness_count > 0
        # 現在の総数から新規追加分を引いて、以前の数を計算
        current_total = current_user.diary_contents.count
        previous_total = current_total - new_happiness_count
        
       flash[:happiness_animation] = {
        type: 'increase',
        count: new_happiness_count,
        previous_total: previous_total
      }
        
        Rails.logger.info "📝 新規作成: #{previous_total}個 → #{current_total}個 (#{new_happiness_count}個追加)"
      end
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
    previous_happiness_count = @diary.diary_contents.count
    @diary_form.assign_attributes(diary_form_params)

    if @diary_form.update(@diary)
      new_happiness_count = @diary_form.happiness_count
      happiness_diff = new_happiness_count - previous_happiness_count
      
      if happiness_diff != 0
        flash[:happiness_animation] = {
          type: happiness_diff > 0 ? "increase" : "decrease",
          count: happiness_diff.abs,
          previous_total: previous_happiness_count
        }
      end

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
