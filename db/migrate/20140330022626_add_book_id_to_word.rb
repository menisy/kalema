class AddBookIdToWord < ActiveRecord::Migration
  def change
    add_column :words, :book_id, :integer
  end
end
