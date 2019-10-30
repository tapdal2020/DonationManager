# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create({ email: 'root@admin.com', password: 'root', password_confirmation: 'root', admin: true })
u = User.create({ first_name: 'user', last_name: 'user', email: 'me@user.com', password: 'user', password_confirmation: 'user', street_address_line_1: 'home', city: 'home', state: 'home', zip_code: '77840' })