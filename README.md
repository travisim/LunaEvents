# 🌙 LunaEvents - AI-Powered Event Discovery

LunaEvents combines web scraping, AI-powered recommendations, and social networking in a SwiftUI iOS app. The project has three main components:

## 🏗️ Components

### 1. 🕷️ Selenium Web Scraper

Automatically scrapes event data from Luma.co and saves to CSV.

### 2. 📱 SwiftUI iOS App

Modern iOS app with authentication, event discovery, AI recommendations, and social features.

### 3. 🗄️ Supabase Backend

PostgreSQL database with vector embeddings, edge functions, and real-time features.

## 🚀 Quick Start

### Run Selenium Scraper

```bash
cd seleniumScrap
pip install -r requirements.txt
python scraper.py
```

### Run iOS App

1. Open `LunaEvents.xcodeproj` in Xcode
2. Configure Supabase credentials in `SupabaseManager.swift`
3. Build and run on iOS simulator or device

### Setup Supabase Backend

1. Create new Supabase project
2. Run `schema.sql` in SQL editor
3. Deploy edge functions:
   ```bash
   cd supabase
   supabase functions deploy
   ```

## 🛠️ Tech Stack

- **Frontend**: SwiftUI, iOS
- **Backend**: Supabase (PostgreSQL + Edge Functions)
- **AI/ML**: Vector embeddings with pgvector
- **Scraping**: Python, Selenium WebDriver

## 📊 Features

- ✅ Automated event data collection
- ✅ AI-powered event recommendations
- ✅ Social networking & friend connections
- ✅ Location-based event discovery
- ✅ Real-time updates
