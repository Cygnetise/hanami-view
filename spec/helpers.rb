module Helpers
  module AssetTagHelpers
    def javascript_tag(source)
      Hanami::CygUtils::Escape::SafeString.new %(<script type="text/javascript" src="/javascripts/#{ source }.js"></script>)
    end
  end
end
