
import streamlit as st
import database
import requests
from datetime import datetime
import random

def get_live_weather(city):
    api_key = st.secrets["OPENWEATHER_API_KEY"]

    geo_url = "https://api.openweathermap.org/geo/1.0/direct"

    try:
        geo_response = requests.get(
            geo_url,
            params={
                "q": f"{city},IN",
                "limit": 5,
                "appid": api_key
            },
            timeout=10
        )

        if geo_response.status_code == 401:
            st.error("Weather API key is invalid or not activated yet.")
            return None

        geo_response.raise_for_status()
        locations = geo_response.json()
        
        if not locations:
            st.error(f"Could not find {city}. Try another spelling.")
            return None

        # Prefer a result whose city name matches the user's input
        location = next(
            (
                item for item in locations
                if item["name"].strip().lower() == city.strip().lower()
            ),
            locations[0]
        )
        lat = location["lat"]
        lon = location["lon"]
        
        weather_url = "https://api.openweathermap.org/data/2.5/weather"

        weather_response = requests.get(
            "https://api.openweathermap.org/data/2.5/weather",
            params={
                "lat": float(lat),
                "lon": float(lon),
                "appid": api_key,
                "units": "metric"
            },
            timeout=10
        )
        

        if weather_response.status_code == 401:
            st.error("Weather API key is invalid or not activated yet.")
            return None

        weather_response.raise_for_status()
        weather_data = weather_response.json()


        return weather_data
        

    except requests.RequestException as error:
        st.error(f"Weather request failed: {error}")
        return None

def correct_city_spelling(city):
    from rapidfuzz import process, fuzz

    api_key = st.secrets["OPENWEATHER_API_KEY"]
    url = "https://api.openweathermap.org/geo/1.0/direct"
    cleaned = city.strip()

    known_cities = [
        "Lucknow", "Prayagraj", "Allahabad", "Kanpur",
        "Varanasi", "Agra", "Meerut", "Noida", "Ayodhya",
        "Gorakhpur", "Mumbai", "Delhi", "New Delhi",
        "Kolkata", "Chennai", "Bengaluru", "Hyderabad",
        "Pune", "Jaipur", "Ahmedabad", "Patna", "Bhopal",
        "London", "New York", "Toronto", "Dubai", "Singapore",
        "Tokyo", "Paris", "Sydney", "Karachi", "Dhaka"
    ]

    # Match the typed city against our known city list
    match = process.extractOne(
        cleaned,
        known_cities,
        scorer=fuzz.WRatio,
        score_cutoff=75
    )

    search_city = match[0] if match else cleaned

    # Search the corrected name using OpenWeather
    try:
        response = requests.get(
            url,
            params={
                "q": f"{search_city},IN" if search_city in known_cities else search_city,
                "limit": 5,
                "appid": api_key
            },
            timeout=10
        )

        response.raise_for_status()
        cities = response.json()

        if cities:
            return cities[0]["name"]

        # If the API has no result, return our matched name
        if match:
            return search_city

    except requests.RequestException:
        st.warning("Could not check the city name. Please try again.")

    return None

st.set_page_config(
    page_title="Smart Wardrobe | Style Assistant",
    page_icon="👗",
    layout="wide",
    initial_sidebar_state="expanded"
)


