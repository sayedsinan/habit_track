# Habit Track

A comprehensive habit tracking application featuring a backend built with NestJS and a mobile application built with Flutter.

## Project Structure

The project is structured as a monorepo containing both the backend and the mobile app:

```bash
habit_track/
├── apps/
│   ├── backend/       # NestJS backend application
│   └── mobile_app/    # Flutter mobile application
```

## Backend System

The backend is built using the robust **NestJS** framework for Node.js, providing a scalable and easily testable architecture.

### Tech Stack
- Framework: [NestJS](https://nestjs.com/) (Node.js)
- Language: TypeScript
- Node Version: Node.js 18+ recommended

### Running the Backend Local Server

1. Navigate to the backend directory:
   ```bash
   cd apps/backend
   ```
2. Install the necessary dependencies:
   ```bash
   npm install
   ```
3. Start the development server:
   ```bash
   # Development mode
   npm run dev
   
   # Or using Nest's default start scripts:
   npm run start:dev
   ```

## Mobile App

The mobile application is a cross-platform client built using **Flutter**.

### Tech Stack
- Framework: [Flutter](https://flutter.dev/)
- Language: Dart
- Target Platforms: Android, iOS, Web, Windows, macOS, Linux (depending on your Flutter setup requirements).

### Running the Mobile App Locally

1. Navigate to the mobile app directory:
   ```bash
   cd apps/mobile_app
   ```
2. Fetch required dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Contributing

1. Ensure you have the latest versions of Flutter, Dart, Node.js, and npm installed.
2. Follow the standard code styling options defined in the respective directories (`.prettierrc` and ESLint configuration in NestJS, and `analysis_options.yaml` in Flutter).
