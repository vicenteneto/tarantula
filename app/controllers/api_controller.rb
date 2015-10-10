class ApiController < ApplicationController
  skip_filter :set_current_user_and_project
  before_filter :login_once
  before_filter do |f|
    f.require_permission(['ADMIN'])
  end
  respond_to :xml

  def create_user
    @user = User.new(@data)
    @user.new_random_password if @user.password.blank?
    @user.save!

    render :json => @user.id, :status => :created
  end

  def create_project
    test_areas = @data.delete('test_areas')
    bug_products = @data.delete('bug_products')
    assigned_users = @data.delete('assigned_users')

    @project = Project.create_with_assignments!(@data, assigned_users, test_areas, bug_products)

    render :json => @project.id, :status => :ok
  end

  def view_project
    @project = Project.find(params[:id])

    render :json => {:data => [@project.to_data]}
  end

  private
  def login_once
    authenticate_or_request_with_http_basic do |username, password|
      if can_do_stuff?(username,password)
        set_current_user_and_project
      end
    end
  end
end