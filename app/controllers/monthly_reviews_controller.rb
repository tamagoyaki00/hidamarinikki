class MonthlyReviewsController < ApplicationController
  def index
    @months = (1..12).map { |i| Date.today.prev_month(i).beginning_of_month }.reverse
  end

  def show
    month = Date.strptime(params[:month], "%Y-%m").beginning_of_month
    @month = month

    diaries = current_user.diaries.where(posted_date: month..month.end_of_month)

    if diaries.empty?
      @monthly_review = nil
      return render :show
    end

    @monthly_review = current_user.monthly_reviews.find_or_create_by(month: month) do |review|
      total = diaries.sum(:happiness_count)
      average = diaries.any? ? (total.to_f / diaries.count).round(2) : 0
      max_diary = diaries.max_by(&:happiness_count)

      review.total_happiness_count = total
      review.average_happiness_count = average
      review.max_happiness_count = max_diary&.happiness_count
      review.max_happiness_diary = max_diary
      review.diary_snippets = diaries.flat_map do |d|
        d.diary_contents.map { |c| { date: d.posted_date, body: c.body } }
      end.sample(3)
    end

    render :show
  end
end
