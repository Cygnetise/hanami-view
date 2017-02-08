require 'test_helper'

describe 'Framework configuration' do
  it 'keeps separated copies of the configuration' do
    framework_configuration = Hanami::View.configuration
    card_configuration      = CardDeck::View.configuration

    framework_configuration.wont_equal(card_configuration)
  end

  it 'sets a root path' do
    card_configuration = CardDeck::View.configuration
    card_configuration.root.must_equal(Pathname.new('test/fixtures/templates/card_deck/app/templates').realpath)
  end

  it 'sets a layout' do
    card_configuration = CardDeck::View.configuration
    card_configuration.layout.must_equal(CardDeck::ApplicationLayout)
  end

  it 'allow views to inherit the layout' do
    view_configuration = CardDeck::Views::Home::Index.configuration
    view_configuration.layout.must_equal(CardDeck::ApplicationLayout)
  end

  it 'includes modules from configuration in views' do
    modules = CardDeck::Views::Home::Index.included_modules
    modules.must_include(::MyCustomModule)
    modules.must_include(::MyOtherCustomModule)
  end

  it 'includes modules from configuration in layouts' do
    modules = CardDeck::ApplicationLayout.included_modules
    modules.must_include(::MyCustomModule)
    modules.must_include(::MyOtherCustomModule)
  end

  it 'in a view disable a layout' do
    CardDeck::Views::Home::RssIndex.layout.must_equal Hanami::View::Rendering::NullLayout
  end

  it 'allow views to specify a layout'
  # TODO move all the values into the configuration:
  #
  #   * format
  #   * layout
  #   * template
  #
  # TODO move all the inherit logic into configuration:
  #
  #   Instead of HelloWorldView.subclasses, use HelloWorldView.configuration.views
  #
  # This also helps to have an unified API to load the framework Configuration#load! vs
  # Hanami::View::Inheritable#load!
  #
  # it 'allow views to specify a layout' do
  #   view_configuration = CardDeck::Views::Home::JsonIndex.configuration
  #   view_configuration.layout.must_be_nil
  # end
end