st.markdown("""
<style>
    /* Soft blush background */
    .stApp {
        background-color: #211a22;
        color: #f8edf3;
    }

    section[data-testid="stMain"] {
        background-color: #211a22;
    }

    /* Elegant headings */
    h1, h2, h3 {
        color: #f4b6ce !important;
        font-family: Georgia, serif;
        font-weight: 600;
        letter-spacing: 0.3px;
    }

    /* Readable body text */
    p, label, .stMarkdown,
    [data-testid="stCaptionContainer"] {
        color: #eadce5;
    }

    /* Wardrobe statistics */
    div[data-testid="stMetric"] {
        background: linear-gradient(145deg, #382637, #30212f);
        padding: 20px;
        border-radius: 18px;
        border: 1px solid #65445d;
        box-shadow: 0 4px 14px rgba(0, 0, 0, 0.12);
    }

    div[data-testid="stMetricLabel"] {
        color: #e7b8ce !important;
    }

    div[data-testid="stMetricValue"] {
        color: #fff1f7 !important;
    }

    /* Text input */
    .stTextInput input {
        background-color: #342733;
        color: #fff1f7;
        border: 1px solid #76536c;
        border-radius: 12px;
    }

    .stTextInput input::placeholder {
        color: #cbb4c5;
    }

    /* Dropdowns */
    div[data-baseweb="select"] > div {
        background-color: #342733;
        color: #fff1f7;
        border-color: #76536c;
        border-radius: 12px;
    }

    /* Forms and photo upload */
    div[data-testid="stForm"],
    div[data-testid="stFileUploader"] {
        background-color: #2c222d;
        color: #f8edf3;
        padding: 18px;
        border-radius: 18px;
        border: 1px solid #594054;
    }

    /* Clothing cards */
    div[data-testid="stVerticalBlockBorderWrapper"] {
        background-color: #2b212c;
        border: 1px solid #594054;
        border-radius: 18px;
    }

    /* Expandable edit section */
    div[data-testid="stExpander"] {
        background-color: #302330;
        border: 1px solid #65445d;
        border-radius: 14px;
    }

    /* Buttons */
    div.stButton > button {
        background-color: #c77da0;
        color: #241923;
        border: 1px solid #d99ab7;
        border-radius: 12px;
        font-weight: 600;
        transition: all 0.2s ease;
    }

    div.stButton > button:hover {
        background-color: #e5a8c4;
        color: #241923;
        border-color: #f4c4d9;
    }

    /* Dividers */
    hr {
        border-color: #594054;
    }

    /* Multiselect tags */
    span[data-baseweb="tag"] {
        background-color: #80516f;
        color: #ffffff;
    }

    /* Links */
    a {
        color: #f4b6ce !important;
    }

    /* Success and info messages */
    div[data-testid="stAlert"] {
        border-radius: 14px;
    }
</style>
""", unsafe_allow_html=True)




database.create_database()

# Pinterest-inspired sidebar
with st.sidebar:
    st.markdown(
        "<h2 style='color:#f4b6ce;'>♡ Style Diary</h2>",
        unsafe_allow_html=True
    )

    st.caption("Your little corner of fashion ✿")
    st.divider()

    sidebar_clothes = database.get_clothes()

    st.metric("My Wardrobe", len(sidebar_clothes))

    st.markdown("### ✧ Your Style Space")
    st.write("👗 Build your collection")
    st.write("🎀 Discover outfit ideas")
    st.write("♡ Dress like yourself")

    st.divider()
    st.caption("Made with ♡ and a little style.")


# Style inspiration card
from datetime import date

style_tips = [
    "Pair denim with a cute top for an effortless look. ♡",
    "Try matching your accessories to one color in your outfit. 🎀",
    "A simple outfit can shine with statement earrings. ✨",
    "Layer different textures to make your outfit interesting. 🌷",
    "Choose an outfit that makes you feel confident. 💗",
    "Neutral colors pair beautifully with one bold accent. 🖤",
    "Your favorite outfit is always worth wearing again. ♡"
]

today_tip = style_tips[date.today().weekday()]

st.markdown(f"""
<div style="
    background: linear-gradient(135deg, #382637, #70445f);
    border: 1px solid #8b526f;
    border-radius: 18px;
    padding: 22px;
    margin-bottom: 25px;
">
    <p style="color:#f4b6ce; letter-spacing:2px;
              font-size:12px; margin-bottom:8px;">
        ✧ YOUR DAILY FASHION NOTE ✧
    </p>
    <h3 style="color:#ffffff; margin-top:0;">
        Style of the Day ♡
    </h3>
    <p style="color:#fff0f6; margin-bottom:0;">
        {today_tip}
    </p>
</div>
""", unsafe_allow_html=True)




st.markdown("""
<div style="
    background: linear-gradient(135deg, #4a2d43, #8b526f, #c77da0);
    padding: 35px 30px;
    border-radius: 22px;
    margin-bottom: 28px;
    border: 1px solid #b87b9d;
">
    <p style="
        color: #ffe2ef;
        font-size: 14px;
        letter-spacing: 3px;
        text-transform: uppercase;
        margin-bottom: 10px;
    ">
        ✧ YOUR PERSONAL STYLE JOURNAL ✧
    </p>
    <h1 style="
        color: #ffffff;
        font-family: Georgia, serif;
        font-size: 42px;
        margin: 0;
    ">
        My Smart Wardrobe ♡
    </h1>
    <p style="
        color: #fff0f6;
        font-size: 16px;
        margin-top: 12px;
        margin-bottom: 0;
    ">
        Curate your closet. Discover your style. Dress like you. ✿
    </p>
</div>
""", unsafe_allow_html=True)


