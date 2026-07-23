# Surglogs | iOS Coding Assignment — StayFinder

## Overview

Welcome to the _Surglogs_ iOS coding assignment. You will build **StayFinder** — a
simplified accommodation browsing app (think _Airbnb_) that lets users browse available
stays and view their details.

This repository contains a compilable starter _iOS_ project with a single welcome screen.
Your task is to replace it with the features described below.

## Time expectation

**~90 minutes** of focused work. We respect your time — do not over-invest. If you run out
of time, document what you would do next in a `NOTES.md` file.

## Technical requirements

| Requirement    | Value                                                     |
| -------------- | --------------------------------------------------------- |
| Language       | _Swift_ 5.9+                                              |
| UI framework   | _SwiftUI_                                                 |
| Minimum target | iOS 17.0                                                  |
| IDE            | _Xcode_ 15+                                               |
| Backend        | _Supabase_ (set up your own free project)                 |
| Architecture   | Your choice — justify it                                  |
| AI tools       | **Required** — use whatever helps you ship quality code   |

## Backend — Supabase

Set up your own _Supabase_ project at
[supabase.com](https://supabase.com/) (free tier is sufficient). You are
responsible for:

1. Creating the project
2. Designing the database schema to support the features below
3. Seeding it with sample data (at least 5–10 accommodations with reviews)
4. Integrating the _Supabase_ iOS SDK into the project

Document your schema design and any setup steps in the `README.md`.

## Your tasks

### 1) Accommodation list screen

Build a scrollable list of available accommodations. Each item should display:

- Accommodation photo (first image from `image_urls`)
- Title
- Location (city, country)
- Price per night
- Rating

**Requirements:**

- Fetch data from _Supabase_
- Handle loading, error and empty states gracefully
- Support pull-to-refresh
- Implement basic filtering by price range (min/max)

### 2) Accommodation detail screen

When a user taps an accommodation, navigate to a detail view showing:

- Photo gallery (horizontal scroll of all images)
- Title, location, rating and price
- Full description
- Amenities list
- Host information (name, avatar)
- Number of bedrooms, bathrooms and max guests
- Reviews section

**Requirements:**

- Clean navigation from list to detail
- Async image loading with placeholder/loading states
- Reviews sorted by newest first

## Wireframes

Below are minimal wireframes indicating the expected information hierarchy. Visual
design and polish are up to you — we care about usability, not pixel-perfection.

```text
┌─────────────────────────────┐    ┌─────────────────────────────┐
│  StayFinder                 │    │  ← Back                     │
├─────────────────────────────┤    ├─────────────────────────────┤
│ ┌─────────────────────────┐ │    │ ┌─────────────────────────┐ │
│ │  [Photo]                │ │    │ │ [  Photo Gallery  >>>]  │ │
│ │  Cozy Loft in Prague    │ │    │ └─────────────────────────┘ │
│ │  Prague, Czechia        │ │    │                             │
│ │  €85/night    ★ 4.7     │ │    │  Cozy Loft in Prague        │
│ └─────────────────────────┘ │    │  Prague, Czechia  ★ 4.7     │
│ ┌─────────────────────────┐ │    │  €85 / night                │
│ │  [Photo]                │ │    │                             │
│ │  Mountain Cabin         │ │    │  ─────────────────────────  │
│ │  Tatras, Slovakia       │ │    │  Description text...        │
│ │  €120/night   ★ 4.9     │ │    │                             │
│ └─────────────────────────┘ │    │  ─────────────────────────  │
│ ┌─────────────────────────┐ │    │  Amenities: WiFi, Kitchen.. │
│ │  [Photo]                │ │    │                             │
│ │  ...                    │ │    │  ─────────────────────────  │
│ └─────────────────────────┘ │    │  🧑 Host: Jan K.            │
│                             │    │  🛏 2 bed · 🛁 1 bath · 👥 4 │
│ ───── Filter: €50–€200 ───  │    │                             │
└─────────────────────────────┘    │  ─────────────────────────  │
         LIST SCREEN               │  Reviews (12)               │
                                   │  ★★★★★ "Amazing place..."   │
                                   │  ★★★★☆ "Great location..."  │
                                   └─────────────────────────────┘
                                            DETAIL SCREEN
```

## Submission

1. Push the **entire repository** (including its full commit history) to a **public
   GitHub repository** and send the link to your recruiter contact
2. Ensure the project **compiles and runs** on the iOS Simulator
3. Update `README.md` with:
   - _Supabase_ setup instructions and schema design
   - Architecture decisions and reasoning
   - What you would improve given more time
4. Optionally add notes to `NOTES.md` — anything else you want to share

> **Note:** We review your commit history as part of the assessment — it helps us
> understand how you break down work. Use meaningful commits as you normally would.

## Questions?

If anything is unclear, reach out to your recruiter contact. We'd rather you ask than
guess — that's a signal we value.

Good luck! 🚀
