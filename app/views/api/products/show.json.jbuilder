json.extract! @product, :id, :category, :name, :dosage, :package



json.prices do @product.prices do |price|
end
