import React, { useState, useEffect } from "react";
import helperFetch from "../helpers/Fetcher.js";
import ReviewForm from "./ReviewsForm.js";
import ReviewTiles from "./ReviewTiles.js";
import { Link } from "react-router-dom";

const GamesShow = (props) => {
	const [game, setGame] = useState({});
	const [reviews, setReviews] = useState([]);
	const [user, setUser] = useState({});
	const [description, setDescription] = useState([]);
	const [showMoreStatus, setShowMoreStatus] = useState(true);
	const [reviewNumber, setReviewNumber] = useState("");
	const [favorited, setFavorited] = useState(false);
	const [subscribed, setSubscribed] = useState("");
	const [userPhoto, setUserPhoto] = useState("");
	const gameId = props.match.params.id;
	const [formData, setFormData] = useState({
	body: "",
	game_id: "",
	});
	useEffect(() => {
	fetch(`/games/${gameId}`, {
		headers: { 'Accept': 'application/json' }
	})
	.then(response => response.json())
	.then((gameData) => {		
		setGame(gameData);
		setFormData({
		body: "",
		game_id: gameData.id, // Use DATABASE ID, not api_id
		});

		setDescription(gameData.short_description);
		
		if (gameData.reviews) {
		setReviews(gameData.reviews);
		setReviewNumber(gameData.reviews.length);
		}
	});
	helperFetch("/users").then((userData) => {
	if (userData) {
		setUser(userData);
		// Safe access - profile_photo might be null or a string
		const photo = userData.profile_photo;
		setUserPhoto(typeof photo === 'object' ? photo?.url : photo || "");
	}
	});
	}, []);

	const favorite = async (event) => {
		const response = await fetch("/favorite_games", { 
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				Accept: "application/json",
			},
			credentials: "same-origin",
			body: JSON.stringify({ game: game.id }),
		});
		const responseJson = await response.json();
		if (responseJson.success) {
			setFavorited(!favorited);
		}
	};

	const toggleShowMore = (event) => {
		event.preventDefault();
		setShowMoreStatus(!showMoreStatus);
	};

	let style = "favorite";
	if (favorited) {
		style = "favored";
	}

	const addNewReview = async (formPayload) => {
		try {
			const response = await fetch("/reviews", {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					Accept: "application/json",
				},
				credentials: "same-origin",
				body: JSON.stringify(formPayload),
			});
			if (!response.ok) {
				const errorMessage = `${response.status} ${response.statusText}`;
				throw new Error(errorMessage);
			}
			const newReview = await response.json();
			if (newReview.errors) {
				alert(newReview.errors);
			} else {
				setReviews([...reviews, newReview]);
				setReviewNumber(game.reviews);
			}

			setFormData({
			body: "",
			game_id: gameId,
			});
		} catch (err) {
			console.log(err);
		}
	};
	const updateReview = (index) => {
		setReviews(
			reviews.slice(0, index).concat(reviews.slice(index + 1, reviews.lenght))
		);
	};
	const deleteReview = (id, position) => {
		fetch(`/reviews/${id}`, { method: "DELETE" }).then(() =>
			updateReview(position)
		);
	};

	const reviewTiles = reviews.map((review, index) => {
		return (
			<ReviewTiles
				key={review.id}
				review={review}
				user={review.user}
				position={index}
				updateReview={updateReview}
				deleteReview={deleteReview}
				currentUser={user}
				game={game}
			/>
		);
	});

	let userImage = userPhoto;
	if (userPhoto === null) {
		userImage =
			"https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/542px-Unknown_person.jpg";
	}

	let createReviews;
	if (user) {
		createReviews = (
			<ReviewForm
				addNewReview={addNewReview}
				formData={formData}
				setFormData={setFormData}
				game={game.title}
			/>
		);
	}

	// if (game.favorite_games) {
	// 	game.favorite_games.forEach((info) => {
	// 		console.log(info.user.id);
	// 	});
	// }
	let text;

	if (showMoreStatus) {
		text = description;
	} else {
		text = game.short_description;
	}
	return (
		<div className='q1'>
			<Link to={`/user/${user.id}`}>
				<img className='profile-image' src={userImage} />
			</Link>
			<div className='gameprofile_gradient'>
				<div className='left'>
					{" "}
					<img src={game.thumbnail} />{" "}
					<div>
						<a className='play-now' href={game.game_url} target='_blank'>
							{" "}
							<strong>Play Now</strong>{" "}
						</a>
					</div>
				</div>
				<div className='right'>
					{" "}
					<h1>{game.title}</h1>
					<a className={style} onClick={favorite}>
						{favorited ? "Favorited!" : "Favorite"}
					</a>
					<p> {reviewNumber} Comments</p>
					<p> {subscribed} Favored</p>
					{/* <p>3 Favorite</p> */}
					<p>
						{text}
					</p>
					<div className='info'>
						<h2>Aditional information</h2>
					</div>
					<div className='row-flex'>
						<div className='col-6 col-md-4'>
							<span>
								<strong>Title</strong>
							</span>
							<p>{game.title}</p>
						</div>
						<div className='col-6 col-md-4'>
							<span>
								<strong>Developer</strong>
							</span>
							<p>{game.developer}</p>
						</div>
						<div className='col-6 col-md-4'>
							<span>
								<strong>Publisher</strong>
							</span>
							<p>{game.publisher}</p>
						</div>
						<div className='col-6 col-md-4'>
							<span>
								<strong>Release Date</strong>
							</span>
							<p>{game.release_date}</p>
						</div>
						<div className='col-6 col-md-4'>
							<span>
								<strong>Genre</strong>
							</span>
							<p>{game.genre}</p>
						</div>
						<div className='col-6 col-md-4'>
							<span>
								<strong>Platform</strong>
							</span>
							<p>{game.platform}</p>
						</div>
					</div>
					<h2>{game.title} Screenshots</h2>
					<div className='row-flex'>
						<div className='col-6 col-md-4'>
							<img className='image' src={game.screenshot1} alt='hey'></img>
						</div>
						<div className='col-6 col-md-4'>
							<img className='image' src={game.screenshot2} alt='hey'></img>
						</div>
						<div className='col-6 col-md-4'>
							<img className='image' src={game.screenshot3} alt='hey'></img>
						</div>
						<div className='info'>
							<h2>Minimum System Requirements</h2>
						</div>
						<div className='row-flex'>
							<div className='col-6 col-md-4'>
								<span>
									<strong>OS</strong>
								</span>
								<p>{game.os1}</p>
							</div>
							<div className='col-6 col-md-4'>
								<span>
									<strong>Processor</strong>
								</span>
								<p>{game.os2}</p>
							</div>
							<div className='col-6 col-md-4'>
								<span>
									<strong>Memory</strong>
								</span>
								<p>{game.os3}</p>
							</div>
							<div className='col-6 col-md-4'>
								<span>
									<strong>Graphics</strong>
								</span>
								<p>{game.os4}</p>
							</div>
							<div className='col-6 col-md-4'>
								<span>
									<strong>Storage</strong>
								</span>
								<p>{game.os5}</p>
							</div>
							<div className='col-6 col-md-4'>
								<span>
									<strong>Aditional Notes</strong>
								</span>
								<p>Specifications may change during development</p>
							</div>
						</div>
					</div>
					<div className='form-line'>{createReviews}</div>
					<h2>User Comments</h2>
					<div>{reviewTiles}</div>
				</div>
			</div>
		</div>
	);
};

export default GamesShow;
