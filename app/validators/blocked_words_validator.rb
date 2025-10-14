class BlockedWordsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    values = value.is_a?(Array) ? value : [ value ]

    values.each do |v|
      blocked_words.each do |word|
        if v.match?(word)
          record.errors.add(attribute, "に不適切な表現（#{word.source}）が含まれています")
        end
      end
    end
  end

  private

  def blocked_words
    @blocked_words ||= begin
      path = Rails.root.join("config", "blocked_words.yml")
      if File.exist?(path)
        YAML.load_file(path)["blocked_words"].map do |w|
          Regexp.new(Regexp.escape(w), Regexp::IGNORECASE)
        end
      else
        []
      end
    end
  end
end
