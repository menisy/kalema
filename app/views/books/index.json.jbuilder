json.array!(@books) do |book|
  json.extract! book, :id, :name, :reference
  json.url book_url(book, format: :json)
end
