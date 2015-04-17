class BooksController < ApplicationController
  before_action :set_book, only: [:remove_page, :rotate_page, :show, :edit, :update, :destroy, :play, :generate_words, :new_page]

  before_action :authenticate_admin!

  # GET /books
  # GET /books.json
  def index
    @books = Book.all
  end

  # GET /books/1
  # GET /books/1.json
  def show
    if params[:reload]
      @reload = true
    end
    @pages = @book.pages
  end

  def verify_word
    @word = Word.find(params[:word_id])
    valid = params[:valid]
    @word.verified = !valid.blank?
    @word.save
  end

  def generate_words
    @book.generating = true
    @book.save
    logger.error 'in generation *********************'
    #Thread.new do
      logger.error 'in thread %%%%%%%%%%%%%%%%%%%%'
      @book.generate_words
    #  Mongoid::Sessions.default.disconnect
    #end
    #GenWorker.perform_async(@book.id.to_s)
    redirect_to book_path(@book, reload: true), notice: "Words will be generated shortly\nPlease wait till the page reloads!"
  end

  def play
    @game = Game.new
    @game.user = current_user if user_signed_in?
    @lang = @book.lang
    @words = @book.words.asc(:played).take(20)
    @game.words = @words.map(&:id)
    @game.save
    @words.map(&:inc_played)
  end

  def rotate_page
    page = @book.pages.find(params[:page_id])
    image = Magick::Image.read(page.attachment.path).first
    b = nil
    if params[:or] == 'anti'
      b = image.rotate!(-90)
    else
      b = image.rotate!(90)
    end
    f = b.write("#{Rails.root}/tmp/temp#{page.id}.jpg")
    page.attachment = open f.filename
    page.save
    FileUtils.rm(f.filename)
    redirect_to :back, notice: 'Rotated successfully'
  end

  def remove_page
    page = @book.pages.find(params[:page_id])
    page.destroy!
    redirect_to :back, notice: 'Page deleted'
  end

  def new_page
    filename = page_params[:attachment].original_filename
    unless @book.can_add? filename
      render json: {message: 'Already loaded a page with the same name!'}, status: :unprocessable_entity
      return
    end
    @page = @book.pages.build page_params
    @page.filename = filename
    respond_to do |format| 
      if @page.save
        format.html { redirect_to @page, notice: 'Photo was successfully created.' }
        format.json { 
          data = {id: @page.id, filename: @page.filename, thumb: view_context.image_tag(@page.attachment.url(:thumb))} 
          render json: data, status: :created, location: @book
      }
      else 
        format.html { render action: "new" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books
  # POST /books.json
  def create
    @book = Book.new(book_params)

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: 'Book was successfully created.' }
        format.json { render action: 'show', status: :created, location: @book }
      else
        format.html { render action: 'new' }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: 'Book was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_params
      params.require(:book).permit(:two_pages, :name, :reference, :attachment, :lang)
    end

    def page_params
      params.require(:page).permit(:attachment)
    end
end
