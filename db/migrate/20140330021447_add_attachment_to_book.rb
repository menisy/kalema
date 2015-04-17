class AddAttachmentToBook < ActiveRecord::Migration
  def change
    add_attachment :books, :attachment
  end
end
