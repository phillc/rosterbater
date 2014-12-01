module ApplicationHelper
  def load_javascript_class(javascript_class, options = nil)
    content_for :page_javascripts do
      javascript_tag "$(function(){ (new #{javascript_class}(#{options.to_json})).bind(); })"
    end
  end

  def large_banner_ad
    content_tag :div, class: "text-center" do
      render "layouts/footer_ad_#{rand(2..3)}"
    end
  end
end
