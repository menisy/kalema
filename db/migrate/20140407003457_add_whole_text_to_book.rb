class AddWholeTextToBook < ActiveRecord::Migration
  def change
    add_column :books, :whole_text, :text
  end
end
