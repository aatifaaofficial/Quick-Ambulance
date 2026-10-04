# 🚑 Quick Ambulance

### Emergency Ambulance Booking & Tracking Mobile Application

**Quick Ambulance** is a Flutter-based emergency ambulance booking and tracking application designed to help patients quickly find and request nearby ambulances during emergency situations. The application connects patients, ambulance drivers, and hospitals through a simple and user-friendly platform.

> **Fast Response • Easy Booking • Live Tracking • Emergency Support**

---

## 📱 Project Overview

During medical emergencies, finding an available ambulance quickly can be difficult. Patients may not know which ambulance is nearby, whether it is available, or which hospital should be selected.

**Quick Ambulance** provides a digital solution where users can:

* 🚑 Find nearby available ambulances
* 📍 Select pickup location
* 🏥 Select destination hospital
* 📲 Request an ambulance
* 🗺️ Track ambulance location
* 📞 Contact the ambulance driver
* 📋 View booking history
* 🔔 Receive booking notifications
* 👤 Manage personal profile

The application also provides separate functionality for ambulance drivers and administrators.

---

## 🎯 Objectives

The main objectives of Quick Ambulance are:

* Reduce the time required to find an ambulance.
* Make ambulance booking easier and faster.
* Help patients locate nearby available ambulances.
* Provide ambulance location tracking.
* Connect patients with ambulance drivers.
* Help users find nearby hospitals.
* Improve emergency transportation management.
* Provide a centralized ambulance booking system.

---

## 👥 User Roles

The application supports three major user roles:

### 👤 Patient / User

Patients can:

* Register and login
* View available ambulances
* Request an ambulance
* Select pickup location
* Select destination hospital
* Track ambulance
* Contact driver
* View booking status
* View booking history
* Receive notifications
* Manage profile

### 🚑 Ambulance Driver

Drivers can:

* Register and login
* Manage availability
* Receive ambulance requests
* Accept or reject requests
* View patient information
* View pickup location
* View destination hospital
* Update trip status
* Share current location
* Complete trips
* View trip history

### 🛠️ Administrator

Administrators can:

* View users
* Manage ambulance drivers
* Manage ambulances
* Manage hospitals
* Monitor bookings
* View booking status
* Manage application data
* Monitor overall system activity

---

## ✨ Key Features

### 🚨 Emergency Ambulance Booking

Users can quickly request an ambulance by providing pickup and destination information.

### 📍 Location Selection

Users can select their current/pickup location and destination hospital.

### 🚑 Nearby Ambulances

The application displays nearby available ambulances with driver and distance information.

### 🗺️ Live Tracking

Users can track the ambulance during an active booking.

### 📞 Driver Contact

Users can contact the assigned ambulance driver when necessary.

### 🏥 Nearby Hospitals

Users can search and view nearby hospitals for emergency treatment.

### 📋 Booking History

Users can view previous ambulance requests and their booking details.

### 🔔 Notifications

Users and drivers can receive updates related to ambulance requests and booking status.

### 👤 Profile Management

Users can view and update their personal information.

### 📊 Driver Dashboard

Drivers can manage their availability and handle incoming ambulance requests.

### 🛠️ Admin Dashboard

Administrators can monitor users, drivers, ambulances, hospitals, and bookings.

---

## 🔄 Ambulance Booking Flow

```text
User Opens App
       ↓
Login / Register
       ↓
Select Pickup Location
       ↓
Select Destination Hospital
       ↓
View Nearby Ambulances
       ↓
Request Ambulance
       ↓
Driver Receives Request
       ↓
Driver Accepts Request
       ↓
Driver Goes to Pickup Location
       ↓
Patient Picked Up
       ↓
Travel to Hospital
       ↓
Trip Completed
       ↓
Booking History Updated
```

---

## 📌 Booking Status

The application supports different booking states:

```text
Pending
   ↓
Accepted
   ↓
Driver On Way
   ↓
Arrived
   ↓
Patient Picked
   ↓
Going to Hospital
   ↓
Completed
```

A booking can also be:

```text
Cancelled
Rejected
```

---

## 🏗️ Technology Stack

| Technology               | Purpose                              |
| ------------------------ | ------------------------------------ |
| Flutter                  | Mobile & Web Application Development |
| Dart                     | Programming Language                 |
| Firebase Authentication  | User Authentication                  |
| Cloud Firestore          | Database                             |
| Firebase Storage         | File Storage                         |
| Firebase Cloud Messaging | Notifications                        |
| Google Maps              | Maps & Location                      |
| Geolocator               | Location Services                    |
| Provider / Riverpod      | State Management                     |
| Material 3               | User Interface                       |

---

## 📂 Project Structure

```text
lib/
│
├── main.dart
│
├── app/
│   ├── theme/
│   ├── routes/
│   └── app.dart
│
├── models/
│   ├── user_model.dart
│   ├── driver_model.dart
│   ├── ambulance_model.dart
│   ├── booking_model.dart
│   ├── hospital_model.dart
│   └── notification_model.dart
│
├── providers/
│   ├── auth_provider.dart
│   ├── booking_provider.dart
│   ├── location_provider.dart
│   ├── driver_provider.dart
│   └── hospital_provider.dart
│
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── booking_service.dart
│   ├── location_service.dart
│   ├── hospital_service.dart
│   └── notification_service.dart
│
├── screens/
│   ├── auth/
│   ├── patient/
│   ├── driver/
│   ├── admin/
│   └── hospital/
│
├── widgets/
│
└── utils/
```

