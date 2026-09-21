namespace :users do
  desc "Create or promote an approved master user (EMAIL=... [PASSWORD=...])"
  task create_master: :environment do
    email = ENV.fetch("EMAIL") { abort "EMAIL is required" }

    user = User.find_or_initialize_by(email_address: email)
    user.password = ENV["PASSWORD"] if ENV["PASSWORD"].present?
    user.approved = true
    user.master = true
    user.save!

    puts "Master user ready: #{user.email_address}"
  end
end
