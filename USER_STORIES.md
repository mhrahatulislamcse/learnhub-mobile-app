# LearnHub — User Stories

## Overview
LearnHub is an educational and learning resource discovery application built with Flutter and Firebase. The following nine user stories define the core requirements and expected benefits across all application modules as specified in the project rubric.

---

### User Story 1: Registration
**As a** new learner,  
**I want to** register for a personal LearnHub account using my username, email address, and a secure password,  
**so that** I can securely access the learning platform and have my educational data safely associated with my profile.

* **Acceptance Criteria:**
  - The registration form validates non-empty username, RFC 5322-compliant email format, and password length (minimum 6 characters).
  - An account is provisioned in Firebase Authentication and a corresponding user profile document is initialized in Cloud Firestore under `users/{uid}`.
  - Descriptive, human-readable errors are displayed for weak passwords, malformed emails, or duplicate email registrations.
  - The user is seamlessly navigated to the home screen upon successful registration.

---

### User Story 2: Login & Authentication
**As a** registered student or instructor,  
**I want to** log in with my verified email and password credentials,  
**so that** I can authenticate my identity, restore my personal learning session, and keep my account protected.

* **Acceptance Criteria:**
  - Login form validates email format and password presence.
  - Authentication is handled securely via Firebase Authentication with session persistence.
  - Informative error feedback is presented for incorrect credentials, disabled accounts, or network drops.
  - Route guards protect authenticated features while offering an optional guest mode for exploratory browsing.

---

### User Story 3: Home Dashboard & Discovery
**As an** active learner,  
**I want to** browse a curated home dashboard featuring educational books, search tools, and resource categories,  
**so that** I can effortlessly explore new topics, discover recommended reading materials, and stay engaged with my learning goals.

* **Acceptance Criteria:**
  - Home dashboard presents a welcome banner, quick search bar, category chips, and book recommendation cards.
  - Features real-time state management displaying loading skeletons, content cards, and empty state fallbacks.
  - Provides quick-action navigation to book details, favorites, notifications, and settings menu.

---

### User Story 4: Book Details
**As an** inquisitive student,  
**I want to** open and read comprehensive details for any selected book—including full title, author names, cover imagery, publication year, subjects, and synopsis,  
**so that** I can evaluate whether the resource aligns with my study plan before committing to it.

* **Acceptance Criteria:**
  - Book details screen renders high-resolution cover graphics with graceful fallback placeholders for missing imagery.
  - Displays structured metadata including author, first publish year, edition count, language, and subject tags.
  - Offers an interactive Favorite toggle button with immediate visual feedback.

---

### User Story 5: Favorites Management
**As an** avid reader,  
**I want to** bookmark my favorite books into a dedicated Favorites collection and remove them whenever desired,  
**so that** I can easily maintain an accessible personal library of high-priority learning materials.

* **Acceptance Criteria:**
  - Bookmarking or un-bookmarking a book immediately updates the Favorites state across the application.
  - The Favorites screen displays the list of saved books with cover, title, author, and quick removal actions.
  - If no books are saved, an informative and visually appealing empty-state widget is presented.

---

### User Story 6: Local Data Persistence
**As an** on-the-go user,  
**I want** my favorited books, reading bookmarks, and application preferences to be saved locally using SharedPreferences,  
**so that** my saved resources and custom settings persist reliably even when I close or restart the application.

* **Acceptance Criteria:**
  - Favorite book IDs and metadata are persisted to local device storage using `SharedPreferences`.
  - Stored bookmarks are seamlessly restored on application launch and synchronized with Firestore when online.
  - Local cache operations are performed asynchronously without freezing the UI thread.

---

### User Story 7: External API Integration
**As a** researcher,  
**I want** the application to fetch live, real-world educational book data directly from the Open Library REST API,  
**so that** I can search through millions of global academic books and reference texts in real time.

* **Acceptance Criteria:**
  - Seamless integration with the Open Library Search API (`https://openlibrary.org/search.json?q={query}`).
  - Strong JSON parsing converting responses into immutable `BookModel` Dart objects.
  - Proper handling of network latency, empty queries, rate limiting, and connection timeouts with retry options.

---

### User Story 8: Settings Menu & Personalization
**As a** user who values customization,  
**I want to** access a dedicated settings screen through an accessible menu icon,  
**so that** I can toggle between light and dark themes, view my profile, review privacy policies, and manage my session.

* **Acceptance Criteria:**
  - Prominent settings menu icon accessible from the primary navigation bar.
  - Comprehensive settings screen with persistent Theme mode toggle (System, Light, Dark).
  - Navigation links to user profile, notification configurations, app version info, and secure logout.

---

### User Story 9: Scheduled & Local Notifications
**As a** busy learner,  
**I want to** receive timely local notifications and scheduled study reminders on my Android device,  
**so that** I can stay disciplined with my daily reading routine and never miss critical updates.

* **Acceptance Criteria:**
  - Integration with `flutter_local_notifications` featuring dedicated notification channel configuration.
  - Runtime notification permission requesting conforming to Android 13+ (`POST_NOTIFICATIONS`).
  - Ability to trigger an immediate test notification as well as schedule daily/interval reading reminders.
  - Tapping a notification opens the application smoothly to the relevant content.

