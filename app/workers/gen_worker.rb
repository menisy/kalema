class GenWorker
  include Sidekiq::Worker

  def perform(book_id)
    logger.error ">>>>>>>>>>>>>>>>>>>"
    logger.error book_id
    book = Book.find(book_id)
    book.generate_words
  end
end