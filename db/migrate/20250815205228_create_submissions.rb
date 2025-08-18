class CreateSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :submissions do |t|
      t.string :source_type, null: false
      t.bigint :source_id, null: false

      t.text :content
      t.text :generated_reply
      t.string :status, null: false
      t.text :review_comment
      t.datetime :submitted_at

      t.timestamps
    end
  end
end
