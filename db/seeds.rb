# 10.times do |n|
#   User.create!(
#     firstname: Faker::Name.first_name,
#     lastname: Faker::Name.last_name,
#     email: "user#{n + 1}@example.com",
#     password: "SecurePass#{n + 1}!"  # Will be encrypted into password_digest
#   )
# end

# Create 2 superadmins
# 2.times do |n|
#   Agent.create!(
#     firstname: Faker::Name.first_name,
#     lastname: Faker::Name.last_name,
#     email: "superadmin#{n + 1}@example.com",
#     password: "SuperAdminPass#{n + 1}!",
#     role: 'SUPERADMIN'
#   )
# end

# # Create 8 admins
# 8.times do |n|
#   Agent.create!(
#     firstname: Faker::Name.first_name,
#     lastname: Faker::Name.last_name,
#     email: "admin#{n + 1}@example.com",
#     password: "AdminPass#{n + 1}!",
#     role: 'ADMIN'
#   )
# end


# Ensure users and agents exist first
if User.count.zero? || Agent.count.zero?
  puts "Please seed users and agents first before creating tickets."
  exit
end

# Seed 5 tickets per user
User.find_each do |user|
  5.times do
    Ticket.create!(
      title: Faker::Lorem.sentence(word_count: 3),
      content: Faker::Lorem.paragraph(sentence_count: 4),
      created_by: user,
      assigned_to: Agent.order("RANDOM()").first,  # Random agent
      media: [ Faker::Internet.url, nil ].sample,     # Optional media
      deadline: Faker::Date.forward(days: rand(3..30)),
      status: %w[ACTIVE ESCALATED RESOLVED].sample,
      has_user_deleted: false
    )
  end
end

puts "✅ Created #{User.count * 5} tickets (5 per user)."