categories = [
    "Shirts", "T-shirts", "Trousers", "Jeans",
    "Dresses", "Footwear", "Accessories","Traditional"
]

occasions = [
    "College", "Office", "Casual Outing",
    "Party", "Wedding", "Travel","Festival"
]

# Add clothing
st.header("➕ Add a Clothing Item")

with st.form("add_clothing_form"):
    item_name = st.text_input("Clothing item name")

    category = st.selectbox("Choose a category", categories)

    uploaded_image = st.file_uploader(
        "Upload a clothing photo (optional)",
        type=["jpg", "jpeg", "png"]
    )

    submitted = st.form_submit_button("Add Item")

    if submitted:
        if not item_name.strip():
            st.warning("Please enter a clothing item name.")
        else:
            image_bytes = (
                uploaded_image.getvalue()
                if uploaded_image is not None
                else None
            )

            database.add_clothing(
                item_name.strip(),
                category,
                image_bytes
            )

            st.success("Clothing item saved permanently!")
            st.rerun()

st.divider()


# Display wardrobe
st.header("🧥 My Clothing Collection")

search_query = st.text_input(
    "🔍 Search your wardrobe",
    placeholder="Enter a clothing name..."
)

filter_category = st.selectbox(
    "Filter by category",
    ["All"] + categories
)

clothes = database.get_clothes()

# Wardrobe statistics
st.subheader("📊 Wardrobe Summary")

if clothes:
    category_counts = {}

    for item in clothes:
        item_category = item["category"]
        category_counts[item_category] = (
            category_counts.get(item_category, 0) + 1
        )

    col1, col2, col3 = st.columns(3)
    col1.metric("Total Items", len(clothes))
    col2.metric("Categories Used", len(category_counts))

    most_common_category = max(
        category_counts,
        key=category_counts.get
    )
    col3.metric("Most Items In", most_common_category)

    st.write("**Items by category:**")

    for item_category, count in category_counts.items():
        st.write(f"- {item_category}: {count}")
        
else:
    st.info("Add some clothing items to see your wardrobe statistics.")

filtered_items = [
    item for item in clothes
    if (
        filter_category == "All"
        or item["category"] == filter_category
    )
    and search_query.strip().lower() in item["name"].lower()
]

st.write(f"Total clothing items: {len(clothes)}")
st.write(f"Items displayed: {len(filtered_items)}")


if filtered_items:
    gallery_columns = st.columns(3)

    for index, item in enumerate(filtered_items):
        with gallery_columns[index % 3]:
            with st.container(border=True):
                if item["image"] is not None:
                    st.image(
                        item["image"],
                        use_container_width=True
                    )
                else:
                    st.markdown(
                        "<div style='background:#382637;"
                        "padding:50px;text-align:center;"
                        "border-radius:12px;font-size:40px;'>"
                        "👗</div>",
                        unsafe_allow_html=True
                    )

                st.markdown(
                    f"### {item['name']}"
                )
                st.caption(f"♡ {item['category']}")
                
                is_favorite = item.get("is_favorite", 0) == 1

                if st.button(
                    "💗 Remove from Favorites"
                    if is_favorite
                    else "♡ Add to Favorites",
                    key=f"favorite_{item['id']}"
                ):
                    database.toggle_favorite(
                        item["id"],
                        0 if is_favorite else 1
                    )
                    st.rerun()


                with st.expander("✏️ Edit Clothing"):
                    edited_name = st.text_input(
                        "Clothing name",
                        value=item["name"],
                        key=f"edit_name_{item['id']}"
                    )

                    edited_category = st.selectbox(
                        "Category",
                        categories,
                        index=(
                            categories.index(item["category"])
                            if item["category"] in categories
                            else 0
                        ),
                        key=f"edit_category_{item['id']}"
                    )

                    if st.button(
                        "Save Changes",
                        key=f"save_edit_{item['id']}"
                    ):
                        if edited_name.strip():
                            database.update_clothing(
                                item["id"],
                                edited_name.strip(),
                                edited_category
                            )
                            st.success("Clothing item updated!")
                            st.rerun()
                        else:
                            st.warning(
                                "Clothing name cannot be empty."
                            )

                if st.button(
                    "🗑️ Delete Item",
                    key=f"delete_{item['id']}"
                ):
                    database.delete_clothing(item["id"])
                    st.rerun()
