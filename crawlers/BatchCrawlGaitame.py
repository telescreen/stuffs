import os.path
import time
import csv
import logging

import selenium
from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By


END_DATE = '20080430'
URL = "https://www.gaitame.com/markets/calendar/"

logger = logging.getLogger(__name__)

def daily_economic_data():
    logger.info("Openning chrome")
    service = ChromeService(executable_path=ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service)
    driver.get(URL)
    time.sleep(0.5)
    driver.switch_to.frame('parentframe')

    table = driver.find_element(By.ID, 'calendar-table')
    monthly_label = driver.find_element(By.XPATH, '/html/body/div/div/div/div[3]/div/div[1]/div/label[1]/label')
    monthly_label.click()

    selected_label = driver.find_element(By.XPATH, '/html/body/div/div/div/div[2]/ul/li[2]')
    time.sleep(0.5)

    logger.info("Start scrapping data")
    # In order: date, time, country, indicator, importance, previous value, expected value, result
    while selected_label.get_attribute('value') != END_DATE:
        logger.info("Scapping data for " + selected_label.get_attribute('value'))
        year = selected_label.get_attribute('value')[:4]
        current_date = ''
        # Processing the whole page for selected month
        for row in table.find_elements(By.CSS_SELECTOR, "tbody > tr"):
            r = []
            cols = row.find_elements(By.CSS_SELECTOR, "td")
            if cols[0].text != '':
                current_date = cols[0].text[:-3]
            r.append(year+'/'+current_date)
            r.append(cols[1].text)
            try:
                img = cols[2].find_element(By.TAG_NAME, "img")
                r.append(img.get_attribute("title"))
            except selenium.common.exceptions.NoSuchElementException:
                pass
            r.append(cols[3].text)
            try:
                iimg = cols[4].find_element(By.TAG_NAME, "img")
                r.append('1' if iimg.get_attribute("class") == 'importances_mid' else '2')
            except selenium.common.exceptions.NoSuchElementException:
                r.append('0')
                pass
            r.append(cols[5].text)
            r.append(cols[6].text)
            r.append(cols[7].text)
            yield r

        page_left = driver.find_element(By.XPATH, '/html/body/div/div/div/div[2]/div[1]')
        page_left.click()
        time.sleep(0.5)
        selected_label = driver.find_element(By.XPATH, '/html/body/div/div/div/div[2]/ul/li[2]')
        selected_label.click()
        time.sleep(0.5)
    driver.quit()


if __name__ == '__main__':
    with open('gaitame_economic_calendar.csv', 'w') as f:
        writer = csv.writer(f)
        for daily_data in daily_economic_data():
            writer.writerow(daily_data)
