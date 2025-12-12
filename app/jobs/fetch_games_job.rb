class FetchGamesJob < ApplicationJob
  queue_as :default
  
  API_BASE_URL = 'https://www.freetogame.com/api'
  
  def perform(force_refresh: false)
    Rails.logger.info "🎮 Starting Free Games API sync..."
    
    # Fetch all games
    games_data = fetch_all_games
    return if games_data.empty?
    
    # Process in batches to avoid memory issues
    games_data.each_slice(50) do |batch|
      ActiveRecord::Base.transaction do
        batch.each { |game_data| process_game(game_data, force_refresh) }
      end
      Rails.logger.info "Processed batch of #{batch.size} games"
    end
    
    # Clean up old games if forcing refresh
    cleanup_old_games(games_data) if force_refresh
    
    Rails.logger.info "✅ Sync complete! Total: #{Game.count}"
    
    # Optional: Update game statistics
    update_game_stats
  rescue StandardError => e
    Rails.logger.error "❌ Job failed: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
    raise e
  end
  
  private
  
  def fetch_all_games
    response = HTTParty.get("#{API_BASE_URL}/games", timeout: 30)
    
    unless response.success?
      raise "API error: #{response.code} - #{response.message}"
    end
    
    JSON.parse(response.body)
  rescue HTTParty::Error => e
    Rails.logger.error "HTTP error: #{e.message}"
    []
  end
  
  def process_game(game_data, force_refresh)
    # Skip if missing critical data
    return unless game_data['id'].present? && game_data['title'].present?
    
    game = Game.find_or_initialize_by(api_id: game_data['id'].to_s)
    
    # Skip if already exists and not stale (unless force refresh)
    return if game.persisted? && !force_refresh && !game_stale?(game)
    
    # Map API data to your schema
    assign_game_attributes(game, game_data)
    
    # Handle screenshots
    assign_screenshots(game, game_data)
    
    if game.save
      Rails.logger.debug "✓ #{game.title}"
    else
      Rails.logger.warn "✗ Failed #{game.title}: #{game.errors.full_messages}"
    end
  end
  
  def assign_game_attributes(game, game_data)
    game.assign_attributes(
      title: game_data['title'].to_s,
      thumbnail: game_data['thumbnail'].to_s,
      genre: game_data['genre'].to_s,
      short_description: game_data['short_description'].to_s,
      description: game_data['description'].to_s,
      game_url: game_data['game_url'].to_s,
      platform: game_data['platform'].to_s,
      publisher: game_data['publisher'].to_s,
      developer: game_data['developer'].to_s,
      release_date: game_data['release_date'].to_s,
      minimum_system_requirements: extract_system_requirements(game_data)
    )
  end
  
  def extract_system_requirements(game_data)
    return '' unless game_data['minimum_system_requirements']
    
    reqs = game_data['minimum_system_requirements']
    # Format nicely as string or JSON
    {
      os: reqs['os'].to_s,
      processor: reqs['processor'].to_s,
      memory: reqs['memory'].to_s,
      graphics: reqs['graphics'].to_s,
      storage: reqs['storage'].to_s
    }.to_json
  end
  
  def assign_screenshots(game, game_data)
    return unless game_data['screenshots'].is_a?(Array)
    
    screenshots = game_data['screenshots'].take(3)  # Get first 3 screenshots
    
    screenshots.each_with_index do |screenshot, index|
      column_name = "screenshot#{index + 1}"
      game[column_name] = screenshot['image'].to_s if game.respond_to?(column_name)
    end
  end
  
  def game_stale?(game)
    # Game is stale if not updated in 3 days
    game.updated_at < 3.days.ago
  end
  
  def cleanup_old_games(current_games_data)
    current_api_ids = current_games_data.map { |g| g['id'].to_s }
    
    stale_count = Game.where.not(api_id: current_api_ids).count
    return if stale_count.zero?
    
    Rails.logger.info "🧹 Removing #{stale_count} stale games..."
    Game.where.not(api_id: current_api_ids).destroy_all
  end
  
  def update_game_stats
    # Store some statistics
    stats = {
      total_games: Game.count,
      by_genre: Game.group(:genre).count,
      by_platform: Game.group(:platform).count,
      last_synced: Time.current
    }
    
    # Store in Redis for quick access
  Rails.cache.write('games:stats', stats, expires_in: 1.hour)
  end
end