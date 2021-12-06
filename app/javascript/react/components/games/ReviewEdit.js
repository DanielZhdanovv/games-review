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

        <label htmlFor="body" className="ratings">Review</label>
        <textarea 
          type="text"
          name="body"
          id="body"
          onChange={handleChange}
          value={formData.body}
        />
        <input 
        className="button"
        type="submit" />
      </form>
    </div>
  )
}
export default ReviewEdit