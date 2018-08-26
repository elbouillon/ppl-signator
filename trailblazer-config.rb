require "trailblazer/loader"
require "trailblazer/cells"
require "cells-slim"

Trailblazer::Loader.new.(concepts_root: "./concepts/") { |file| require_relative(file) }

Trailblazer::Cell.class_eval do
  include Cell::Slim
  self.view_paths = ["concepts"] # DISCUSS: is that the right place?
end

# Reform::Form.send(:feature, Reform::Form::Dry)
