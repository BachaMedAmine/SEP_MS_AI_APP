# MS-PIM-AI: Multiple Sclerosis Relapse Prediction

MS-PIM-AI is a health monitoring and prediction system for Multiple Sclerosis (MS) patients. It uses a Flutter frontend to collect health metrics (heart rate, HRV, sleep score, steps, temperature, SpO₂, and stress level) and a Flask backend with a pre-trained machine learning model to predict the likelihood of an MS relapse. The app displays predictions via notifications and supports push notifications using Firebase Cloud Messaging.

## Project Structure

- `frontend/`: Flutter app for collecting health data and displaying predictions.
- `backend/`: Flask server with a pre-trained ML model for predicting MS relapse.

## Features

- Collects health metrics from the user.
- Sends data to a Flask backend for prediction.
- Displays prediction results (e.g., "Stable condition", "Possible early signs", "High chance of relapse") with confidence scores.
- Supports local notifications and Firebase push notifications.
- User-friendly interface with animated health metric cards.

## Prerequisites

### General
- Git
- A code editor (e.g., VS Code, Android Studio)

### Frontend (Flutter)
- Flutter SDK (version 3.0.0 or later)
- Dart
- Xcode (for iOS development on macOS)
- Android Studio (for Android development)
- A Firebase project (for push notifications)

### Backend (Flask)
- Python 3.8 or later
- pip (Python package manager)
python -m venv venv
source venv/bin/activate

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/<your-username>/ms-pim-ai.git
cd ms-pim-ai


2. Set Up the Backend (Flask AI Server)
cd backend
-Create a Virtual Environment:
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

3:
Install Dependencies:
pip install -r requirements.txt

4:Run the Flask Server:
python server.py


***Set Up the Frontend (Flutter App):
cd frontend

2:Install Flutter Dependencies:
flutter pub get

Set Up Firebase for Push Notifications:
Create a Firebase project in the Firebase Console.
Add an iOS app to your Firebase project:
Use the bundle ID com.exampleorwhatever.msPimAi (or your own if you’ve changed it).
Download the GoogleService-Info.plist file and place it in frontend/ios/Runner/.
Add an Android app to your Firebase project (optional, if targeting Android):
Use the package name com.bechamedamine.msPimAi.
Download the google-services.json file and place it in frontend/android/app/.
Follow the Firebase setup instructions for Flutter:
Add Firebase dependencies to frontend/pubspec.yaml (already included in the project):

firebase_core: ^3.4.0
firebase_messaging: ^15.1.0


For iOS, ensure Push Notifications and Background Modes (with "Remote notifications") are enabled in Xcode (frontend/ios/Runner.xcodeproj).
For iOS, upload an APNS certificate or APNS Authentication Key to Firebase (Cloud Messaging > APNs Certificates).

NOW RUN IT


Contributing
We welcome contributions to make MS-PIM-AI more efficient and robust! Here are some areas where you can help:

Frontend (Flutter):
Improve the UI/UX of the health dashboard.
Add real-time health data collection (e.g., from wearables like Apple Watch).
Optimize performance for large datasets or frequent predictions.
Enhance error handling for network failures.
Backend (Flask AI Server):
Improve the machine learning model (relapse_predictor.pkl) by retraining with more data or using a different algorithm.
Add feature scaling or preprocessing to ensure consistent predictions.
Implement authentication for the /predict endpoint.
Deploy the Flask server with a production-ready setup (e.g., Gunicorn + Nginx, HTTPS).
General:
Add support for Android push notifications.
Implement a backend endpoint to store FCM tokens and send push notifications when a high relapse risk is detected.
Add unit tests for both the frontend and backend.
To contribute:

Fork the repository.
Create a new branch (git checkout -b feature/your-feature).
Make your changes and commit them (git commit -m "Add your feature").
Push to your fork (git push origin feature/your-feature).
Open a pull request with a description of your changes.