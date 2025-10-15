class DiariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary, only: %i[ edit update destroy generate_ai_comment]

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
        current_total = current_user.total_happiness_count
        previous_total = current_total - new_happiness_count

       flash[:happiness_animation] = {
        type: "increase",
        count: new_happiness_count,
        previous_total: previous_total
      }
      end

      #AIコメントを生成
      contents_text = @diary_form.valid_happiness_items.join("\n")

      client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
      response = client.chat(
        parameters: {
          model: "gpt-5-nano",
          messages: [
            { role: "system", content: "あなたはユーザーの毎日の日記を応援するAIパートナーです。
            あなたの役割は寄り添いと、モチベーションアップです。
            ユーザーの日記の内容に共感したり、励ましたりする短いコメントを1〜2文で書いてください。
            やさしく温かいトーンで、否定的な言葉は使わないでください。
            出力は日本語で、必ず1〜2文に収めてください。" },
            { role: "user", content: contents_text }
          ],
          temperature: 1
        }
      )

      ai_comment = response.dig("choices", 0, "message", "content")
      flash[:ai_comment] = "日記投稿ありがとう！\n#{ai_comment}"

      redirect_to home_path
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
    previous_happiness_count = @diary.diary_contents.count
    previous_total_happiness = current_user.total_happiness_count

    if @diary_form.update(@diary)
      new_happiness_count = @diary_form.happiness_count
      happiness_diff = new_happiness_count - previous_happiness_count

      if happiness_diff != 0
        flash[:happiness_animation] = {
          type: happiness_diff > 0 ? "increase" : "decrease",
          count: happiness_diff.abs,
          previous_total: previous_total_happiness
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
