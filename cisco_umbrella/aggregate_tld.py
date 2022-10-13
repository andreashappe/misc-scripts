import argparse
import csv
import tldextract

def aggregate(source, destination):
    results = {}

    with open(source) as f:
        reader = csv.reader(f, delimiter=',', quotechar='"')
        for row in reader:
            if row[1] == "Domain":
                continue
            tld = tldextract.extract(row[1]).registered_domain
            counter = int(row[2])

            if tld in results:
                if not row[3] in results[tld]["cat"]:
                    results[tld]["cat"].append(row[3])
                results[tld]["counter"] += counter
            else:
                results[tld] = { 'counter' : counter, 'cat': [row[3]] }
        
    print("counter: " + str(len(results)))

    with open(destination, 'w') as f:
        output = csv.writer(f, delimiter=',', quotechar='"', quoting = csv.QUOTE_MINIMAL)
        for i in results:
            output.writerow([i, results[i]["counter"], ", ".join(results[i]["cat"])])

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Take an CSV file, merge TLDs and output new excel file")
    parser.add_argument("input_csv_file", help="the log file to compact", type=str)
    parser.add_argument("output_csv_file", help="the resulting log file", type=str)
    args = parser.parse_args()
    
    aggregate(args.input_csv_file, args.output_csv_file)
