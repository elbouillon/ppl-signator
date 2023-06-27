class Contact < Sequel::Model(:contacts)
  many_to_one :address
end

class Place < Sequel::Model(:places)
  many_to_one :address
  one_to_many :works
end

class Address < Sequel::Model(:addresses)
  one_to_many :places
end

class Work < Sequel::Model(:works)
  many_to_one :customer, class: :Contact, key: :customer_id
  many_to_one :place
end
