# -*- coding: utf-8 -*-

Listwiki.controllers :page do
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

  get :index, :map => '/' do
    redirect '/page/index'
  end

  get :index, :with => :title do
    @title = params[:title]
    render 'page/page.haml'
  end

  get :api, :with => :title do
    content_type 'application/json'
    page_read(params[:title])
  end

  post :api, :with => :title do
    content_type 'application/json'
    page_write(params[:title], request.env["rack.input"].read)
    {}.to_json
  end

  put :api, :with => :title do
    content_type 'application/json'
    page_write(params[:title], params[:data])
  end

  delete :api, :with => :title do
    content_type 'text/json'
    page_delete(params[:title])
  end
end
