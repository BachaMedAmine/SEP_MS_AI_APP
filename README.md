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

