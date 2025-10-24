class BaseBlueprint < Blueprinter::Base
  def self.render(object, options = {})
    json_string = super(object, options)
    hash = JSON.parse(json_string)
    transformed = transform_to_camel_case(hash)
    transformed = remove_null_values(transformed)
    JSON.generate(transformed)
  end

  def self.render_as_hash(object, options = {})
    hash = super(object, options)
    transform_to_camel_case(hash)
  end

  private

  def self.transform_to_camel_case(data)
    case data
    when Hash
      data.transform_keys { |key| key.to_s.camelize(:lower).to_sym }
           .transform_values { |value| transform_to_camel_case(value) }
    when Array
      data.map { |item| transform_to_camel_case(item) }
    when String
      # Convert snake_case strings to camelCase (for enum values)
      data.include?('_') ? data.camelize(:lower) : data
    else
      data
    end
  end

  def self.remove_null_values(data)
    case data
    when Hash
      data.reject { |_, value| value.nil? }
          .transform_values { |value| remove_null_values(value) }
    when Array
      data.map { |item| remove_null_values(item) }
    else
      data
    end
  end
end
