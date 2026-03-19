<div align="center">

<br/>

```
 ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
 ░                                                             ░
 ░    ███████╗██╗██╗  ██╗███████╗██╗      ██████╗ ██╗    ██╗  ░
 ░    ██╔════╝██║╚██╗██╔╝██╔════╝██║     ██╔═══██╗██║    ██║  ░
 ░    █████╗  ██║ ╚███╔╝ █████╗  ██║     ██║   ██║██║ █╗ ██║  ░
 ░    ██╔══╝  ██║ ██╔██╗ ██╔══╝  ██║     ██║   ██║██║███╗██║  ░
 ░    ██║     ██║██╔╝ ██╗██║     ███████╗╚██████╔╝╚███╔███╔╝  ░
 ░    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝  ╚══╝╚══╝  ░
 ░                                                             ░
 ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
```

### 🔗 **[Live Demo → fixflow-dc246.web.app](https://fixflow-dc246.web.app/)**

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FF6F00?style=for-the-badge&logo=firebase&logoColor=white)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Cloudinary](https://img.shields.io/badge/Cloudinary-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)](https://cloudinary.com)

[![Version](https://img.shields.io/badge/Version-1.0.0-blueviolet?style=flat-square)](https://fixflow-dc246.web.app/)
[![Status](https://img.shields.io/badge/Status-Live-brightgreen?style=flat-square)](https://fixflow-dc246.web.app/)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey?style=flat-square)](https://fixflow-dc246.web.app/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

</div>

---

<br/>

## 🌊 What is FixFlow?

**FixFlow** is a modern, real-time complaint management platform that eliminates the frustration of manual, opaque complaint handling. Built with Flutter and Firebase, it connects complainants and administrators in a single, transparent digital system — where every issue is tracked, every update is instant, and no complaint ever falls through the cracks.

> *Submit a complaint in under 2 minutes. Watch it resolve in real time.*

🔗 **Try it live:** [https://fixflow-dc246.web.app/](https://fixflow-dc246.web.app/)

<br/>

---

## ✨ Why FixFlow Stands Out

<br/>

### 🔴 The Problem It Solves
Manual complaint handling is slow, error-prone, and invisible. Complainants submit issues and hear nothing for days. Administrators drown in emails and spreadsheets. Nothing is tracked. Nothing is transparent.

### 🟢 The FixFlow Difference

| Old Way | FixFlow Way |
|---|---|
| Email chains, paper forms | One clean digital submission form |
| "We'll get back to you" | Live status updates the moment anything changes |
| No idea who's handling it | Direct admin assignment with contact info |
| Lost in the inbox | Centralized dashboard, nothing missed |
| No proof of resolution | Timestamped resolution notes, full audit trail |

<br/>

---

## 🚀 Core Features

<br/>

### 👤 For Users — Complete Visibility

- **One-tap Google Sign-In** — secure SSO via Firebase Auth, no passwords to remember
- **Smart Complaint Form** — title, description, category, location, image attachment, and direct admin assignment in a single guided flow
- **Image Attachments** — upload photo evidence directly from your device, hosted securely on Cloudinary CDN
- **Real-time Status Tracking** — watch your complaint move from Pending to In Progress to Resolved as it happens, powered by Firestore live streams
- **Resolution Notes** — see exactly what action was taken and when, with full admin commentary
- **Complaint History** — every complaint you've ever submitted, in one place, with full timeline

<br/>

### 🛡️ For Admins — Total Control

- **Centralized Dashboard** — instant overview of all assigned complaints broken down by Pending, In Progress, and Resolved
- **Live Complaint Feed** — real-time stream of assigned complaints, nothing needs refreshing
- **One-click Status Updates** — move complaints through the resolution pipeline with a single tap
- **Resolution Documentation** — add detailed notes at any stage, visible immediately to the complainant
- **Full Complaint Context** — access every detail the user submitted — description, category, location, image, timestamp, and contact info — all in one screen
- **Audit Trail** — every status change and note is timestamped, creating a permanent record of accountability

<br/>

---

## 🔄 The Complaint Lifecycle

```
╔══════════════╗       ╔═══════════════╗       ╔══════════════╗
║              ║       ║               ║       ║              ║
║   🟡 PENDING  ║──────►║ 🔵 IN PROGRESS ║──────►║  🟢 RESOLVED  ║
║              ║       ║               ║       ║              ║
║  Submitted   ║       ║ Admin working ║       ║ Closed +     ║
║  by user     ║       ║ on the issue  ║       ║ notes added  ║
╚══════════════╝       ╚═══════════════╝       ╚══════════════╝
       │                       │                      │
  Visible to              Visible to             Visible to
    user                    user                   user
```

Every transition is **instant** and **visible to both sides** the moment it happens.

<br/>

---

## 🛠️ Tech Stack

FixFlow is built on a modern, production-grade stack designed for performance, reliability, and real-time responsiveness.

```
┌────────────────────────────────────────────────────┐
│                 Flutter (Dart)                     │
│        Cross-platform · iOS · Android · Web        │
├──────────────────┬─────────────────────────────────┤
│  Firebase Auth   │       Cloud Firestore           │
│  Google Sign-In  │   Real-time NoSQL database      │
│  Session mgmt    │   Live streams · Offline sync   │
├──────────────────┴─────────────────────────────────┤
│               Cloudinary CDN                       │
│       Image upload · Optimisation · Hosting        │
├────────────────────────────────────────────────────┤
│    Provider  ·  go_router  ·  flutter_animate      │
│     State        Routing        Animations         │
└────────────────────────────────────────────────────┘
```

<br/>

---

## 🎯 Design Principles

- **Speed** — complaint submission in under 2 minutes, app load under 3 seconds
- **Transparency** — every status change is immediately visible to the user, no black boxes
- **Simplicity** — intuitive flows designed for users with basic smartphone literacy
- **Reliability** — Firebase infrastructure, Cloudinary CDN, crash rate target under 0.1%
- **Real-time** — Firestore live streams mean zero manual refreshing, ever

<br/>



<div align="center">

**Built with 💙 Flutter · Firebase · Cloudinary**

*If FixFlow impressed you, drop a ⭐ — it genuinely means a lot.*

</div>
