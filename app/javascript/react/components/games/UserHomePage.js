import React from "react";
import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import FavoriteTiles from "./FavoriteTiles";
import PieChart from "./PieChart.js";

const UserHomePage = (props) => {
	const [user, setUser] = useState({});
	const [favorites, setFavorites] = useState([]);
	const [userPhoto, setUserPhoto] = useState("");
	const userId = props.match.params.id;
	const fetchUser = async () => {
	const response = await fetch(`/users/${userId}`);
		const userData = await response.json();
		setUser(userData);
		setUserPhoto(userData.profile_photo.url);
		setFavorites(userData.favorite_games);
	};
	useEffect(() => {
		fetchUser();
	}, []);

	let userImage = userPhoto;
	if (userPhoto === null) {
		userImage =
			"https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/542px-Unknown_person.jpg";
	}
	const gamesTiles = favorites.map((game) => {
		return (
			<FavoriteTiles
				key={game.game.id}
				id={game.game.id}
				title={game.game.title}
				thumbnail={game.game.thumbnail}
				genre={game.game.genre}
			/>
		);
	});

	return (
		<div>
			<Link to={`/user/${user.id}`}>
				<img className='profile-image' src={userImage} />
			</Link>
			<div className='main-container'>
				<div className='gameprofile_gradient'>
					<div className='left-container'>
						<img className='user-image' src={userImage} />
						<h1 className='user-name'>{user.first_name}</h1>
					</div>
					<div className='right-container'>
						<PieChart genre={favorites} />
					</div>

					<hr></hr>
					<h2 className='favorited'>Favorited Games:</h2>
					<div className='product-card'>{gamesTiles}</div>
				</div>
			</div>
		</div>
	);
};

export default UserHomePage;
