require "sidekiq-scheduler"

Sidekiq.configure_server do |config|
  config.on(:startup) do
    schedule_file = Rails.root.join("config", "sidekiq.yml")

    if File.exist?(schedule_file)
      schedule = YAML.load_file(schedule_file)[Rails.env] || YAML.load_file(schedule_file)
      schedule = schedule[:scheduler] if schedule[:scheduler].present? && schedule[:scheduler][:schedule].present?
      if schedule && schedule[:schedule].is_a?(Hash)
        Sidekiq.schedule = schedule[:schedule]
      else
        puts "No schedule found under :scheduler key in #{schedule_file}"
      end
    else
      puts "Sidekiq schedule file not found: #{schedule_file}"
    end

    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end
end
