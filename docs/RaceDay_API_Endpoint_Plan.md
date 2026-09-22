# RaceDay API Endpoint Plan

## Overview

The RaceDay API will allow the web application to communicate with the RaceDay database.

The system has two main user roles:

- **Organiser** – can create and manage events, categories, enrolments and participant results.
- **Participant** – can create an account, view events, enter an event, view their enrolments and view their results.

This document describes the API endpoints that will be implemented for the RaceDay system.

---

## 1. Authentication

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | `/api/auth/register` | Creates a new participant account. | Public | FirstName, LastName, Email, Password | 201 Created with user information |
| POST | `/api/auth/login` | Logs a user into RaceDay. | Public | Email, Password | 200 OK with authentication token and user information |

---

## 2. User Profile

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | `/api/users/profile` | Gets the logged-in user's profile. | Organiser / Participant | None | 200 OK with user profile |
| PUT | `/api/users/profile` | Updates the logged-in user's profile. | Organiser / Participant | FirstName, LastName, Email | 200 OK with updated profile |

---

## 3. Events

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | `/api/events` | Gets all available events. | Organiser / Participant | None | 200 OK with event list |
| GET | `/api/events/{id}` | Gets the details of one event. | Organiser / Participant | None | 200 OK with event details |
| POST | `/api/events` | Creates a new event. | Organiser | EventName, Description, EventDate, Location, EventType, RegistrationDeadline | 201 Created with new event |
| PUT | `/api/events/{id}` | Updates an existing event. | Organiser | EventName, Description, EventDate, Location, EventType, RegistrationDeadline | 200 OK with updated event |
| DELETE | `/api/events/{id}` | Deletes an event. | Organiser | None | 204 No Content |

---

## 4. Categories

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | `/api/events/{eventId}/categories` | Gets all categories for an event. | Organiser / Participant | None | 200 OK with category list |
| GET | `/api/categories/{id}` | Gets one category. | Organiser / Participant | None | 200 OK with category details |
| POST | `/api/events/{eventId}/categories` | Creates a category for an event. | Organiser | CategoryName, DistanceKm, EntryFee, MaxParticipants | 201 Created with new category |
| PUT | `/api/categories/{id}` | Updates an event category. | Organiser | CategoryName, DistanceKm, EntryFee, MaxParticipants | 200 OK with updated category |
| DELETE | `/api/categories/{id}` | Deletes a category. | Organiser | None | 204 No Content |

---

## 5. Event Enrolments

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | `/api/enrolments` | Enters the logged-in participant into an event category. | Participant | EventID, CategoryID | 201 Created with enrolment information |
| GET | `/api/enrolments/my` | Gets all enrolments belonging to the logged-in participant. | Participant | None | 200 OK with participant enrolments |
| GET | `/api/events/{eventId}/enrolments` | Gets all participants enrolled in an event. | Organiser | None | 200 OK with event enrolments |
| PUT | `/api/enrolments/{id}` | Updates the status or race number of an enrolment. | Organiser | Status, RaceNumber | 200 OK with updated enrolment |
| DELETE | `/api/enrolments/{id}` | Cancels/removes an enrolment. | Participant / Organiser | None | 204 No Content |

---

## 6. Results

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | `/api/results` | Records a result for a participant's enrolment. | Organiser | EnrolmentID, FinishTime, OverallPosition, CategoryPosition | 201 Created with result |
| GET | `/api/results/my` | Gets the logged-in participant's results. | Participant | None | 200 OK with participant results |
| GET | `/api/events/{eventId}/results` | Gets results for an event. | Organiser / Participant | None | 200 OK with event results |
| PUT | `/api/results/{id}` | Updates an existing result. | Organiser | FinishTime, OverallPosition, CategoryPosition | 200 OK with updated result |
| DELETE | `/api/results/{id}` | Deletes an incorrect result. | Organiser | None | 204 No Content |

---

## Role-Based Access

RaceDay will use role-based access control to protect API endpoints.

Participants will be able to browse events, enter event categories, view their own enrolments and view their own results.

Organisers will be able to create and manage events, manage event categories, view event enrolments and record or update participant results.

Access to protected operations will be checked by the API before the requested action is allowed.