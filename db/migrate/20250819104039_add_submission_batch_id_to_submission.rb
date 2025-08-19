class AddSubmissionBatchIdToSubmission < ActiveRecord::Migration[8.0]
  def change
    add_column :submissions, :submission_batch_id, :bigint, null: true
    add_index :submissions, :submission_batch_id
  end
end
