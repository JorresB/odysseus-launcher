
# Odysseus Launcher

This is a macOS launcher app for running the Odysseus UI locally.

It is NOT the Odysseus UI itself.

The launcher is responsible for:
- Starting a local backend if needed
- Detecting if the server is already running
- Opening the UI in a native macOS WebView
- Providing a smooth startup experience (no terminal required)

---

## 🧠 What this is

This project is only a **launcher wrapper** for an existing local web app.

It does NOT include:
- The AI model
- The backend implementation
- The UI itself

It only starts and displays it.

---

## 🚀 Features

- One-click macOS startup
- Auto-start backend if not running
- Detects `localhost:7860`
- Embedded WebView (no browser needed)
- Splash screen loading state
- Smooth UI transition (no white flash)

---

## ⚙️ Requirements

- macOS
- Python backend already installed locally
- Backend must run on:
http://127.0.0.1:7860

---

## ▶️ How to use

1. Open the project in Xcode
2. Press Run (▶)
3. The app will:
   - Start backend if needed
   - Wait for server to be ready
   - Open UI automatically inside the app

---

## 🧪 Backend start (for reference)

If you want to run the backend manually:

```bash
python -m uvicorn app:app --host 127.0.0.1 --port 7860
```

---
📌 Notes
This project is a lightweight launcher layer:
* macOS app wrapper
* process starter
* WebView host
It is meant for local development use.

🧑‍💻 Author
Jorres Bout
