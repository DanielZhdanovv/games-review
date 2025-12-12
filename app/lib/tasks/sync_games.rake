namespace :games do
  desc "Sync games from Free Games API"
  task sync: :environment do
    puts "Syncing games from Free Games API..."
    
    # Run job synchronously for rake task
    FetchGamesJob.perform_now
    
    puts "Sync complete!"
    puts "Total games: #{Game.count}"
    puts "Genres: #{Game.distinct.pluck(:genre).join(', ')}"
  end
  
  desc "Force refresh all games"
  task force_sync: :environment do
    puts "Force refreshing all games..."
    
    FetchGamesJob.perform_now(force_refresh: true)
    
    puts "Force sync complete!"
    puts "   Total games: #{Game.count}"
  end
  
  desc "Show game statistics"
  task stats: :environment do
    puts "Game Statistics"
    puts "=" * 50
    puts "Total games: #{Game.count}"
    puts "Last updated: #{Game.maximum(:updated_at)}"
    
    puts "By Genre:"
    Game.group(:genre).count.sort_by { |_, count| -count }.each do |genre, count|
      puts "  #{genre}: #{count}"
    end
    
    puts "By Platform:"
    Game.group(:platform).count.each do |platform, count|
      puts "  #{platform}: #{count}"
    end
    
    puts "Games with screenshots:"
    Game.where.not(screenshot1: [nil, '']).count
  end
end