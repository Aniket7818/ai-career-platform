module Api
  module V1
    class InterviewPrepController < ApplicationController
      before_action :authenticate_api_user!
      before_action -> { authorize_feature!(:interview_prep) }, only: %i[show question]

      def index
        subjects = InterviewQuestionLoader.available_subjects
        render json: { subjects: subjects }
      end

      def show
        questions = InterviewQuestionLoader.load_subject(params[:subject])
        if questions.any?
          render json: { 
            subject: params[:subject].capitalize,
            questions: questions.map { |q| q.slice("id", "title", "difficulty", "topic") }
          }
        else
          render json: { error: "Subject not found" }, status: :not_found
        end
      end

      def question
        questions = InterviewQuestionLoader.load_subject(params[:subject])
        question = questions.find { |q| q["id"].to_s == params[:question_id].to_s }
        if question
          render json: { question: question }
        else
          render json: { error: "Question not found" }, status: :not_found
        end
      end
    end
  end
end
