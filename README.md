# StayFinder

A simplified accommodation browsing app built for the Surglogs iOS coding assignment.

## Backend — Supabase

The backend is a Supabase project with three tables: hosts, accommodations, and reviews. An accommodation belongs to a host, and a review belongs to an accommodation. That's the whole model. The app only ever reads, so I kept the schema flat and let Postgres handle the joining.

The detail screen is the one place that needs everything at once, so it pulls the accommodation, its host, and all its reviews in a single request using Supabase's embedding (`accommodations, hosts(*), reviews(*)`). That only works because of the two foreign keys below. Without them PostgREST has nothing to resolve the join against.

```sql
CREATE TABLE public.hosts (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at timestamptz DEFAULT now(),
    name       text NOT NULL,
    avatar_url text
);

CREATE TABLE public.accommodations (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at      timestamptz DEFAULT now(),
    title           text    NOT NULL,
    description     text    NOT NULL,
    city            text    NOT NULL,
    country         text    NOT NULL,
    price_per_night numeric NOT NULL,
    rating          numeric DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5.0),
    image_urls      text[]  NOT NULL DEFAULT '{}',
    amenities       text[]  NOT NULL DEFAULT '{}',
    bedrooms        integer NOT NULL DEFAULT 1,
    bathrooms       integer NOT NULL DEFAULT 1,
    max_guests      integer NOT NULL DEFAULT 1,
    host_id         uuid    NOT NULL REFERENCES public.hosts(id)
);

CREATE TABLE public.reviews (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at        timestamptz DEFAULT now(),
    accommodation_id  uuid    NOT NULL REFERENCES public.accommodations(id),
    author_name       text    NOT NULL,
    author_avatar_url text,
    rating            integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment           text    NOT NULL
);

CREATE INDEX idx_accommodations_host   ON public.accommodations(host_id);
CREATE INDEX idx_reviews_accommodation ON public.reviews(accommodation_id);
```

The app already points at a live, seeded project, so it runs on the Simulator with no setup. To stand up your own: create a free Supabase project, run the SQL above in the SQL Editor, seed a few hosts and then accommodations and then reviews (in that order, because of the foreign keys), and put your project URL and anon key into `SupabaseConfig` in `StayFinder/Sources/Data/Remote/SupabaseClient.swift`. The Swift SDK is already wired in through SPM.

The anon key is committed intentionally so the project runs without setup; it's a publishable client key protected by read-only RLS. In production this would move to a gitignored xcconfig.

## Clean Architecture

I split the app into three layers (Domain, Data, and Presentation) because I wanted every meaningful behavior to be testable without spinning up a network or a UI. That goal shapes every boundary in the codebase.

The Domain layer knows nothing about Supabase. It only knows about protocols like `AccommodationRepositoryProtocol` and `FetchAccommodationsUseCaseProtocol`, so a test can hand in a fake and the layer under test never notices the difference.

The Data layer owns everything tied to the wire format: snake_case decoding, URL validation, Supabase join flattening, error mapping. Errors get translated to `AccommodationError` at the repository boundary, so the presentation layer never sees a Supabase-specific type. If I swap the backend tomorrow, nothing above the repository changes.

The payoff is that I can test DTO mapping, error translation, use case logic, ViewModel state, and navigation as plain unit tests, with no shared state between runs.

The cost is that the use cases are thin right now. Most of them just call through to the repository. But the boundaries are already earning their keep in the test suite, and they leave room to grow without a big refactor later.

## Coordinator Pattern

I went with Coordinator + MVVM because I didn't want views making navigation decisions. Once a view knows where to go next, it gets hard to test and hard to reuse. So I split the responsibilities:

- The view just says "this row was tapped"
- The view model handles state and calls a closure when something happens
- The coordinator catches that and pushes the right screen
- The router holds a list of screens. Add one and SwiftUI pushes it; remove one and SwiftUI goes back. That's the whole navigation system.

The part I like most is that routes are a Swift enum. Add a new screen and forget to handle it, and you get a compile error instead of a runtime crash.

Of the common SwiftUI navigation approaches, this one and TCA give you the best foundation for testable, scalable navigation. The difference is that TCA asks you to adopt its full architecture. The coordinator approach gets you most of the same navigation benefits without locking the rest of the app into one pattern.

The trade-off: adding a screen means touching three files, so there's more work upfront. In return, every view model has zero SwiftUI imports and can be tested without any UI.

Given more time, I would:

- Make `AppCoordinator` testable through a protocol. Every layer has one except the coordinator right now, which is why views can't be tested in isolation.
- Split into child coordinators per flow if the app grew to multiple features, rather than growing one big `AppRoute` enum.
- Extend the coordinator to handle sheets and full-screen covers, not only push navigation.
- Add a `TabCoordinator` above the child coordinators if a tab bar was needed, to own tab state and handle cross-tab navigation.

## Dependency Injection (Manual Composition Root with Constructor Injection)

I wired up the dependencies by hand instead of reaching for a DI framework. Every object receives what it needs through its initializer, so missing dependencies are caught at compile time, tests need no special tooling, and the core app carries zero third-party DI dependencies.

`AppCompositionRoot` is the one place where all real objects are created and connected. Everything the app needs, including the network client, is built here and handed out. Constructor injection means ViewModels and Use Cases receive their dependencies explicitly through their initializers, so nothing is hidden and nothing resolves itself. Each test spins up its own fresh `AppCompositionRoot` with a fake data source, so tests never share state and can't interfere with each other.

That last point is the real win over a DI container backed by a shared, mutable registry. There's no global state to reset between runs, which rules out a whole category of test pollution.

The downside is that every new dependency has to be added by hand: built in `AppCompositionRoot`, then passed into whatever needs it. Nothing is automatic. With 5 dependencies today that's quick and easy to follow, but as the app grows the manual wiring piles up and a framework starts to look worthwhile.

Given more time, I would:

- Add a protocol for `AppCompositionRoot` so UI tests can swap the entire real setup (network, database) for a fake one without touching view code.
- Extract a `ViewModelFactoryProtocol` for `ViewModelFactory` so the coordinator depends on an abstraction instead of a concrete type, which removes the mutable closure properties the tests currently need.
- Introduce a DI framework like Factory if the manual wiring gets too repetitive. The structure stays the same; Factory would just generate the boilerplate instead of me writing it.

## Approach & Reflection

The assignment said not to over-invest, and I did anyway, on purpose. I wanted to show clear architectural separation rather than a polished UI, so I spent most of my time on the architecture, the testability, and the boundaries between layers, and as little as I could on the views.

The UI was scaffolded with AI assistance to move quickly, which is why it's missing things a production view would have: extracted subviews, localization, loading placeholders. Those didn't feel like the right place to spend time given what I was trying to demonstrate.

If I had more time:

- Localization
- Loading placeholders / skeleton screens
- Better-designed API objects, with more thoughtful data modeling on the Supabase side from the start
- Add map location
- Generic `LoadingState`
- Resolve hardcoded currency
- Move Kingfisher image handling into its own function so the library isn't imported inside the views
