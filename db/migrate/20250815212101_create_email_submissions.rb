class CreateEmailSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :email_submissions do |t|
      t.string :email
      t.text :message

      t.timestamps
    end
  end
end