else:
    st.info("No items found. Add your first clothing item!")


st.divider()

# Outfit suggestions
st.header("👔 Outfit Planner")
st.subheader("✨ Outfit Suggestions")

if clothes:
    recommendation_occasion = st.selectbox(
        "Get suggestions for",
        occasions,
        key="recommendation_occasion"
    )

    if st.button("Recommend an Outfit"):
        if recommendation_occasion in [
            "College", "Casual Outing", "Travel"
        ]:
            preferred_categories = ["T-shirts", "Jeans", "Shoes"]
        elif recommendation_occasion == "Office":
            preferred_categories = ["Shirts", "Trousers", "Shoes"]
        elif recommendation_occasion in ["Party", "Wedding"]:
            preferred_categories = [
                "Shirts", "Trousers", "Dresses", "Shoes"
            ]
        else:
            preferred_categories = categories

        suggestions = [
            item for item in clothes
            if item["category"] in preferred_categories
        ]

        if suggestions:
            st.write(f"Suggestions for {recommendation_occasion}:")

            for item in suggestions:
                col1, col2 = st.columns([1, 3])

                with col1:
                    if item["image"] is not None:
                        st.image(item["image"], width=120)
                    else:
                        st.write("👕")

                with col2:
                    st.write(f"**{item['name']}**")
                    st.caption(f"Category: {item['category']}")
        else:
            st.info(
                "No matching items found. Add more clothes "
                "to get suggestions for this occasion."
            )
else:
    st.info("Add clothing items before requesting recommendations.")

st.divider()

# Plan your own outfit
st.subheader("🗓️ Plan Your Own Outfit")

occasion = st.selectbox(
    "Choose an occasion",
    occasions,
    key="planner_occasion"
)

if clothes:
    item_options = {
        f"{item['name']} ({item['category']})": item["id"]
        for item in clothes
    }

    selected_outfit = st.multiselect(
        "Select clothes for your outfit",
        options=list(item_options.keys()),
        key="selected_outfit"
    )

    if st.button("Create Outfit"):
        if selected_outfit:
            st.session_state["planned_outfit"] = {
                "occasion": occasion,
                "items": selected_outfit
            }
        else:
            st.warning("Please select at least one item.")

    planned_outfit = st.session_state.get("planned_outfit")

    if planned_outfit:
        st.subheader("✨ Your Planned Outfit")
        st.write(f"Occasion: **{planned_outfit['occasion']}**")

        for clothing in planned_outfit["items"]:
            st.write(f"👕 {clothing}")
else:
    st.info("Add clothing items before planning an outfit.")

st.divider()
st.caption("Smart Wardrobe App | Python, Streamlit and SQLite")


# Saved Outfit Journal
st.divider()
st.header("🎀 My Saved Outfits")

with st.form("save_outfit_form"):
    outfit_name = st.text_input(
        "Name your look",
        placeholder="e.g. College Casual"
    )

    outfit_occasion = st.selectbox(
        "Occasion",
        [
            "College",
            "Office",
            "Casual Outing",
            "Party",
            "Wedding",
            "Travel"
        ],
        key="saved_outfit_occasion"
    )
    all_clothes = database.get_clothes()


    if all_clothes:
        clothing_options = {
            f"{item['name']} ({item['category']})": item["id"]
            for item in all_clothes
        }

        chosen_clothes = st.multiselect(
            "Choose pieces for this look",
            options=list(clothing_options.keys())
        )

        save_clicked = st.form_submit_button("♡ Save This Outfit")

        if save_clicked:
            if not outfit_name.strip():
                st.warning("Please give your outfit a name.")
            elif not chosen_clothes:
                st.warning("Please select at least one clothing item.")
            else:
                database.save_outfit(
                    outfit_name.strip(),
                    outfit_occasion,
                    chosen_clothes
                )
                st.success("Your outfit has been saved! 💗")
                st.rerun()
    else:
        st.info("Add clothing items before saving an outfit.")

st.subheader("♡ Your Outfit Collection")

saved_outfits = database.get_outfits()

