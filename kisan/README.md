# 🌿 Kisan | AI-Powered Precision Agriculture

**Empowering farmers with intelligent insights for a sustainable future.**

Kisan is an advanced AI-driven platform designed to bridge the gap between traditional farming and modern technology. By leveraging Large Language Models (LLMs) and computer vision, we provide farmers with actionable data to increase yields and reduce waste.

---

## 🚀 Key Features

### 1. 🧪 Intelligent Fertilizer Planner
Kisan goes beyond generic advice. It uses a specialized LLM to analyze crop type, soil data, and growth stages to generate:
* **Custom Fertilizer Recipes:** Precise nutrient ratios.
* **Application Schedules:** Timelines for maximum absorption.
* **Cost Optimization:** Reducing over-application.

### 2. 🔍 Vision-Based Disease Diagnosis
Stop crop loss before it spreads. Using high-performance image analysis:
* **Instant Detection:** Identify pests, fungi, and nutrient deficiencies from a single photo.
* **Treatment Roadmap:** Immediate organic and chemical remedy suggestions.
* **Root Cause Analysis:** Understand environmental factors leading to the disease.

### 3. 🏛️ Government Scheme Aggregator
Navigating bureaucracy is hard. Kisan simplifies it by:
* **Smart Eligibility Matching:** Cross-referencing farmer profiles with active regional and national schemes.
* **Application Guidance:** Providing checklists and direct links to help farmers get the financial support they deserve.

---

## 🛠️ Tech Stack
* **Frontend:** Flutter (Android)
* **Intelligence:** Gemini 3 Flash (Multimodal Analysis)
* **State Management:** Provider / Riverpod 
* **Environment:** Dart / Google Generative AI SDK

---

## ⚙️ Installation & Setup

### Prerequisites
* Flutter SDK installed
* A valid [Gemini API Key](https://aistudio.google.com/)
* or A valid [OpenAI key]

### Step-by-Step Setup
1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/DheerajBishnoi/SmartKisan.git
    ```
2.  **Environment Configuration:**
    Navigate to the root directory and create a `.env` file at:
    `SmartKisan/kisan/.env`
    
    Add your API key inside:
    ```env
    GEMINI_API_KEY=your_actual_key_here
    or 
    GPT_API_KEY=""
    
    Select your desired model using:
    AI_PROVIDER="" (gpt/gemini)
    ```
3.  **Run the Application:**
    ```bash
    flutter pub get
    flutter run
    ```

---

## 📈 Future Roadmap
- [ ] Offline mode for remote areas using quantized local models.
- [ ] Integration with IoT soil sensors for real-time monitoring.
- [ ] Multilingual support (Voice-to-Text) for easier access.

---
*Created for NxtWave x OpenAI Buildathon 2025*