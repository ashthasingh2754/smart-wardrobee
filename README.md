
# 👗 Smart Wardrobe

A personal wardrobe management and outfit recommendation app built with Python, Streamlit, and SQLite.

## ✨ Features

- Add clothing items with photos
- Search and filter your wardrobe
- Organize clothes by category
- Generate outfit suggestions for different occasions
- Plan and save outfits
- Get weather-based clothing suggestions

## 🛠️ Technologies Used

- Python
- Streamlit
- SQLite
- OpenWeather API

## 🚀 How to Run

1. Clone or download this repository.
2. Open a terminal in the project folder.
3. Create and activate a virtual environment.
4. Install the required dependencies.
5. Configure your OpenWeather API key in Streamlit secrets.
6. Run the application.

```bash
python -m streamlit run app.py
```

## 🔐 API Key Setup

Create `.streamlit/secrets.toml` locally and add:

```toml
OPENWEATHER_API_KEY = "your_api_key_here"
```

Never commit your real API key or `secrets.toml` to GitHub.

## 👩‍💻 About

Smart Wardrobe is a Python project designed to make clothing organization and outfit planning easier.

