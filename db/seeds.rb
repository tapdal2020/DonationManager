# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!({ email: 'root@admin.com', password: 'root', password_confirmation: 'root', admin: true })
u = User.create({ first_name: 'user', last_name: 'user', email: 'me@user.com', password: 'user', password_confirmation: 'user', street_address_line_1: 'home', city: 'home', state: 'home', zip_code: '77840', membership: 'None' })
# MadeDonation.create({ user_id: u.id, payment_id: "FAKE-PAY_ID-0000NULL0100", price: 10})
MadeDonation.create({user_id: u.id, payment_id: "I-EE5J6KLNXG90", price: 1, recurring: true, frequency: "MONTHLY"})