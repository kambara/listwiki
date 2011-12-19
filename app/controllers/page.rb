# -*- coding: utf-8 -*-

Listwiki.controllers :page do
  get :index, :map => '/' do
    redirect '/page/index'
  end

  get :index, :with => :title do
    ## /page/:title
    @title = params[:title]
    render 'page/list.haml'
  end

  get :slides, :with => :title do
    ## /page/slides/:title
    @title = params[:title]
    render 'page/slides.haml'
  end

  get :api, :with => :title do
    content_type 'application/json'
    begin
      page_read(params[:title])
    rescue => ex
      { :status => 'error',
        :message => ex.message
      }.to_json
    end
  end

  post :api, :with => :title do
    content_type 'application/json'
    begin
      page_write(params[:title], request.env["rack.input"].read)
      {}.to_json
    rescue => ex
      { :status => 'error',
        :message => ex.message
      }.to_json
    end
  end

  delete :api, :with => :title do
    content_type 'text/json'
    begin
      page_delete(params[:title])
      {}.to_json
    rescue => ex
      { :status => 'error',
        :message => ex.message
      }.to_json
    end
  end

  # get :index, :map => "/foo/bar" do
  #   session[:foo] = "bar"
  #   render 'index'
  # end

  # get :sample, :map => "/sample/url", :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get "/example" do
  #   "Hello world!"
  # end
end
