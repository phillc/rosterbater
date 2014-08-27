module Support
  module FixtureHelper
    def fixture(name)
      File.open(Rails.root.join("spec", "fixtures", name)).read
    end
  end
end

