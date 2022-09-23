import argparse
import re
import xlsxwriter

# which firewall rule fields to add to the resulting excel sheet.
directives = [
    "name", "uuid", "srcintf", "dstintf", "srcaddr", "dstaddr", "status", "action", "comments", "internet-service-src", "service"
]

# which ip-range fields to add to the resulting excel sheet.
address_directives = [
        "uuid", "type", "comment", "associated-interface", "subnet", "allow-routing", "start-ip", "end-ip"
]

def extract_ticket_ids(policy:dict[str, str], fields:list[str]) -> str:
    ''' go through a firewall policy's fields and check and extract ticket-ids (7-8 digit integers)'''
    ticket_ids = []
    for field in fields:
        if policy[field]:
            ticket_ids += list(re.findall(r'\d{7,8}', policy[field]))
    return " ".join(ticket_ids)

def capture_set(line, target, directives):
    ''' this is intended to help parsing "set <name> <value>" lines.

    a new key-value pair <key>:<value> is added to the collection target.
    directives contains all accepted <name>
    '''

    parts = line.split(" ", 2)
    if parts[1] in directives:
        target[parts[1]] = parts[2]

def parse_firewall_addresses(f, debug_out):
    '''parse a address configuration.

    forward through the file-handle and extract address information
    specific data until a "end" is found.'''

    address = None
    addresses = []

    line = f.readline().strip()
    while line != "end":
        while not (line.startswith("edit") or line.startswith("end")):
            line = f.readline().strip()
        if line.startswith("edit"):
            # start a new address
            address = { "id" : line.split(" ")[1]}
        while line != "next" and line != "end":
            # capture data
            line = f.readline().strip()
            if line.startswith("set"):
                capture_set(line, address, address_directives)
        if line == "next":
            # store policy
            if debug_out:
                print(str(address))
            addresses.append(address)
    return addresses

def parse_firewall_rules(f, debug_out):
    '''parse firewall configuration.

    forward through the file-handle and extract firewall rule
    specific data until a "end" is found.'''

    policy = None
    policy_set = []
    ticket_counter = 0

    line = f.readline().strip()
    while line != "end":
        while not (line.startswith("edit") or line.startswith("end")):
            line = f.readline().strip()
        if line.startswith("edit"):
            # start a new policy
            policy = { "id": line.split(" ")[1]}
        while line != "next" and line != "end":
            # capture data
            line = f.readline().strip()
            if line.startswith("set"):
                capture_set(line, policy, directives)
        if line == "next":
            # search for ticket ids
            policy["ticket_ids"] = extract_ticket_ids(policy, ["comments", "name"])
            if len(policy["ticket_ids"]) > 6:
                ticket_counter += 1

            # store policy
            policy_set.append(policy)
            if debug_out:
                print(str(policy))
    return policy_set, ticket_counter

def parse_config_file(filename:str, output_fw_policies:bool, output_ip_objects:bool):
    '''go through a config file and extract both firewall rules as well as address (ip) information'''

    policies = []
    addresses = []

    counter = 0
    tickets = 0

    # parse data
    with open(filename) as f:
        while True:
            line = f.readline()

            if not line:
                break

            line = line.strip()
            if line == "config firewall policy":
                extracted_policies, number_tickets = parse_firewall_rules(f, output_fw_policies)
                counter += len(extracted_policies)
                tickets += number_tickets
                policies.append(extracted_policies)
            elif line == "config firewall address":
                addresses.append(parse_firewall_addresses(f, output_ip_objects))

    print("different firewalls policies: " + str(len(policies)))
    print("firewall rules: " + str(counter))
    print("with ticket_id: " + str(tickets))

    return policies, addresses

def output_excel_sheet(output_file_name, policies, addresses):
    ''' write the extracted data into an excel file.

    Each firewall rule as well as well as each associated ip address information
    will be writen to different worksheet'''

    workbook = xlsxwriter.Workbook(output_file_name)
    for policy in policies:
        worksheet = workbook.add_worksheet()
        row = 1
        for entry in policy:
            worksheet.write_row(row, 0, list(map(lambda e: entry.get(e, ""), directives)) + [entry["ticket_ids"]])
            row += 1

    for address in addresses:
        worksheet = workbook.add_worksheet()
        row = 1
        for entry in address:
            worksheet.write_row(row, 0, [entry["id"]] + list(map(lambda e: entry.get(e, ""), address_directives)))
            row += 1
    workbook.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Parse a fortinet config file and output an excel sheet containing firewall policies as well as ip-ranges")
    parser.add_argument("input_config_file", help="the fortinet config file to convert", type=str)
    parser.add_argument("output_excel_file", help="the resulting excel sheet", type=str)
    parser.add_argument("--output-fw-policies", help="output (debug) firewall policy objects to stdout", action="store_true")
    parser.add_argument("--output-ip-objects", help="output (debug) ip objects to stdout", action="store_true")
    args = parser.parse_args()
    
    policies, addresses = parse_config_file(args.input_config_file, args.output_fw_policies, args.output_ip_objects)
    output_excel_sheet(args.output_excel_file, policies, addresses)