if saved_outfits:
    for outfit in saved_outfits:
        with st.container(border=True):
            st.markdown(f"### ✨ {outfit['name']}")
            st.caption(f"Occasion: {outfit['occasion']}")

            for clothing_id in outfit["items"]:
                matching_item = next(
                    (
                        item for item in database.get_clothes()
                        if item["id"] == clothing_id
                    ),
                    None
                )

                if matching_item:
                    st.write(
                        f"♡ {matching_item['name']} "
                        f"({matching_item['category']})"
                    )

            if st.button(
                "🗑️ Delete Outfit",
                key=f"delete_outfit_{outfit['id']}"
            ):
                database.delete_outfit(outfit["id"])
                st.rerun()
else:
    st.info("Your saved looks will appear here. Create your first outfit above!")

# 💖 My Saved Outfits
st.divider()

# 💖 My Saved Outfits
st.divider()

st.header("💖 My Saved Outfits")
st.caption("Your favorite looks, saved in one place.")

saved_outfits = database.get_outfits()
all_saved_clothes = database.get_clothes()

if saved_outfits:
    outfit_columns = st.columns(2)

    for index, outfit in enumerate(saved_outfits):
        with outfit_columns[index % 2]:
            with st.container(border=True):
                st.subheader(f"✨ {outfit['name']}")

                st.caption(f"♡ {outfit['occasion']}")

                st.write("**Your outfit pieces**")

                outfit_items = outfit.get("items", [])

                for clothing_name in outfit_items:
                    matching_item = next(
                       (
                            item for item in all_saved_clothes
                            if (
                               f"{item['name']} ({item['category']})"
                               == clothing_name
                            )
                ),
                None
                )

                if matching_item:
                    if matching_item.get("image"):
                        st.image(
                            matching_item["image"],
                            width=160
                        )

                    st.write(f"👗 {matching_item['name']}")
                    st.caption(
                        f"Category: {matching_item['category']}"
                    )
                else:
                    st.write(f"👗 {clothing_name}")

                if st.button(
                    "🗑️ Delete Outfit",
                    key=f"delete_saved_outfit_{outfit['id']}"
                ):
                    database.delete_outfit(outfit["id"])
                    st.rerun()

else:
    st.info(
        "Your saved looks will appear here. "
        "Create your first outfit above! ♡"
    )

st.divider()
st.caption("♡ Smart Wardrobe | Your personal style diary")

# 🌦️ Live Weather
st.divider()
st.header("🌦️ Weather-Based Outfit Ideas")
st.caption("Check your city's weather before choosing your look.")
wardrobe_for_weather = database.get_clothes()

city = st.text_input(
    "Enter your city",
    value="Prayagraj",
    key="weather_city"
)

if city.strip():
    corrected_city = correct_city_spelling(city.strip())

    if corrected_city and corrected_city.lower() != city.strip().lower():
        st.info(f"📍 Using the city name: **{corrected_city}**")

    if corrected_city:
        weather = get_live_weather(corrected_city)
    else:
        weather = get_live_weather(city.strip())

    if weather:
            temperature = weather["main"]["temp"]
            feels_like = weather["main"]["feels_like"]
            condition = weather["weather"][0]["description"].title()

            st.subheader(f"📍 {corrected_city}")

            col1, col2 = st.columns(2)

            with col1:
                st.metric(
                    "🌡️ Temperature",
                    f"{temperature:.1f} °C",
                    f"Feels like {feels_like:.1f} °C"
                )

            with col2:
                st.metric(
                    "🌤️ Conditions",
                    condition
                )

            st.write("### 👗 What to wear")

            if temperature >= 30:
                suitable_categories = ["T-shirts", "Shirts", "Dresses"]
                st.info("☀️ It's hot! Let's find something light and breathable.")

            elif temperature >= 20:
                suitable_categories = [
                    "T-shirts", "Shirts", "Jeans", "Trousers", "Dresses"
                ]
                st.info("🌸 The weather is mild. Let's find a comfortable outfit.")

            elif temperature >= 10:
                suitable_categories = [
                    "Shirts", "Trousers", "Jeans", "Traditional"
                ]
                st.info("🧥 It's cool. Consider comfortable clothes and layering.")

            else:
                suitable_categories = [
                    "Shirts", "Trousers", "Jeans", "Traditional"
                ]
                st.info("❄️ It's cold. Choose warm clothes and layer up.")

            if "rain" in condition.lower() or "drizzle" in condition.lower():
                st.warning(
                    "☔ Rain is possible based on current conditions. "
                    "Consider a raincoat and water-resistant footwear."
                )

                        # 👗 Recommend clothes from your wardrobe
            matching_clothes = [
                item for item in wardrobe_for_weather
                if item["category"] in suitable_categories
            ]

            if matching_clothes:
                st.write("### 🧥 Clothes available in your wardrobe")

                for item in matching_clothes:
                    st.write(f"👚 **{item['name']}** — {item['category']}")
            else:
                st.info(
                    "No matching clothes found in your wardrobe yet. "
                    "Try adding some clothes first!"
                )
    else:
        st.warning("Please enter a city name.")



