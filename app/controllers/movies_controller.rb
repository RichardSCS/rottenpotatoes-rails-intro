class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    session[:sort] = if params[:sort].present?
                        params[:sort]
                      else
                        session[:sort] || 'id'
                      end
    session[:ratings] = if params[:ratings].present?
                          params[:ratings]
#			elsif session[:ratings] == nil
#			  nil
                        else
                          session[:ratings] || { 'G' => '1', 'PG' => '1', 'PG-13' => '1', 'R' => '1' } 
                        end

    if !(params[:sort].present? && params[:ratings].present?)
      redirect_to movies_path(sort: session[:sort], ratings: session[:ratings])
      return
    end
=begin	  
    if params[:home] == '1' || params[:commit] == 'Refresh'
#      flash[:notice] = "Made the redirect"
      redirect_to movies_path(sort: params[:sort], ratings: session[:ratings])
      return
    end
=end
    @all_ratings = Movie.all_ratings.sort
    if params[:ratings] == nil
      @building_hash = Hash.new
      @all_ratings.each { |r| @building_hash["#{r}"] = "1"}
      params[:ratings] = @building_hash
    end

    if session[:ratings] == nil
      @ratings_to_show = @all_ratings
    elsif session[:ratings] == []
      @ratings_to_show = []
    else
      @ratings_to_show = session[:ratings].keys
    end

    @movies = Movie.with_ratings(@ratings_to_show)

    @ratings_hash = Hash.new
    @ratings_to_show.each { |r| @ratings_hash["#{r}"] = "1"}

=begin    if !(params[:sort] == nil)
      @current = params
    elsif !(session[:sort] == nil)
      @current = session
    end
=end
    case params[:sort]
    when 'title'
      @hightlight_title_header = true
    when 'release_date'
      @hightlight_release_date_header = true
    end
    @movies = @movies.order(params[:sort])
   # end

    session[:ratings] = params[:ratings]
    session[:sort] = params[:sort]
#    flash[:notice] = "#{params}"
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