---

## 🗄️ Database Structure

The application is designed to use Firebase Cloud Firestore.

### Users

```text
users
 └── userId
      ├── name
      ├── email
      ├── phone
      ├── age
      ├── role
      └── profileImage
```

### Drivers

```text
drivers
 └── driverId
      ├── name
      ├── phone
      ├── licenseNumber
      ├── ambulanceId
      ├── isAvailable
      └── currentLocation
```

### Ambulances

```text
ambulances
 └── ambulanceId
      ├── ambulanceNumber
      ├── driverId
      ├── type
      ├── status
      └── location
```

### Bookings

```text
bookings
 └── bookingId
      ├── userId
      ├── driverId
      ├── ambulanceId
      ├── pickupLocation
      ├── destination
      ├── hospitalId
      ├── status
      ├── createdAt
      └── completedAt
```

### Hospitals

```text
hospitals
 └── hospitalId
      ├── name
      ├── address
      ├── phone
      ├── latitude
      ├── longitude
      └── emergencyAvailable
```

---

## 🎨 UI & Design

Quick Ambulance uses a modern medical emergency-focused interface.

### Design Principles

* 🚑 Emergency-focused UI
* 🔴 Red emergency actions
* ⚪ Clean white background
* 🔵 Medical blue accents
* 📱 Responsive layout
* 🧩 Reusable components
* 🎯 Simple navigation
* 👆 Large and easy-to-use buttons
* 📍 Location-focused interface

---

## 🧪 Demo Data

For demonstration purposes, the application can use sample data.

### Patient

```text
Name: Aatifaa Jyoti
Age: 22
Phone: 01602381861
```

### Demo Ambulance

```text
Ambulance: #102
Driver: Rahim Ahmed
Distance: 1.2 km
Status: Available
```

### Demo Hospital

```text
Hospital: City Hospital
Distance: 2.5 km
```

> Demo data is intended for testing and presentation purposes.

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/aatifaaofficial/quick-ambulance.git
```

### 2. Open the Project

```bash
cd quick-ambulance
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Enable Flutter Platforms

If web support is not already available:

```bash
flutter create .
```

### 5. Run on Chrome

```bash
flutter run -d chrome
```

### 6. Run on Android

Connect an Android device or start an Android emulator and run:

```bash
flutter run
```

---

## 🌐 Running the App in Chrome

Quick Ambulance supports Flutter Web for development and demonstration.

```bash
flutter clean
flutter pub get
flutter create .
flutter run -d chrome
```

---

## 🔐 Firebase Integration

For production use, Firebase can be configured for:

* Firebase Authentication
* Cloud Firestore
* Firebase Storage
* Firebase Cloud Messaging
* Secure database rules

Firebase configuration files should be added according to the FlutterFire setup.

---

## 🔒 Security

The application is designed with security considerations such as:

* User authentication
* Role-based access
* Secure Firestore rules
* Protected user information
* Restricted admin access
* Secure booking data
* Firebase authentication

---

## 📸 Screenshots

Add your application screenshots here.

Example:

```markdown
## 📸 Screenshots

### 🏠 Home Screen

![Home Screen](screenshots/home.png)

### 🚑 Ambulance Booking

![Booking Screen](screenshots/booking.png)

### 🗺️ Live Tracking

![Tracking Screen](screenshots/tracking.png)

### 🏥 Nearby Hospitals

![Hospital Screen](screenshots/hospital.png)
```

Create a folder in your repository:

```text
screenshots/
```

Then put your screenshots inside it.

---

## 📈 Future Improvements

Future versions of Quick Ambulance may include:

* 🤖 AI-based emergency assistance
* 🏥 Hospital bed availability
* 💳 Online payment
* ⭐ Driver rating and review
* 📞 Emergency call integration
* 🗺️ Advanced route optimization
* 📍 Real-time GPS tracking
* 🔔 Advanced emergency notifications
* 🌐 Multi-language support
* ☁️ Cloud synchronization
* 📊 Advanced admin analytics
* 🧑‍⚕️ Doctor/hospital communication

---

## ⚠️ Limitations

The current project may require additional configuration for full production functionality, including:

* Google Maps API
* Firebase configuration
* Real-time GPS services
* Firebase Cloud Messaging
* Production authentication
* Secure backend deployment

The demo mode can be used for presentation and development without complete backend configuration.

---

## 🎓 Academic Project

**Project Name:** Quick Ambulance
**Project Type:** Flutter Mobile & Web Application
**Category:** Healthcare / Emergency Services
**Platform:** Flutter
**Language:** Dart

---

## 👩‍💻 Developer

**Aatifaa Jyoti**

Developed as a Flutter-based academic project focused on improving emergency ambulance booking and transportation management.

---

## 📄 License

This project is developed for educational and academic purposes.

---

## ⭐ Support

If you find this project useful, please consider giving the repository a ⭐ on GitHub.

---

### 🚑 Quick Ambulance

**Fast Response. Easy Booking. Better Emergency Care.**

