# frozen_string_literal: true

RSpec.describe "View / errors" do
  specify "Raising an error when paths are not configured" do
    view_class = Class.new(Hanami2::View) do
      config.template = "hello"
    end

    expect { view_class.new }.to raise_error(Hanami2::View::UndefinedConfigError, "no +paths+ configured")
  end

  specify "Raising an error when template is not configured" do
    view_class = Class.new(Hanami2::View) do
      config.paths = FIXTURES_PATH.join("integration/errors")
    end

    expect { view_class.new }.to raise_error(Hanami2::View::UndefinedConfigError, "no +template+ configured")
  end
end
