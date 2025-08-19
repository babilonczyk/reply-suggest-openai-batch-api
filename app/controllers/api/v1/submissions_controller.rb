
class Api::V1::SubmissionsController < ApplicationController
  def index
    submissions = Submission.all

    render json: Api::V1::SubmissionResource.new(submissions).serialize, status: :ok
  end

  def show
    submission = Submission.find_by(id: params[:id])

    return render json: { error: "Submission not found" }, status: :not_found unless submission

    render json: Api::V1::SubmissionResource.new(submission).serialize, status: :ok
  end

  def accept
    submission = Submission.find_by(id: params[:id])

    render json: { error: "Submission not found" }, status: :not_found unless submission

    result = SubmissionManagement::AcceptSubmission.new.call(submission: submission)
    return { error: result[:error] } if result[:error]

    render json: Api::V1::SubmissionResource.new(result[:submission]).serialize, status: :ok
  end

  def reject
    submission = Submission.find_by(id: params[:id])

    render json: { error: "Submission not found" }, status: :not_found unless submission

    result = SubmissionManagement::RejectSubmission.new.call(submission: submission, review_comment: params[:review_comment])
    return { error: result[:error] } if result[:error]

    render json: Api::V1::SubmissionResource.new(result[:submission]).serialize, status: :ok
  end

  def create
    source_type_param = submission_params[:source_type]
    raw_params = submission_params.except(:source_type).to_h.symbolize_keys

    source_types = Types::SubmissionSource.all

    type_mapping = {
      "email" => "EmailSubmission"
    }

    source_type = type_mapping[source_type_param]

    unless source_types.map(&:to_s).include?(source_type)
      return render json: { error: "Invalid source type `#{source_type}` (#{source_types})" }, status: :unprocessable_entity
    end

    result_submission = nil
    ActiveRecord::Base.transaction do
      result_source = SubmissionManagement::CreateSource.new.call(source_type: source_type, **raw_params)

      return render json: { error: result_source[:error] }, status: :unprocessable_entity if result_source[:error]

      result_submission = SubmissionManagement::CreateSubmission.new.call(source: result_source[:source])

      return render json: { error: result_submission[:error] }, status: :unprocessable_entity if result_submission[:error]
    end

    render json: Api::V1::SubmissionResource.new(result_submission[:submission]).serialize, status: :ok
  end

  private

  def submission_params
    params.require(:submission).permit(:id, :source_type, :message, :email)
  end
end
