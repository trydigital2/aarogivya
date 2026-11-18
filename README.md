# Aarogivya🏥 

> **Your Health, Our Priority.**  
> A modern, comprehensive Flutter healthcare application for doctor appointment scheduling, pharmacy management, digital health records, and telemedicine services.

---

## ✨ Features

### 🩺 Doctor Consultations & Appointments
- **Find Doctors**: Search by doctor name, medical specialty (Cardiology, Pediatrics, Dermatology, General Physician, Orthopedics), or city.
- **Doctor Profiles**: View qualifications, years of experience, clinic details, ratings, review counts, consultation fees, and languages spoken.
- **Smart Scheduling**: Browse available time slots by date and book appointments instantly.
- **Appointment Management**: Track upcoming visits, reschedule, or cancel anytime with live status updates.

### 💊 Pharmacy & Medicine Store
- **Medicine Catalog**: Search across diverse categories including Pain Relief, Antibiotics, Allergy, Digestive, and Supplements.
- **Prescription Badges**: Clear indicators for over-the-counter vs. prescription-required medicines with dosage details.
- **Cart & Checkout**: Real-time quantity adjustment, total calculation, prescription attachment, and one-tap order placement.
- **Order Tracking**: Keep track of order history and delivery statuses.

### 📋 Digital Health Records & Vitals
- **Medical Records**: View lab reports, doctor prescriptions, notes, and verification statuses.
- **Vitals Tracking**: Log and monitor health measurements such as Blood Pressure (mmHg) and Blood Sugar (mg/dL).
- **Patient Profile**: Manage blood group, known allergies, medical history, and emergency contact details.

### 🔔 In-App Notifications
- Real-time updates for appointment reminders, pharmacy delivery status, and health tips.

### 👥 Dual Role Experience
- Seamless switching and support for both **Patient** and **Doctor** roles with dedicated dashboards and bottom-navigation shells.

---

## 🛠️ Architecture & Tech Stack

The project follows a clean, decoupled architecture:

```
lib/
├── app/                  # Application bootstrap, routing (GoRouter), dependencies
│   ├── router.dart
│   ├── dependencies.dart
│   └── shells/           # Patient & Doctor navigation shells
├── core/                 # Shared widgets, themes, formatters, and errors
│   ├── presentation/
│   ├── theme/
│   └── widgets/
├── data/                 # Data layer implementations
│   └── local/            # Standalone, persistent repositories
└── features/             # Feature-driven domain & presentation modules
    ├── appointments/     # Booking, listing, and slot management
    ├── auth/             # Login, registration, role selection
    ├── doctor/           # Doctor search, profile, slots, and dashboard
    ├── medicines/        # Pharmacy catalog, cart, and orders
    ├── notifications/    # In-app notifications
    ├── onboarding/       # Interactive walkthrough screens
    ├── patient/          # Patient dashboard & health summary
    ├── profile/          # User settings & profile
    └── records/          # Lab reports, vitals, and medical history
```

- **Framework**: [Flutter](https://flutter.dev) (Dart 3+)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Local Storage**: [shared_preferences](https://pub.dev/packages/shared_preferences)
- **UI & Icons**: Material 3 Design + Cupertino Icons

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.41.0` or newer)
- Android Studio / Xcode with an emulator or physical device

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/trydigital2/aarogivya.git
   cd aarogivya
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on an emulator or device:**
   ```bash
   flutter run
   ```

---

## 📱 Screenshots

| Onboarding | Login | Patient Dashboard |
|:---:|:---:|:---:|
| Doctor Booking Intro | Patient & Doctor Authentication | Quick Actions & Appointments |

| Find Doctors | Medicine Store | Digital Records |
|:---:|:---:|:---:|
| Search & Filter Doctors | Cart & Direct Orders | Vitals & Health Reports |

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
