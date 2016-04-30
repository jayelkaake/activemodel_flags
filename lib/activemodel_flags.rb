require "activemodel_flags/version"

module ActivemodelFlags
  if defined?(Rails)
    require 'activemodel_flags/has_flags'
  end
end
