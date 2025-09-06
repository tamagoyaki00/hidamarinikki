class DiaryForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user_id, :integer
  attribute :status, :string
  attribute :posted_date, :date
  attribute :diary_id, :integer
  attribute :happiness_items

  validates :user_id, presence: true
  validates :status, presence: true
  validates :posted_date, presence: true

  # 最低1つは入力必須
  validate :at_least_one_happiness_present
  # 各項目の文字数制限
  validate :happiness_items_length

  def self.from_diary(diary)
    new(
      diary_id: diary.id,
      user_id: diary.user_id,
      status: diary.status,
      posted_date: diary.posted_date,
      happiness_items: diary.diary_contents.pluck(:body)
    ).tap do |form|
      form.ensure_minimum_fields(5)
    end
  end

  def self.for_new_diary(user)
    new(
      user_id: user.id,
      status: 'is_public',
      posted_date: Date.current
    )
  end

  def initialize(attributes = {})
    super
    ensure_minimum_fields(5) if happiness_items.all?(&:blank?)
  end

  def happiness_items
    @happiness_items ||= [""]
  end

  def happiness_items=(values)
    @happiness_items = case values
    when Array
      values.map(&:to_s)
    when String
      [values]
    when nil
      [""]
    else
      Array(values).map(&:to_s)
    end
  end

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      diary = create_diary
      create_diary_contents(diary)
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def update(diary)
    return false unless valid?

    ActiveRecord::Base.transaction do
      update_diary(diary)
      update_diary_contents(diary)
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def persisted?
    diary_id.present?
  end

  # 空のフィールドを最低指定数まで確保
  def ensure_minimum_fields(min_count = 5)
    current_count = happiness_items.length
    if current_count < min_count
      additional_fields = Array.new(min_count - current_count, "")
      self.happiness_items = happiness_items + additional_fields
    end
  end

  # ✅ 修正: 空でない項目のみを取得
  def valid_happiness_items
    happiness_items.reject(&:blank?)
  end

  private

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

  def create_diary
    Diary.create!(
      user_id: user_id,
      status: status,
      posted_date: posted_date,
      happiness_count: valid_happiness_items.count
    )
  end

  # ✅ 修正: valid_happiness_itemsを使用
  def create_diary_contents(diary)
    valid_happiness_items.each do |item|
      DiaryContent.create!(
        diary: diary,
        body: item.strip
      )
    end
  end

  def update_diary(diary)
    diary.update!(
      status: status,
      posted_date: posted_date,
      happiness_count: valid_happiness_items.count
    )
  end

  # ✅ 修正: valid_happiness_itemsを使用
  def update_diary_contents(diary)
    diary.diary_contents.destroy_all
    
    valid_happiness_items.each do |item|
      DiaryContent.create!(
        diary: diary,
        body: item.strip
      )
    end
  end
end
