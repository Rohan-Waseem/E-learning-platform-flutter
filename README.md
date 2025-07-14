# 📚 Flutter E-Learning Platform

**E-Learning** is a platform built using **Flutter** and **Firebase**, designed to deliver high-quality education with personalized content, quizzes, AI assistance, and interactive teacher-student features. The app supports course uploads, student notes, messaging, and AI-driven help powered by Dialogflow.

## ✨ Features

- **Secure Firebase Authentication** – Signup/login with email verification
- **Browse & Enroll in Courses** – Organized by category or interest
- **Lessons & Resources** – Each course includes structured content, videos, PDFs, and images
- **Interactive Quizzes** – Test knowledge with real-time scoring and feedback
- **Student Notes** – Add and view private notes per lesson
- **Teacher Dashboard** – Upload and manage courses, lessons, notes, and quizzes
- **Discussion Threads** – Ask and answer questions below each lesson
- **AI Chat Assistant** – Get help from an integrated Dialogflow-powered assistant
- **Progress Tracking** – Monitor completion status and quiz performance
- **Firebase Firestore & Storage** – Secure, scalable backend
- **Modern Flutter UI** – Dark-themed, responsive design for Android

## 🛠️ Tech Stack

- **Flutter** & **Dart**
- **Firebase Authentication**
- **Cloud Firestore**
- **Firebase Storage**
- **Dialogflow ES** (AI assistant integration via Firebase Cloud Functions)
- **Provider / Riverpod** (for state management)
- **Custom UI Widgets + Google Fonts**

## 📂 Project Structure

- `lib/screens/` – All screen views for student and teacher dashboards
- `lib/widgets/` – Reusable custom widgets (cards, buttons, modals)
- `lib/models/` – Data models for Course, Lesson, Quiz, User, Notes
- `lib/services/` – Firebase + Dialogflow integrations
- `lib/utils/` – Utility functions (validators, formatters, colors)

## 🤖 AI Assistant (Dialogflow Integration)

- Built using **Dialogflow ES**
- Students can ask questions about lessons or concepts
- AI replies are fetched via **Firebase HTTPS Functions**
- Clean, simple chat UI included in `lib/screens/ai_chat_screen.dart`

## 📽️ Demo Preview

[![Watch the demo](assets/thumbnail.png)](https://www.youtube.com/watch?v=YOUR_VIDEO_ID)

## 🧪 Planned Enhancements

- 🎯 Quiz performance insights using ML
- 🏅 Badge system & gamification
- 🌐 Multilingual support
- 🔔 Push notifications for course updates
- 🧾 Certificate generation on course completion

## 🙋‍♂️ Developer

**Rohan Waseem**  
Flutter & Full Stack Developer    
📧 rohan.waseem965@gmail.com  
🔗 [[LinkedIn / Portfolio URL]](https://www.linkedin.com/in/rohan-w-53124731b/)

