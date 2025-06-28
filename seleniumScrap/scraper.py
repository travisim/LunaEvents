import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import csv

def scrape_luma_events():
    """
    Scrapes event data from https://lu.ma/singapore using Selenium.

    Returns:
        list: A list of dictionaries, where each dictionary represents an event.
    """
    # # Set up the Chrome driver
    # options = webdriver.ChromeOptions()
    # options.add_argument("--headless")  # Run in headless mode
    # options.add_argument("--no-sandbox")
    # options.add_argument("--disable-dev-shm-usage")
    # path = "/Users/k/Downloads/cody/seleniumScrap/chromedriver"
    # service = Service(executable_path=path)
    driver = webdriver.Chrome()

    url = "https://lu.ma/singapore"
    driver.get(url)

    # Wait for event cards to load (up to 15 seconds)
    try:
        WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, ".card-wrapper"))
        )
    except Exception as e:
        print("Event cards did not load:", e)
        driver.quit()
        return []

    events = []

    # Find all event card elements (updated selector)
    event_cards = driver.find_elements(By.CSS_SELECTOR, ".card-wrapper")
    print(f"Found {len(event_cards)} event cards.")
    for card in event_cards:
        try:
            # Updated selectors based on provided HTML
            title = card.find_element(By.CSS_SELECTOR, "h3").text
            # Date and time are in .event-time span and possibly elsewhere
            try:
                time_text = card.find_element(By.CSS_SELECTOR, ".event-time span").text
            except:
                time_text = ""
            try:
                date = card.find_element(By.CSS_SELECTOR, ".event-time").text.replace(time_text, "").strip()
            except:
                date = ""
            # Location may not always be present
            try:
                location = card.find_element(By.CSS_SELECTOR, ".attribute .text-ellipses").text
            except:
                location = ""
            link = card.find_element(By.CSS_SELECTOR, "a.event-link").get_attribute("href")

            # New: Extract cover image URL
            try:
                cover_img = card.find_element(By.CSS_SELECTOR, ".cover-image img").get_attribute("src")
            except:
                cover_img = ""

            # New: Extract organizer
            try:
                organizer = card.find_element(By.CSS_SELECTOR, ".attribute .text-ellipses .nowrap").text
            except:
                organizer = ""

            # New: Extract status/price
            try:
                status = card.find_element(By.CSS_SELECTOR, ".status-or-price .pill-label").text
            except:
                status = ""

            events.append({
                "title": title,
                "date": date,
                "time": time_text,
                "location": location,
                "organizer": organizer,
                "status": status,
                "cover_image": cover_img,
                "link": link
            })
        except Exception as e:
            print(f"Error scraping an event card: {e}")

    driver.quit()
    return events

if __name__ == "__main__":
    scraped_events = scrape_luma_events()
    for event in scraped_events:
        print(event)
    # Save to CSV
    if scraped_events:
        csv_file = "luma_events.csv"
        fieldnames = [
            "title", "date", "time", "location",
            "organizer", "status", "cover_image", "link"
        ]
        with open(csv_file, "w", newline='', encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            for event in scraped_events:
                writer.writerow(event)
        print(f"Saved {len(scraped_events)} events to {csv_file}")