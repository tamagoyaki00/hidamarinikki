class DiariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary, only: %i[ edit update destroy ai_comment]

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

      # 幸せ瓶に入れる幸せの数をカウント
      if new_happiness_count > 0
        current_total = current_user.total_happiness_count
        previous_total = current_total - new_happiness_count

       flash[:happiness_animation] = {
        type: "increase",
        count: new_happiness_count,
        previous_total: previous_total
      }
      end

            flash[:ai_comment] = "日記投稿ありがとう！<br>" \
                     "<span class='loading loading-spinner'></span> コメント生成中..."
      @diary = @diary_form.diary

      redirect_to home_path(from: "create", diary_id: @diary_form.diary.id)
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

      flash[:ai_comment] = "日記更新ありがとう！<br>" \
                     "<span class='loading loading-spinner'></span> コメント生成中..."

      redirect_to home_path(from: "update", diary_id: @diary.id)
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

  def ai_comment
    contents_text = @diary.diary_contents.map(&:body).join("\n")

    # 投稿か更新かを判定（例: params[:from] に "create" or "update" を渡す）
    if params[:from] == "create"
      diary_streak = @diary.user.diary_streak

      cheering_instruction = case diary_streak
      when 1
                              "継続日数1日目です。「今日から素敵な習慣の始まりですね！」のように、新しいスタートを祝福する言葉を必ず添えてください。"
      when 2..10
                              "ユーザーは現在#{diary_streak}日連続で日記を続けています。「この調子で、ポジティブ習慣を身につけましょう！」のように、今後も続けやすいように温かい言葉で褒めてください。"
      else
                              "ユーザーは現在#{diary_streak}日連続で日記を続けています。「#{diary_streak}日も続いていて素晴らしい習慣ですね！」のように、習慣化してきた努力を称賛してください。"
      end

      system_prompt = <<~PROMPT
        あなたはユーザーの毎日の日記を応援するAIパートナーです。あなたの役割は寄り添いとモチベーションアップです。
        日記に書かれている出来事を一つ一つ取り上げるのではなく、日記全体から感じられるポジティブな雰囲気に対して、温かい感想を一言で返してください。
        ユーザーが感じた幸せな気持ちや、自分を褒めている素敵な行動に共感を示しましょう。
        否定的な言葉は使わないでください。
        #{cheering_instruction}
        出力は日本語で、必ず100文字以内に収めてください。
        漢字を使う場合は旧字体や異体字は使わず、常用漢字で自然な表記にしてください。
      PROMPT

      client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
      response = client.chat(
        parameters: {
          model: "gpt-5-mini",
          messages: [
            { role: "system", content: system_prompt },
            { role: "user", content: contents_text }
          ],
          temperature: 1
        }
      )

      ai_comment = response.dig("choices", 0, "message", "content")
      flash.now[:ai_comment] = "日記投稿ありがとう！\n#{ai_comment}"

    else # 更新後
      client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
      response = client.chat(
        parameters: {
          model: "gpt-5-mini",
          messages: [
            { role: "system", content: "あなたはユーザーの毎日の日記を応援するAIパートナーです。
              あなたの役割は寄り添いと、モチベーションアップです。
              日記に書かれている出来事を一つ一つ取り上げるのではなく、日記全体から感じられるポジティブな雰囲気に対して、温かい感想を一言で返してください。
              ユーザーが感じた幸せな気持ちや、自分を褒めている素敵な行動に共感を示しましょう。
              否定的な言葉は使わないでください。
              出力は日本語で、必ず100文字以内に収めてください。
              漢字を使う場合は旧字体や異体字は使わず、常用漢字で自然な表記にしてください。" },
            { role: "user", content: contents_text }
          ],
          temperature: 1
        }
      )

      ai_comment = response.dig("choices", 0, "message", "content")
      flash.now[:ai_comment] = "日記更新ありがとう！\n#{ai_comment}"
    end

    respond_to do |format|
      format.turbo_stream
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
