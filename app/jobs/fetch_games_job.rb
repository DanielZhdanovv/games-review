class FetchGamesJob < ApplicationJob
  queue_as :default
  
  API_BASE_URL = 'https://www.freetogame.com/api'
  
  def perform(force_refresh: false)
    Rails.logger.info "Starting Free Games API sync..."
    
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
    
    Rails.logger.info "Sync complete! Total: #{Game.count}"

  rescue StandardError => e
    Rails.logger.error "Job failed: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
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
    #Skip game exists
    return unless game_data['id'].present? && game_data['title'].present?
    
    game = Game.find_or_initialize_by(api_id: game_data['id'].to_s)
    return if game.persisted? && !force_refresh && !game_stale?(game)
    #Assign games
    assign_game_attributes(game, game_data)
    
    if game.save
      Rails.logger.debug "✓ #{game.title}"
    else
      Rails.logger.warn "✗ Failed #{game.title}: #{game.errors.full_messages}"
    end
  end
  
  def assign_game_attributes(game, game_data)
    short_desc = game_data['short_description'].to_s
    
    game.assign_attributes(
      api_id: game_data['id'].to_s,
      title: game_data['title'].to_s,
      thumbnail: game_data['thumbnail'].to_s,
      genre: game_data['genre'].to_s,
      short_description: short_desc,
      description: short_desc,
      game_url: game_data['game_url'].to_s,
      platform: game_data['platform'].to_s,
      publisher: game_data['publisher'].to_s,
      developer: game_data['developer'].to_s,
      release_date: game_data['release_date'].to_s,
      minimum_system_requirements: ''
    )
  end

end