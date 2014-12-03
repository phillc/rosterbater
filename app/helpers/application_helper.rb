module ApplicationHelper
  def load_javascript_class(javascript_class, options = nil)
    content_for :page_javascripts do
      javascript_tag "$(function(){ (new #{javascript_class}(#{options.to_json})).bind(); })"
    end
  end

  def footer_ad
    number = rand(1..3)
    if number == 1
      render "shared/footer_ad"
    else
      content_tag :div, class: "text-center" do
        render "shared/amazon_banner_ad_#{number}"
      end
    end
  end

  def large_banner_ad
    number = rand(0..3)
    if number == 0 || number == 1
      render "shared/google_large_banner_ad"
    else
      content_tag :div, class: "text-center" do
        render "shared/amazon_banner_ad_#{rand(2..3)}"
      end
    end
  end
end
