class DiaryForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user_id, :integer
  attribute :status, :string
  attribute :posted_date, :date
  attribute :diary_id, :integer
  attribute :happiness_items
  attribute :happiness_count, :integer
  attribute :photos, default: []
  attribute :delete_photo_ids, default: []
  attribute :tag_names, :string, default: ""

  validates :user_id, presence: true
  validates :status, presence: true
  validates :posted_date, presence: true
  validates :happiness_items, blocked_words: true
  validates :tag_names, blocked_words: true


  attr_accessor :existing_photos
  attr_reader :diary
  attr_reader :diary_contents

  # 最低1つは入力必須
  validate :at_least_one_happiness_present
  # 各項目の文字数制限
  validate :happiness_items_length
  # 画像関連
  validate :validate_photos_count
  validate :validate_photos_format
  # タグ関連
  validate :tag_names_length
  validate :tag_names_count
  validate :parsed_tags

  def self.from_diary(diary)
    new(
      diary_id: diary.id,
      user_id: diary.user_id,
      status: diary.status,
      posted_date: diary.posted_date,
      happiness_items: diary.diary_contents.pluck(:body),
      tag_names: diary.tags.pluck(:name).join(", ")
    ).tap do |form|
      form.ensure_minimum_fields(5)
      form.existing_photos = diary.photos if diary.photos.attached?
    end
  end

  def self.for_new_diary(user)
    new(
      user_id: user.id,
      status: "is_public",
      posted_date: Date.current,
      photos: [],
      tag_names: ""
    )
  end

  def initialize(attributes = {})
    super
    ensure_minimum_fields(5) if happiness_items.all?(&:blank?)
  end

  def happiness_items
    @happiness_items ||= [ "" ]
  end

  def happiness_items=(values)
    @happiness_items = case values
    when Array
      values.map(&:to_s)
    when String
      [ values ]
    when nil
      [ "" ]
    else
      Array(values).map(&:to_s)
    end
  end

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      @diary = create_diary
      @diary_contents = create_diary_contents(@diary)
      create_tags(@diary)
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def update(diary)
    return false unless valid?

    ActiveRecord::Base.transaction do
      update_diary(diary)
      @diary_contents = update_diary_contents(diary)
      update_tags(diary)
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def added_ids
    @added_ids || []
  end


  def deleted_ids
    @deleted_ids || []
  end


  def persisted?
    diary_id.present?
  end

  def ensure_minimum_fields(min_count = 5)
    current_count = happiness_items.length
    if current_count < min_count
      additional_fields = Array.new(min_count - current_count, "")
      self.happiness_items = happiness_items + additional_fields
    end
  end

  def valid_happiness_items
    happiness_items.reject(&:blank?)
  end

  # 写真関連のメソッド
  def has_photos?
    (existing_photos&.attached?) || (photos.present? && photos.any?(&:present?))
  end

  def display_photos
    existing_photos&.attached? ? existing_photos : []
  end

  def total_photos_count
    existing_count = existing_photos&.attached? ? existing_photos.count : 0
    new_count = photos.present? ? photos.reject(&:blank?).count : 0
    removed_count = delete_photo_ids.present? ? delete_photo_ids.count : 0

    existing_count + new_count - removed_count
  end

  # 幸せ数のカウント
  def happiness_count
    valid_happiness_items.count
  end

  private

  # カスタムバリデーション
  def at_least_one_happiness_present
    if valid_happiness_items.empty?
      errors.add(:base, "少なくとも1つの幸せを入力してください")
    end
  end

  def happiness_items_length
    happiness_items.each_with_index do |item, index|
      next if item.blank?

      if item.length > 1000
        errors.add("happiness_items_#{index}", "は1000文字以内で入力してください")
      end
    end
  end

  def validate_photos_count
    if total_photos_count > 6
      errors.add(:photos, "は6枚以内でアップロードしてください")
    end
  end

  def validate_photos_format
    return unless photos.present?

    photos.each do |photo|
      next if photo.blank? || !photo.respond_to?(:content_type)

      unless photo.content_type.in?(%w[image/jpeg image/png image/gif])
        errors.add(:photos, "はJPEG、PNG、GIF形式でアップロードしてください")
        break
      end

      if photo.size > 5.megabytes
        errors.add(:photos, "は1枚あたり5MB以内でアップロードしてください")
        break
      end
    end
  end

  def tag_names_length
    return if tag_names.blank?

    parsed_tags.each do |tag|
      if tag.length > 20
        errors.add(:tag_names, "は20文字以内で入力してください")
        break
      end
    end
  end

  def tag_names_count
    return if tag_names.blank?

    if parsed_tags.length > 10
      errors.add(:tag_names, "は10個以内にしてください")
    end
  end

  def parsed_tags
    return [] if tag_names.blank?

    tag_names.split(/[[:blank:],]+/)
             .map(&:strip)
             .reject(&:blank?)
             .uniq
  end

  def create_diary
    diary = Diary.create!(
      user_id: user_id,
      status: status,
      posted_date: posted_date,
      happiness_count: valid_happiness_items.count
    )
    diary.photos.attach(photos) if photos.present?
    diary
  end

  def create_diary_contents(diary)
    contents = []

    valid_happiness_items.each do |item|
      content = diary.diary_contents.create!(body: item.strip)
      contents << content
    end

    @diary_contents = contents
    @added_ids = contents.map(&:id)
    @deleted_ids = []

    contents
  end


  def create_tags(diary)
    return if tag_names.blank?

    parsed_tags.each do |tag_name|
      tag = Tag.find_or_create_by(name: tag_name)
      diary.tags << tag unless diary.tags.include?(tag)
    end
  end

  def update_diary(diary)
    delete_selected_photos(diary) if delete_photo_ids.present?

    diary.update!(
      status: status,
      posted_date: posted_date,
      happiness_count: valid_happiness_items.count
    )
    attach_new_photos(diary) if photos.present?
  end

  def delete_selected_photos(diary)
    delete_photo_ids.each do |photo_id|
      next if photo_id.blank?

      photo_to_remove = diary.photos.find_by(id: photo_id)
      photo_to_remove&.purge
    end
  end

  def attach_new_photos(diary)
    valid_photos = photos.reject(&:blank?).select { |photo| photo.respond_to?(:tempfile) }
    diary.photos.attach(valid_photos) if valid_photos.any?
  end

  def update_diary_contents(diary)
    existing_contents = diary.diary_contents.order(:created_at).to_a
    updated_contents = []
    deleted_ids = []
    added_ids = []

    ActiveRecord::Base.transaction do
      valid_happiness_items.each_with_index do |item, index|
        content = existing_contents[index] || diary.diary_contents.build
        content.body = item.strip
        content.save!

        updated_contents << content
        added_ids << content.id if content.previous_changes.key?("id")
      end

      if existing_contents.size > valid_happiness_items.size
        extra = existing_contents[valid_happiness_items.size..]
        deleted_ids = extra.map(&:id)
        extra.each(&:destroy)
      end
    end

    @diary_contents = updated_contents
    @added_ids = added_ids
    @deleted_ids = deleted_ids

    updated_contents
  end

  def update_tags(diary)
    if tag_names.blank?
      diary.tags.clear
    else
      diary.tags.clear
      create_tags(diary)
    end
  end
end
