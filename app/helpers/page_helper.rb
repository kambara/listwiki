# -*- coding: utf-8 -*-

require 'json'
require 'cgi'

Listwiki.helpers do
  def page_read(title)
    if File.exist?(page_filepath(title))
      File.open(page_filepath(title)).read
    else
      default_page(title.force_encoding("UTF-8")).to_json
    end
  end

  def default_page(title)
    {
      :title      => title,
      :created_at => nil,
      :updated_at => nil,
      :body       => ['']
    }
  end

  def page_write(title, data)
    puts title, data
    File.open(page_filepath(title), 'w') {|f|
      f << data.force_encoding("UTF-8")
    }
  end

  def page_delete(title)
    File.delete(page_filepath(title))
  end

  def page_filepath(title)
    "data/#{ CGI.escape(params[:title]) }.json"
  end
end
