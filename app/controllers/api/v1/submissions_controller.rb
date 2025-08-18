
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

    result = SubmissionManagement::AcceptSubmission.new(submission: submission)
    return { error: result[:error] } if result[:error]

    render json: Api::V1::SubmissionResource.new(result[:submission]).serialize, status: :ok
  end

  def reject
    submission = Submission.find_by(id: params[:id])

    render json: { error: "Submission not found" }, status: :not_found unless submission

    result = SubmissionManagement::RejectSubmission.new(submission: submission)
    return { error: result[:error] } if result[:error]

    render json: Api::V1::SubmissionResource.new(result[:submission]).serialize, status: :ok
  end

  def create
    source_type = submission_params[:source_type]
    source_types = Types::SubmissionSource.all

    return { error: "Invalid source type `#{source_type}` (#{source_types})" } unless source_types.include?(source_type.to_sym)

    ActiveRecord::Base.transaction do
      result_source = SubmissionManagement::CreateSource.new(source_type: source_type, **submission_params)
      return { error: result_source[:error] } if result_source[:error]

      result_submission = SubmissionManagement::CreateSubmission.new(source: result_source[:source])
      return { error: result_submission[:error] } if result_submission[:error]
    end

    render json: Api::V1::SubmissionResource.new(result_submission[:submission]).serialize, status: :ok
  end

  private

  def submission_params
    params.require(:submission).permit(:id, :source_type, :message, :email)
  end
end
