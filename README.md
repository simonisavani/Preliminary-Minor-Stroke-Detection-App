# StrokeAlert: Preliminary Minor Stroke Detection App

A mobile application for the early, self-assistive detection of **minor strokes**, based on the clinically accepted **FAST criteria**. The app uses multimodal sensor inputs—camera, audio, and touch—to detect common early symptoms and prompt users to seek immediate medical attention if necessary.

---

## Publications

This app and its underlying research have been featured in the following international conferences:

* **StrokeAlert: Early Detection of Minor Strokes**, *2024 4th International Conference on Advancement in Electronics & Communication Engineering (AECE)*
* **A Comprehensive Review of Multimodal Techniques for Early Detection of Minor Strokes**, *2nd International Conference on Technologies for Energy, Agriculture, and Healthcare*

---

## Based on the FAST Criteria

The app is inspired by the medical **FAST** test used to detect stroke symptoms:

| FAST Component | App Feature                                                       |
| -------------- | ----------------------------------------------------------------- |
| **F – Face**   | Facial asymmetry detection using the front camera                 |
| **A – Arms**   | Arm weakness simulated via tapping or movement test               |
| **S – Speech** | Voice analysis to detect slurred or delayed speech                |
| **T – Time**   | Urges users to act quickly and seek help if symptoms are detected |

---

## Features

* **Facial landmark analysis**: Uses on-device ML to detect signs of facial drooping
* **Touch test**: Checks coordination and speed using touchscreen tapping
* **Speech recognition**: Captures and evaluates clarity of user-spoken phrases
* **Risk evaluation**: Generates a stroke likelihood score based on combined tests
* **Immediate guidance**: Provides alerts and health advice based on FAST results

---

## Getting Started

### Prerequisites

* Android device (API level 24+)
* Android Studio (Flamingo or later)
* Kotlin/Java 8+

### Installation

```bash
git clone https://github.com/simonisavani/Preliminary-Minor-Stroke-Detection-App.git
cd Preliminary-Minor-Stroke-Detection-App
```

* Open in Android Studio → Build & Run on device/emulator

---

## 📱 App Screens 

* [ ] Facial Test Screen

![image](https://github.com/user-attachments/assets/e581377f-f73f-461c-92e7-4befc391cfc5)
![image](https://github.com/user-attachments/assets/7c470e12-3a5f-404b-a4a7-0cf510a574f2)

* [ ] Arm Coordination Screen

![image](https://github.com/user-attachments/assets/d5801b9f-20a5-4107-b2ad-02f97bc25f60)

* [ ] Speech Input Screen

![image](https://github.com/user-attachments/assets/a969a60a-71d0-42b7-9d5e-9dea64a6ebbb)
![image](https://github.com/user-attachments/assets/61791cf7-da4d-4338-ab89-c9caab9142f1)

* [ ] Final Result and Advice

![image](https://github.com/user-attachments/assets/f259dc32-ca67-4086-91c2-2aac0593509a)
---

## 📦 Tech Stack

* **Language**: Kotlin / Java
* **ML Framework**: TensorFlow Lite / ML Kit
* **UI**: Material Design Components
* **Audio**: Android AudioRecord & MFCC feature extraction
* **On-device privacy**: No data uploaded

---

## 🔒 Privacy

* All detection is **on-device**
* No personally identifiable data is stored or transmitted
* App explicitly instructs users to consult doctors in case of high risk