# 👗 Smart Outfit Generator

st.divider()
st.header("✨ Smart Outfit Generator")

occasion = st.selectbox(
    "Where are you going?",
    occasions,
    key="outfit_occasion"
)

if st.button("✨ Generate My Outfit"):
    st.session_state["generate_outfit"] = True

if st.session_state.get("generate_outfit", False):
    st.session_state["generate_outfit"] = False
    
    all_clothes = database.get_clothes()

    tops = [
        item for item in all_clothes
        if item["category"] in ["Shirts", "T-shirts"]
    ]

    bottoms = [
        item for item in all_clothes
        if item["category"] in ["Jeans", "Trousers"]
    ]

    dresses = [
        item for item in all_clothes
        if item["category"] == "Dresses"
    ]

    traditional = [
        item for item in all_clothes
        if item["category"] == "Traditional"
    ]

    footwear = [
        item for item in all_clothes
        if item["category"] == "Footwear"
    ]

    accessories = [
        item for item in all_clothes
        if item["category"] == "Accessories"
    ]

    # Choose an outfit based on the occasion
    if occasion in ["College", "Casual Outing", "Travel"]:
        preferred_tops = [
            item for item in tops
            if item["category"] == "T-shirts"
        ]
        selected_tops = preferred_tops or tops
        selected_bottoms = bottoms

    elif occasion == "Office":
        preferred_tops = [
            item for item in tops
            if item["category"] == "Shirts"
        ]
        preferred_bottoms = [
            item for item in bottoms
            if item["category"] == "Trousers"
        ]
        selected_tops = preferred_tops or tops
        selected_bottoms = preferred_bottoms or bottoms

    else:  # Party, Wedding, Festival
        selected_tops = []
        selected_bottoms = []

    st.subheader(f"Your outfit for {occasion} 👗")

    if occasion in ["Party", "Wedding", "Festival"]:
        festive_options = dresses + traditional

        if festive_options:
            selected = random.choice(festive_options)
            st.write("### 👗 Outfit")
            st.write(
                f"**{selected['name']}** — {selected['category']}"
            )

        elif tops and bottoms:
            selected_top = random.choice(tops)
            selected_bottom = random.choice(bottoms)

            st.write("### 👚 Top")
            st.write(
                f"**{selected_top['name']}** — {selected_top['category']}"
            )

            st.write("### 👖 Bottom")
            st.write(
                f"**{selected_bottom['name']}** — {selected_bottom['category']}"
            )

        else:
            st.info("Add more clothes to generate this outfit.")

    elif selected_tops and selected_bottoms:
        selected_top = random.choice(selected_tops)
        selected_bottom = random.choice(selected_bottoms)

        st.write("### 👚 Top")
        st.write(
            f"**{selected_top['name']}** — {selected_top['category']}"
        )

        st.write("### 👖 Bottom")
        st.write(
            f"**{selected_bottom['name']}** — {selected_bottom['category']}"
        )

    elif dresses:
        selected = random.choice(dresses)
        st.write("### 👗 Outfit")
        st.write(f"**{selected['name']}** — {selected['category']}")

    elif traditional:
        selected = random.choice(traditional)
        st.write("### 🪷 Traditional Outfit")
        st.write(
            f"**{selected['name']}** — {selected['category']}"
        )

    else:
        st.info("Add more clothes to generate an outfit.")

    if footwear:
        selected_footwear = random.choice(footwear)
        st.write("### 👟 Footwear")
        st.write(
            f"**{selected_footwear['name']}** — {selected_footwear['category']}"
        )

    if accessories:
        selected_accessory = random.choice(accessories)
        st.write("### 👜 Accessory")
        st.write(
            f"**{selected_accessory['name']}** — {selected_accessory['category']}"
        )