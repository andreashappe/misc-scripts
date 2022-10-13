import argparse
import csv
import requests
import multiprocessing as mp

from bs4 import BeautifulSoup

def get_text_file_for(domain):
    try:
        r = requests.get("https://" + domain)
    except:
        print(domain + ": connection error for ")
        return

    if r.status_code >= 200 and r.status_code < 300:
        html_text = r.text
        cleantext = BeautifulSoup(html_text, "lxml").text

        filename = f'output/{domain.replace(" ", "_")}.txt'
        with open(filename, 'w') as f:
            f.write(cleantext)
    else:
        print(domain + ": status code invalid: " + str(r.status_code))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Take an textfile with URLs and download all html files, convert them to text and put them into the output/ directory")
    parser.add_argument("csv_file", help="a traffic log CSV file", type=str)
    args = parser.parse_args()

    # read file into array
    urls = []
    with open(args.csv_file) as f:
        reader = csv.reader(f, delimiter=',', quotechar='"')
        for row in reader:
            if row[1] == "Domain":
                continue
            urls.append(row[1])

    pool = mp.Pool(mp.cpu_count())
    results = pool.map(get_text_file_for, urls)
    pool.close()