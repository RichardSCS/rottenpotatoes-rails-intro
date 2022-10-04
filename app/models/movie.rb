class Movie < ActiveRecord::Base
  def self.all_ratings
    Movie.uniq.pluck(:rating)
  end

  def self.with_ratings(ratings_list)
    if ratings_list == []
      return Movie.all
    end

    Movie.where(rating: ratings_list)
  end
end
