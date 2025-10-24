module Transformers
  class CamelCaseTransformer
    def self.call(hash)
      hash.transform_keys! { |key| key.to_s.camelize(:lower).to_sym }
    end
  end
end
