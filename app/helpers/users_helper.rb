module UsersHelper
  # ユーザー名の先頭2文字を文字アバターとして表示
  def avatar_placeholder(user, size: "w-24 h-24", **options)
    initials = if user.name.present?
                user.name[0..1].upcase
    else
                "?"
    end

    # optionsからclass属性を取得し、既存のクラスと結合
    merged_classes = ["avatar-placeholder", size, options[:class]].compact.join(" ")
    
    # 文字サイズを動的に設定するためのクラスを抽出
    text_size_class = options[:class].to_s.split.find { |c| c.start_with?("text-") } || "text-3xl"

    content_tag :div, class: merged_classes do
      content_tag :div, class: "bg-neutral text-neutral-content #{size} rounded-full flex items-center justify-center" do
        content_tag :span, initials, class: text_size_class
      end
    end
  end
end