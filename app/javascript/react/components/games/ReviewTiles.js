import React, { useState } from "react";
import ReviewEdit from "./ReviewEdit";


const ReviewTiles = (props) => {
	  console.log("ReviewTiles props:", props);
  console.log("Review body:", props.review?.body);
  console.log("Body type:", typeof props.review?.body);
	const [edit, setEdit] = useState(false);
	const { review, user, deleteReview, position, currentUser } = props;
	const [currentReview, setCurrentReview] = useState(review);
	const [like, setlike] = useState(review.upvotes);

	const [formData, setFormData] = useState({
		upvotes: "",
		body: "",
	});

	const likeFunction = () => {
		setlike(like + 1);
		setCurrentReview({ ...currentReview, upvotes: like + 1 });
		updateLikes(currentReview);
	};

	const updateLikes = async () => {
		try {
			const response = await fetch(`/reviews/${review.id}`, {
				method: "PATCH",
				headers: {
					"Content-Type": "application/json",
					Accept: "application/json",
				},
				credentials: "same-origin",
				body: JSON.stringify(currentReview),
			});
			if (!response.ok) {
				const errorMessage = `${response.status} ${response.statusText}`;
				throw new Error(errorMessage);
			}
			const newReview = await response.json();
			if (newReview.errors) {
				alert(newReview.errors);
			} else {
				setCurrentReview(newReview);
				setFormData({
					upvotes: review.upvotes,
				});
			}
		} catch (err) {
			console.log(err);
		}
	};


	let text = "user";

	if (user.role == "admin") {
		text = "admin";
	}

	const editReview = async (formPayload) => {
		setEdit(false);
		try {
			const response = await fetch(`/reviews/${review.id}`, {
				method: "PATCH",
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
				setCurrentReview(newReview);
				setFormData({
					body: review.body,
				});
			}
		} catch (err) {
			console.log(err);
		}
	};

	const button = (event) => {
		event.preventDefault();
		setEdit(!edit);
	};

	let textField = <h3 className='review-description'>{currentReview.body}</h3>;
	if (edit === true) {
		textField = (
			<ReviewEdit
				formData={formData}
				setFormData={setFormData}
				editReview={editReview}
			/>
		);
	}
	let deleteButton;
	let editButton;

	if (currentUser.id === user.id) {
		deleteButton = (
			<button
				className='edit'
				onClick={() => deleteReview(review.id, position)}
			>
				Delete
			</button>
		);
		editButton = (
			<button onClick={button} className='edit'>
				Edit
			</button>
		);
	}
	return (
		<div className='card'>
			<div className='deep-dark card-body'>
				<div className='show-name'>
					<h2 className={text}>{user.first_name}</h2>
					{textField}
					{editButton}
					{deleteButton}
					{/* <button onClick={likeFunction}> Upvote {like}</button> */}
				</div>
			</div>
		</div>
	);
};

export default ReviewTiles;
