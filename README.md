# README
A system to monitor platform for new entries of given queries and sends email alerts when new results found.

## Tech Stack
- Rails - 5.x.x
- Sidekiq - 6.x.x
- Redis
- SQLite

## Supported Platforms to Monitor
- Tableau
- Shodan

## Steps to setup:
- Install RVM
- Install Ruby 2.7.x
- Use Ruby 2.7.x
- Clone Project
- bundle install
- `rails db:migrate`
- Copy sample config files and setup values
- Start webserver: `rails s`
- Start Sidekiq process: `bundle exec sidekiq`
- Start console: `rails c`
- Add Queries to Monitor:
```
MonitoringQuery.create(:platform_id => 1, :params => {"type" => "authors", "query" => "ankit"}, :interval => 1.hour.to_i, :state => MonitoringQuery::State::VALID)
MonitoringQuery.create(:platform_id => 1, :params => {"type" => "vizzes", "query" => "ankit"}, :interval => 1.hour.to_i, :state => MonitoringQuery::State::VALID)

MonitoringQuery.create(:platform_id => 2, :params => {"query" => "ankit"}, :interval => 1.hour.to_i, :state => MonitoringQuery::State::VALID)

# To test from console
action = MonitoringAction.create(:monitoring_query_id => 1, :state => MonitoringAction::State::INITIALIZED)
MonitoringActionJob.new.perform(action.id)

ProcessAlertJob.new.perform
```
- From console: `MasterMonitoringJob.perform_async`
- Check logs in sidekiq workers
- Preview sample emails at: `http://localhost:3000/rails/mailers/alert_mailer`
- Check sidekiq status at: `http://localhost:3000/sidekiq`

## Future
This is a very basic functioning prototype. Lots of scope of improvements.
Most of things were written considering time of implementation in mind.
