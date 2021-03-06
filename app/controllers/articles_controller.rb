class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy, :create_comment, :create_tag]
  before_action :initialize_markdown, only: [:show, :index]

  # GET /articles
  # GET /articles.json
  def index
    if params[:titleKeyword].blank? and params[:tagKeyword].blank?
      @articles = Article.all
    elsif params[:tagKeyword].blank?
      @articles = Article.where('title LIKE ?', "%#{params[:titleKeyword]}%")
    elsif params[:titleKeyword].blank?
      @articles = Article.joins(:tags).where('value = ?', params[:tagKeyword])
    else
      @articles = Article.joins(:tags).where('value = ? AND title LIKE ?', params[:tagKeyword], "%#{params[:titleKeyword]}%")
    end
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    @article.views = @article.views + 1
    @article.save
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  # POST /articles.json
  def create
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_comment
    Comment.create(body: params[:comment_content], article_id: params[:id])
    redirect_to articles_path
  end

  def create_tag
    tag = Tag.where('value = ?', params[:tag_value])
    if tag.exists?
      @article.tags << tag
    else
      @article.tags.create(value: params[:tag_value])
    end
    redirect_to articles_path
  end

  # PATCH/PUT /articles/1
  # PATCH/PUT /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: 'Article was successfully updated.' }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article.comments.delete_all
    @article.destroy
    respond_to do |format|
      format.html { redirect_to articles_url, notice: 'Article was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_article
    @article = Article.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def article_params
    params.require(:article).permit(:title, :body)
  end

  def initialize_markdown
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  end
end
