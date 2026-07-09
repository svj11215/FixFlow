<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0d0d1a,30:1a0533,60:0a1628,100:0d0d1a&height=240&section=header&text=FixFlow&fontSize=86&fontColor=ffffff&fontAlignY=40&fontAlign=50&desc=Complaint%20Management%2C%20Reimagined&descSize=17&descAlignY=62&descAlign=50&animation=fadeIn&stroke=6c47ff&strokeWidth=2" width="100%"/>

<br/>

[![Typing SVG](https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=700&size=18&duration=2800&pause=1200&color=6C47FF&center=true&vCenter=true&multiline=true&width=600&height=54&lines=Submit+·+Track+·+Resolve;Real-time+·+Role-based+·+AI-Powered)](https://fixflow-dc246.web.app/)

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FF6F00?style=for-the-badge&logo=firebase&logoColor=white)](https://firebase.google.com)
[![Cloudinary](https://img.shields.io/badge/Cloudinary-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)](https://cloudinary.com)
[![Groq](https://img.shields.io/badge/Groq%20AI-F55036?style=for-the-badge&logo=groq&logoColor=white)](https://groq.com)

<br/>

</div>

<br/>

---

## 📌 About FixFlow

**FixFlow** is a cross-platform complaint management system built with **Flutter** and **Firebase**, designed to make reporting and resolving everyday issues — electrical, plumbing, internet, maintenance — fast, transparent, and trackable in real time.

Users submit complaints with photos and location context, watch live status updates as admins work the queue, and get instant troubleshooting help from an AI assistant powered by **Groq's Llama 3.3 70B** while they wait.

**🔗 Live Demo:** [fixflow-dc246.web.app](https://fixflow-dc246.web.app/)

---

## 👤 User Features

| Feature | Description |
|---|---|
| 🔐 **Google Sign-In SSO** | Passwordless authentication via Firebase Auth |
| 📝 **Smart Complaint Form** | Structured entry — title, category, location |
| 📸 **Image Attachments** | Photo uploads via Cloudinary CDN |
| 📡 **Realtime Status Feed** | Live updates powered by Firestore streams |
| 🗒️ **Resolution Notes** | Admin remarks visible once resolved |
| 🗑️ **Manage Pending Items** | Delete or review full complaint history |
| 🤖 **AI Assistant** | 24/7 instant guidance while complaints are processed |

---

## 🛡️ Admin Features

| Feature | Description |
|---|---|
| 📊 **Central Dashboard** | At-a-glance metrics and status counts |
| 📬 **Assigned Complaint Feed** | Live feed, no manual refresh needed |
| 🔄 **Status Control** | Move complaints: Pending → In Progress → Resolved |
| 📋 **Full Complaint Context** | Image, location, and timestamp in one view |
| 🗒️ **Resolution Docs** | Timestamped, auditable resolution trail |

---

## 🤖 AI Assistant — FixFlow Intelligence

<div align="center">

[![AI](https://img.shields.io/badge/Powered%20By-Llama%203.3%2070B-6c47ff?style=for-the-badge)](#)
[![Groq](https://img.shields.io/badge/Inference-Groq%20LPU-F55036?style=for-the-badge)](#)
[![Chat](https://img.shields.io/badge/History-Firestore%20Persistent-FF6F00?style=for-the-badge)](#)
[![Speed](https://img.shields.io/badge/Response-%3C%201%20Second-22c55e?style=for-the-badge)](#)

</div>

| Capability | Description |
|---|---|
| ⚡ **Instant Responses** | Groq LPU inference, replies in under 1 second |
| 🔌 **Electrical Guidance** | Safety tips and precautionary steps |
| 🔧 **Plumbing Advice** | Temporary fixes and step-by-step guidance |
| 🌐 **Internet Troubleshooting** | Router resets, DNS fixes, connectivity checks |
| 🧹 **General Maintenance Help** | DIY steps and guidance on when to wait for an admin |
| 💾 **Persistent Chat History** | Conversations stored in Firestore, resumable anytime |
| 🗑️ **Clear Chat Option** | Reset the conversation whenever you like |

<details>
<summary><strong>💬 Example Interactions</strong></summary>

<br/>

**User:** *"My electricity tripped, what should I do?"*

**FixFlow AI:** Reset your circuit breaker — locate your electrical panel, find the tripped switch (middle position), push it fully OFF then ON. If it trips again, unplug all devices and retry. Do NOT touch wiring directly. Your complaint is being processed by the admin.

---

**User:** *"Water is leaking from the sink pipe"*

**FixFlow AI:** As a temporary fix, place a bucket under the leak and turn off the water valve (under the sink, turn clockwise). Avoid using that tap until resolved. Your complaint has been filed and is in the queue.

---

**User:** *"How long will my complaint take?"*

**FixFlow AI:** Typically complaints are picked up within a few hours. You'll see a real-time status update the moment your admin marks it "In Progress." You can track it in your complaints feed.

</details>

---

## 🔄 Complaint Lifecycle

<div align="center">

![pending](https://img.shields.io/badge/%F0%9F%9F%A1%20PENDING-complaint%20submitted-f59e0b?style=for-the-badge)
&nbsp;**`──────►`**&nbsp;
![inprogress](https://img.shields.io/badge/%F0%9F%94%B5%20IN%20PROGRESS-admin%20active-3b82f6?style=for-the-badge)
&nbsp;**`──────►`**&nbsp;
![resolved](https://img.shields.io/badge/%F0%9F%9F%A2%20RESOLVED-closed%20%2B%20notes-22c55e?style=for-the-badge)

</div>

| Stage | Who Acts | What Happens |
|:---:|:---:|---|
| 🟡 **Pending** | User submits | Complaint created, admin notified, status visible |
| 🔵 **In Progress** | Admin picks up | Status updated live, user sees change instantly |
| 🟢 **Resolved** | Admin closes | Resolution note saved, timestamped, audit trail locked |
| 🤖 **Any Stage** | AI Assistant | User gets instant guidance 24/7 while waiting |

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|:---:|:---:|---|
| 📱 **Frontend** | Flutter 3.x · Dart | Cross-platform UI — iOS, Android, Web |
| 🔐 **Auth** | Firebase Auth · Google Sign-In | Secure SSO, session management |
| 🗄️ **Database** | Cloud Firestore | Realtime NoSQL, live streams + chat history |
| 🖼️ **Storage** | Cloudinary CDN | Image upload, optimisation, delivery |
| 🤖 **AI Engine** | Groq · Llama 3.3 70B | Ultra-fast AI inference for assistant |
| ⚙️ **State Management** | Provider | AuthProvider, ComplaintProvider, ChatProvider |
| 🧭 **Routing** | go_router | Role-based navigation guards |
| ✨ **Animation** | flutter_animate | Smooth transitions, micro-interactions |

---

## 📊 Performance Targets

<div align="center">

![submit](https://img.shields.io/badge/Submission-%3C%202%20minutes-6c47ff?style=flat-square&logo=checkmarx&logoColor=white)
![load](https://img.shields.io/badge/App%20Load-%3C%203%20seconds-0ea5e9?style=flat-square&logo=speedtest&logoColor=white)
![stream](https://img.shields.io/badge/Live%20Update-%3C%201%20second-22c55e?style=flat-square&logo=firebase&logoColor=white)
![image](https://img.shields.io/badge/Image%20Upload-%3C%205%20seconds-f59e0b?style=flat-square&logo=cloudinary&logoColor=white)
![ai](https://img.shields.io/badge/AI%20Response-%3C%201%20second-F55036?style=flat-square&logo=groq&logoColor=white)
![crash](https://img.shields.io/badge/Crash%20Rate-%3C%200.1%25-ef4444?style=flat-square&logo=flutter&logoColor=white)

</div>

---



<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0d0d1a,50:1a0533,100:0d0d1a&height=120&section=footer&text=Try%20FixFlow%20Live&fontSize=24&fontColor=ffffff&fontAlignY=65&animation=fadeIn&desc=fixflow-dc246.web.app&descSize=14&descAlignY=85&descAlign=50" width="100%"/>

</div>
