class AddOcrTextToWord < ActiveRecord::Migration
  def change
    add_column :words, :ocr_text, :string
  end
end
