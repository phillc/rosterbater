module ApplicationHelper
  def load_javascript_class(javascript_class, options = nil)
    content_for :page_javascripts do
      javascript_tag "$(function(){ (new #{javascript_class}(#{options.to_json})).bind(); })"
    end
  end

  def week_1_alert
    if @league.start_week != 1
      content_tag :div, class: "alert alert-danger" do
        "Sorry, this tool does not work for leagues that do not start in week 1."
      end
    end
  end
end
