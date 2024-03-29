class SurveysController < ApplicationController
  
  
  layout 'survey', :except => :intro
  before_filter :require_user
  has_mobile_fu
  
  
  def index
    @surveys = Survey.where(archived: false)

    respond_to do |format|
      format.mobile {render :layout => '/layouts/blank.html.erb'}
      format.tablet {render :layout => '/layouts/blank.html.erb'}
      format.html
      format.js
    end
  end

  def show
    @survey = Survey.find(params[:id])
    @response = Response.new
    @section_id = params[:section_id] if params[:section_id]
    @sections = @survey.questions.select {|q| q.title == true }
    @gtg = true
    @agreed = Membership.where(person_id: current_user.id, fuction: "survey agreement", resource: "survey", resource_id: params[:id]).first.present?

    if @survey.company_survey == true
      @gtg = false

      m = Membership.where(person_id: current_user.id, fuction: "survey access", resource: "survey", resource_id: params[:id]).first
      if m.nil?
        if current_user.company.primary_person_id.present? && current_user.id == current_user.company.primary_person_id
          @reason = "primary"
          @gtg = true
        else
          @section_id = '0'
          @reason = "no membership"
        end
      else
        @gtg = true
      end

      if current_user.company.present? && current_user.company.name != ""
        if current_user.company.primary_person_id.nil?
          @section_id = '0'
          @reason = "no primary person"
          @gtg = false
        end
      else
        @section_id = '0'
        @reason = "no company"
        @gtg = false
      end
    end
      
    if @survey.company_survey == false || @survey.company_survey.blank?
      @agreed = true
      @gtg = true
    end


    if @survey.force_sections == true && @section_id.nil?
      @section_id = '0'
    end

    
    if @section_id.to_i > @sections.length
      if @sections.length > 0
        @section_id = "0"
      else
        @section_id = nil
      end
    end

    if @agreed == false
      @section_id = "0"
    end
    
    authorize! :read, @survey
    


    if is_mobile_device?
      redirect_to intro_survey_path(@survey)
    elsif is_tablet_device?
      @tablet = true
      render :layout => '/layouts/survey.html.erb'
    else

      respond_to do |format|
        
        format.html
        format.js
        format.csv do
          send_data @survey.to_csv
        end
      end
    end
  end

  def sign_agreement
    @survey = Survey.find(params[:id])
    @person = Person.find(params[:person_id])
    Membership.create(person_id: params[:person_id], fuction: "survey agreement", resource: "survey", resource_id: params[:id])

    # @person.sign_agreement(@survey)

    redirect_to :back
  end

  def assign_person
    @survey = Survey.find(params[:id])
    @person = Person.find(params[:person_id])
    Membership.create(person_id: params[:person_id], fuction: "survey access", resource: "survey", resource_id: params[:id])

    @person.access_granted(@survey)

    redirect_to :back
  end

  def remove_person
    @survey = Survey.find(params[:id])
    @person = Person.find(params[:person_id])
    m = Membership.where(person_id: params[:person_id], fuction: "survey access", resource: "survey", resource_id: params[:id]).first

    if m 
      m.destroy
      @person.access_revoked(@survey)
    end

    redirect_to :back
  end

  def intro
    @survey = Survey.find(params[:id])
  end

  def slide_show
    @survey = Survey.find(params[:id])

    redirect_to survey_question_path(@survey, @survey.questions.first)
  end

  def new
    @survey = Survey.new
    authorize! :create, @survey
  end

  def create
    @survey = Survey.new(params[:survey])
    
    authorize! :create, Survey

    @survey.author = current_user
    
    if @survey.save
      redirect_to edit_survey_path(@survey)
    else
      flash[:notice] = "Please give your new survey a title."
      redirect_to surveys_path
    end
  end

  def edit
    @survey = Survey.find(params[:id])
    authorize! :edit, @survey
  end
  
  def sort
    params[:question].each_with_index do |id, index|
      Question.update_all({position: index+1}, {id: id})
    end
    render nothing: true
    
  end
  
  def update
    @survey = Survey.find(params[:id])
    authorize! :edit, @survey
    if @survey.company_survey == true
      @survey.force_sections == true
    end
    @survey.update_attributes(params[:survey])
    redirect_to edit_survey_path(@survey)
  end

  def archive
    @survey = Survey.find(params[:id])
    
    authorize! :destroy, @survey

    @survey.archived = true
    @survey.active = false
    @survey.save
    
    redirect_to surveys_path
  end

  def report
    @survey = Survey.find(params[:id])
    authorize! :create, @survey

    if params[:format] = 'csv'
      if @survey.company_survey == true
        csv_data = CSV.generate() do |csv|
          csv << [@survey.title]
          @survey.questions.each do |q|
            temp = []
            csv << []
            temp << q.prompt

            if q.response_type == 'radio'
              if q.possible_responses.present?
                q.possible_responses.each {|i, r| temp << r if r }
                csv << temp
                temp = []
                if q.responses.present?
                  q.responses.each do |r|
                    unless r.person.admin?
                      temp << r.company.name
                      q.possible_responses.each do |k, v|
                        unless r.selected_response.nil?
                          if r.selected_response == k.to_i
                            temp << 1
                          else
                            temp << 0
                          end
                        end
                      end
                      csv << temp
                      temp = []
                    end
                  end
                end
              end
            end

            if q.response_type == 'checkbox'
              if q.possible_responses.present?
                q.possible_responses.each {|i, r| temp << r }
                csv << temp
                temp = []
                if q.responses.present?
                  q.responses.each do |r|
                    unless r.person.admin?
                      temp << r.company.name
                      unless r.selected_responses.nil?
                        r.selected_responses.each do |s|
                          temp << s
                        end
                      end
                      csv << temp
                      temp = []
                    end
                  end
                end
              end
            end

            if q.response_type == 'singleline' || q.response_type == 'multiline'
                csv << temp
                if q.responses.present?
                  q.responses.each do |r|
                    unless r.person.admin?
                      csv << [r.company.name, r.text_response.html_safe]
                    end
                    csv << []
                  end
                end
              end

            if false
              if q.response_type == 'radio'
                if q.possible_responses.present?
                  q.possible_responses.each do |k, v|
                    csv << [radio_question_responses(q, k).length, v]
                  end
                  csv << []
                end
              end

              if q.response_type == 'checkbox'
                if q.possible_responses.present?
                  q.possible_responses.each do |k, v|
                    csv << [checkbox_question_responses(q, k).length, v]
                  end
                  csv << []
                end
              end

              if q.response_type == 'singleline'
                q.responses.each do |r|
                  unless r.person.admin?
                    csv << [r.text_response.html_safe]
                  end
                  csv << []
                end
              end

              if q.response_type == 'multiline'
                q.responses.each do |r|
                  unless r.person.admin?
                    csv << [r.text_response.html_safe]
                  end
                  csv << []
                end
              end
            end

          end
        end
      else
        csv_data = CSV.generate() do |csv|
          csv << [@survey.title]
          @survey.questions.each do |q|
            temp = []
            csv << []
            temp << q.prompt

            if q.response_type == 'radio'
              if q.possible_responses.present?
                q.possible_responses.each {|i, r| temp << r if r }
                csv << temp
                temp = []
                if q.responses.present?
                  q.responses.each do |r|
                    unless r.person.admin?
                      temp << r.person.name
                      q.possible_responses.each do |k, v|
                        unless r.selected_response.nil?
                          if r.selected_response == k.to_i
                            temp << 1
                          else
                            temp << 0
                          end
                        end
                      end
                      csv << temp
                      temp = []
                    end
                  end
                end
              end
            end

            if q.response_type == 'checkbox'
              if q.possible_responses.present?
                q.possible_responses.each {|i, r| temp << r }
                csv << temp
                temp = []
                if q.responses.present?
                  q.responses.each do |r|
                    unless r.person.admin?
                      temp << r.person.name
                      unless r.selected_responses.nil?
                        r.selected_responses.each do |s|
                          temp << s
                        end
                      end
                      csv << temp
                      temp = []
                    end
                  end
                end
              end
            end

            if q.response_type == 'singleline' || q.response_type == 'multiline'
                csv << temp
                if q.responses.present?
                  q.responses.each do |r|
                    unless r.person.admin?
                      csv << [r.person.name, r.text_response.html_safe]
                    end
                    csv << []
                  end
                end
              end

            if false
              if q.response_type == 'radio'
                if q.possible_responses.present?
                  q.possible_responses.each do |k, v|
                    csv << [radio_question_responses(q, k).length, v]
                  end
                  csv << []
                end
              end

              if q.response_type == 'checkbox'
                if q.possible_responses.present?
                  q.possible_responses.each do |k, v|
                    csv << [checkbox_question_responses(q, k).length, v]
                  end
                  csv << []
                end
              end

              if q.response_type == 'singleline'
                q.responses.each do |r|
                  unless r.person.admin?
                    csv << [r.text_response.html_safe]
                  end
                  csv << []
                end
              end

              if q.response_type == 'multiline'
                q.responses.each do |r|
                  unless r.person.admin?
                    csv << [r.text_response.html_safe]
                  end
                  csv << []
                end
              end
            end

          end
        end
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.csv { send_data csv_data }
    end

  end
end
