
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

    # submission = SubmissionManagement::AcceptSubmission.new(submission: submission)

    # return { error: submission[:error] } if submission[:error]

    # render json: Api::V1::SubmissionResource.new(submission).serialize, status: :ok
  end

  def reject
    submission = Submission.find_by(id: params[:id])

    render json: { error: "Submission not found" }, status: :not_found unless submission

    # submission = SubmissionManagement::RejectSubmission.new(submission: submission)

    # return { error: submission[:error] } if submission[:error]

    # render json: Api::V1::SubmissionResource.new(submission).serialize, status: :ok
  end

  def create
    source_type = submission_params[:source_type]

    { error: "Invalid source type" } unless Types::SubmissionSource.all.include?(source_type.to_sym)

    # source = SubmissionManagement::CreateSource.new(source_type: source_type, **submission_params)

    # return { error: source[:error] } if source[:error]

    # submission = SubmissionManagement::CreateSubmission.new(source: source)

    # return { error: submission[:error] } if submission[:error]

    # render json: Api::V1::SubmissionResource.new(submission).serialize, status: :ok
  end

  private

  def submission_params
    params.require(:submission).permit(:source_type, :message, :email)
  end
end
