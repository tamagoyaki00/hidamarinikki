module UsersHelper
  # ユーザー名の先頭2文字を文字アバターとして表示
  def avatar_placeholder(user, size: "w-24 h-24")
    initials = if user.name.present?
                 user.name[0..1].upcase
               else
                 "?"
               end

    content_tag :div, class: "avatar avatar-placeholder #{size}" do
      content_tag :div, class: "bg-neutral text-neutral-content #{size} rounded-full flex items-center justify-center" do
        content_tag :span, initials, class: "text-3xl"
      end
    end
  end
end