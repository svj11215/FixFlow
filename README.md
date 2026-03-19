<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0d0d1a,30:1a0533,60:0a1628,100:0d0d1a&height=240&section=header&text=FixFlow&fontSize=86&fontColor=ffffff&fontAlignY=40&fontAlign=50&desc=Complaint%20Management%2C%20Reimagined&descSize=17&descAlignY=62&descAlign=50&animation=fadeIn&stroke=6c47ff&strokeWidth=2" width="100%"/>

<br/>

[![Typing SVG](https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=700&size=18&duration=2800&pause=1200&color=6C47FF&center=true&vCenter=true&multiline=true&width=600&height=54&lines=Submit+·+Track+·+Resolve;Real-time+·+Role-based+·+Transparent)](https://fixflow-dc246.web.app/)

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FF6F00?style=for-the-badge&logo=firebase&logoColor=white)](https://firebase.google.com)
[![Cloudinary](https://img.shields.io/badge/Cloudinary-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)](https://cloudinary.com)

<br/>

[![Live Demo](https://img.shields.io/badge/%F0%9F%9F%A2%20LIVE-fixflow--dc246.web.app-22c55e?style=for-the-badge)](https://fixflow-dc246.web.app/)
[![Version](https://img.shields.io/badge/Version-1.0.0-8b5cf6?style=for-the-badge)](#)
[![Platform](https://img.shields.io/badge/iOS%20%7C%20Android%20%7C%20Web-0ea5e9?style=for-the-badge)](#)

</div>

## 👤 User Features &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 🛡️ Admin Features

<table>
<tr>
<td width="50%" valign="top">

```
┌─────────────────────────────────┐
│  👤  USER  PANEL                │
├─────────────────────────────────┤
│                                 │
│  🔐  Google Sign-In SSO         │
│      Firebase Auth · No pwd     │
│                                 │
│  📝  Smart Complaint Form       │
│      Title · Category · Loc     │
│                                 │
│  📸  Image Attachments          │
│      Cloudinary CDN upload      │
│                                 │
│  📡  Realtime Status Feed       │
│      Firestore live streams     │
│                                 │
│  🗒️  Resolution Notes           │
│      Admin commentary visible   │
│                                 │
│  🗑️  Delete Pending Items       │
│      Full complaint history     │
│                                 │
└─────────────────────────────────┘
```

</td>
<td width="50%" valign="top">

```
┌─────────────────────────────────┐
│  🛡️  ADMIN  PANEL               │
├─────────────────────────────────┤
│                                 │
│  📊  Central Dashboard          │
│      Metrics · Status counts    │
│                                 │
│  📬  Assigned Complaint Feed    │
│      Live · Never refresh       │
│                                 │
│  🔄  Status Control             │
│      Pending → In Progress      │
│      In Progress → Resolved     │
│                                 │
│  📋  Full Complaint Context     │
│      Image · Location · Time    │
│                                 │
│  🗒️  Resolution Docs            │
│      Timestamped audit trail    │
│                                 │
└─────────────────────────────────┘
```

</td>
</tr>
</table>

---

<br/>

## 🔄 Complaint Lifecycle

<div align="center">

![lifecycle](https://img.shields.io/badge/%F0%9F%9F%A1%20PENDING-complaint%20submitted-f59e0b?style=for-the-badge)
&nbsp;**`──────►`**&nbsp;
![inprogress](https://img.shields.io/badge/%F0%9F%94%B5%20IN%20PROGRESS-admin%20active-3b82f6?style=for-the-badge)
&nbsp;**`──────►`**&nbsp;
![resolved](https://img.shields.io/badge/%F0%9F%9F%A2%20RESOLVED-closed%20%2B%20notes-22c55e?style=for-the-badge)

<br/>

| Stage | Who Acts | What Happens |
|:---:|:---:|---|
| 🟡 **Pending** | User submits | Complaint created, admin notified, status visible |
| 🔵 **In Progress** | Admin picks up | Status updated live, user sees change instantly |
| 🟢 **Resolved** | Admin closes | Resolution note saved, timestamped, audit trail locked |

</div>

---

<br/>

## 🛠️ Tech Stack

<div align="center">

| Layer | Technology | Purpose |
|:---:|:---:|---|
| 📱 **Frontend** | Flutter 3.x · Dart | Cross-platform UI — iOS, Android, Web |
| 🔐 **Auth** | Firebase Auth · Google Sign-In | Secure SSO, session management |
| 🗄️ **Database** | Cloud Firestore | Realtime NoSQL, live streams |
| 🖼️ **Storage** | Cloudinary CDN | Image upload, optimisation, delivery |
| ⚙️ **State** | Provider | AuthProvider, ComplaintProvider |
| 🧭 **Routing** | go_router | Role-based navigation guards |
| ✨ **Animation** | flutter_animate | Smooth transitions, micro-interactions |

</div>

---

<br/>

## 📊 Performance Targets

<div align="center">

![submit](https://img.shields.io/badge/Submission-%3C%202%20minutes-6c47ff?style=flat-square&logo=checkmarx&logoColor=white)
![load](https://img.shields.io/badge/App%20Load-%3C%203%20seconds-0ea5e9?style=flat-square&logo=speedtest&logoColor=white)
![stream](https://img.shields.io/badge/Live%20Update-%3C%201%20second-22c55e?style=flat-square&logo=firebase&logoColor=white)
![image](https://img.shields.io/badge/Image%20Upload-%3C%205%20seconds-f59e0b?style=flat-square&logo=cloudinary&logoColor=white)
![crash](https://img.shields.io/badge/Crash%20Rate-%3C%200.1%25-ef4444?style=flat-square&logo=flutter&logoColor=white)

</div>

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0d0d1a,50:1a0533,100:0d0d1a&height=120&section=footer&text=Try%20FixFlow%20Live&fontSize=24&fontColor=ffffff&fontAlignY=65&animation=fadeIn&desc=fixflow-dc246.web.app&descSize=14&descAlignY=85&descAlign=50" width="100%"/>

</div>
