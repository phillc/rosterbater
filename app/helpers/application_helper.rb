module ApplicationHelper
  def load_javascript_class(javascript_class, options = nil)
    content_for :javascripts do
      javascript_tag "$(function(){ (new #{javascript_class}(#{options.to_json})).bind(); })"
    end
  end
end
