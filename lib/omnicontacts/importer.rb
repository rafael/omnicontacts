module OmniContacts
  module Importer

    autoload :Gmail, "omnicontacts/importer/gmail"
    autoload :Yahoo, "omnicontacts/importer/yahoo"
    autoload :Hotmail, "omnicontacts/importer/hotmail"
    autoload :Facebook, "omnicontacts/importer/facebook"
    autoload :Twitter, "omnicontacts/importer/twitter"

  end
end
