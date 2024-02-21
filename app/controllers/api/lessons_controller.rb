# frozen_string_literal: true

module Api
  class LessonsController < ApiController
    before_action :authorize_user, except: %i[index show]
    before_action :verify_school_class_belongs_to_school, only: :create
    load_and_authorize_resource :lesson

    def index
      scope = params[:include_archived] == 'true' ? Lesson : Lesson.unarchived
      @lessons_with_users = scope.accessible_by(current_ability).with_users
      render :index, formats: [:json], status: :ok
    end

    def show
      @lesson_with_user = @lesson.with_user
      render :show, formats: [:json], status: :ok
    end

    def create
      result = Lesson::Create.call(lesson_params:)

      if result.success?
        @lesson_with_user = result[:lesson].with_user
        render :show, formats: [:json], status: :created
      else
        render json: { error: result[:error] }, status: :unprocessable_entity
      end
    end

    def update
      result = Lesson::Update.call(lesson: @lesson, lesson_params:)

      if result.success?
        @lesson_with_user = result[:lesson].with_user
        render :show, formats: [:json], status: :ok
      else
        render json: { error: result[:error] }, status: :unprocessable_entity
      end
    end

    def destroy
      operation = params[:undo] == 'true' ? Lesson::Unarchive : Lesson::Archive
      result = operation.call(lesson: @lesson)

      if result.success?
        head :no_content
      else
        render json: { error: result[:error] }, status: :unprocessable_entity
      end
    end

    private

    def verify_school_class_belongs_to_school
      return if base_params[:school_class_id].blank?
      return if school&.classes&.pluck(:id)&.include?(base_params[:school_class_id])

      raise ParameterError, 'school_class_id does not correspond to school_id'
    end

    def lesson_params
      if school_owner?
        # A school owner must specify who the lesson user is.
        base_params
      else
        # A school teacher may only create classes they own.
        base_params.merge(user_id: current_user.id)
      end
    end

    def base_params
      params.require(:lesson).permit(:school_id, :school_class_id, :user_id, :name)
    end

    def school_owner?
      school && current_user.school_owner?(organisation_id: school.id)
    end

    def school
      @school ||= @lesson&.school || School.find_by(id: base_params[:school_id])
    end
  end
end
