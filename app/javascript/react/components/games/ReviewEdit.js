import React, { useState } from "react";

const ReviewEdit = (props) => {
  const { formData, setFormData } = props

  const handleChange = (event) => {
    setFormData({
      ...formData,
      [event.currentTarget.name]: event.currentTarget.value
    })
  }

  const handleSubmit = (event) => {
    event.preventDefault()
    props.editReview(formData)
  }

  return (
    <div className="cell small-8">
      <form onSubmit={handleSubmit}>

        <label htmlFor="body" className="edit-text-review"> <strong>Edit Review</strong></label>
        <textarea
          className="edit-form" 
          type="text"
          name="body"
          id="body"
          onChange={handleChange}
        />
        <input 
        className="edit-button"
        type="submit" />
      </form>
    </div>
  )
}
export default ReviewEdit