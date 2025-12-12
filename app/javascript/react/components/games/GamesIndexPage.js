import React from "react";
import { useState, useEffect } from "react";
import GameTile from "./GameTile";
import Search from "./Search";
import { Link } from "react-router-dom";

const GamesIndexPage = (props) => {
  const [games, setGames] = useState([]);
  const [showMoreStatus, setShowMoreStatus] = useState(true);
  const [search, setSearch] = useState("");
  const [searchResults, setSearchResults] = useState([]);
  const [user, setUser] = useState({});
  const [userPhoto, setUserPhoto] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchGames = async () => {
    try {
      const response = await fetch("/games");
      
      if (!response.ok) {
        throw new Error(`API Error: ${response.status}`);
      }
      
      const parsedGames = await response.json();
      
      // Handle different API response structures
      let gamesData = [];
      
      if (Array.isArray(parsedGames)) {
        // Direct array: [...]
        gamesData = parsedGames;
      } else if (parsedGames && Array.isArray(parsedGames.data)) {
        // { data: [...] }
        gamesData = parsedGames.data;
      } else if (parsedGames && Array.isArray(parsedGames.games)) {
        // { games: [...] }
        gamesData = parsedGames.games;
      } else {
        console.warn("Unexpected API structure, using empty array");
        gamesData = [];
      }
      
      setGames(gamesData);
      setSearchResults(gamesData);
      setError(null);
    } catch (err) {
      console.error("Failed to fetch games:", err);
      setError("Failed to load games. Please try again.");
      setGames([]);
      setSearchResults([]);
    } finally {
      setLoading(false);
    }
  };

  const fetchUser = async () => {
    try {
      const response = await fetch(`/users`);
      if (!response.ok) return;
      
      const userData = await response.json();
      if (userData) {
        setUser(userData);
        setUserPhoto(userData.profile_photo?.url || "");
      }
    } catch (err) {
      console.warn("Could not fetch user:", err);
    }
  };

  useEffect(() => {
    fetchGames();
    fetchUser();
  }, []);

  let userImage = userPhoto;
  if (!userPhoto) {
    userImage = "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/542px-Unknown_person.jpg";
  }

  const toggleShowMore = (event) => {
    event.preventDefault();
    setShowMoreStatus(!showMoreStatus);
  };

  const searchHandler = (searchTerm) => {
    setSearch(searchTerm);
    
    if (searchTerm !== "") {
      const newGameList = games.filter((game) => {
        return Object.values(game)
          .join(" ")
          .toLowerCase()
          .includes(searchTerm.toLowerCase());
      });
      setSearchResults(newGameList);
    } else {
      setSearchResults(games);
    }
  };

  // Show loading state
  if (loading) {
    return (
      <div className="loading">
        <h2>Loading games...</h2>
        <p>Please wait while we fetch the latest games.</p>
      </div>
    );
  }

  // Show error state
  if (error) {
    return (
      <div className="error">
        <h2>Error Loading Games</h2>
        <p>{error}</p>
        <button onClick={fetchGames} className="retry-button">
          Try Again
        </button>
      </div>
    );
  }

  // Generate game tiles
  let gameTiles;
  const gamesToShow = showMoreStatus ? searchResults : searchResults;
  
  if (gamesToShow.length === 0) {
    gameTiles = (
      <div className="no-games">
        <h3>No games found</h3>
        {search ? (
          <p>No games match your search. Try a different term.</p>
        ) : (
          <p>No games available. Please sync games from the API.</p>
        )}
      </div>
    );
  } else {
    gameTiles = gamesToShow.map((game) => (
      <div key={game.id || game.api_id}>
        <GameTile game={game} />
      </div>
    ));
  }

  return (
    <div>
      {user.id && (
        <Link to={`/user/${user.id}`}>
          <img className="profile-image" src={userImage} alt="User profile" />
        </Link>
      )}
      
      <div className="row expanded collapse">
        <div className="column">
          <div className="large-article-header">
            <div className="large-article-header-content">
              <div className="center-container">
                <div className="article-date">
                  <p>Created by Daniel Zhdanov</p>
                </div>
                <div className="article-title">
                  <h1>
                    Every Free Game You Would <strong>EVER</strong> Need
                  </h1>
                </div>
                <Search
                  className="search"
                  term={search}
                  searchKeyword={searchHandler}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div className="product-card">
        {gameTiles}
      </div>
      
      {searchResults.length > 12 && (
        <button onClick={toggleShowMore} className="show-more">
          {showMoreStatus ? "Load More" : "Show Less"}
        </button>
      )}
      
      <div className="game-stats">
        <p>Showing {gamesToShow.length} of {searchResults.length} games</p>
      </div>
    </div>
  );
};

export default GamesIndexPage;