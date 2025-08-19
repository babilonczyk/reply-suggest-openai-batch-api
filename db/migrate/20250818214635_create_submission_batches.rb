class CreateSubmissionBatches < ActiveRecord::Migration[8.0]
  def change
    create_table :submission_batches do |t|
      t.string :batch_id, null: false
      t.string :status, null: false
      t.timestamps
    end
  end
end
