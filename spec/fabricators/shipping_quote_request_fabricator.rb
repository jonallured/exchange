Fabricator(:shipping_quote_request) do
  external_id { SecureRandom.hex(10) }
  line_item { Fabricate(:line_item) }
end
