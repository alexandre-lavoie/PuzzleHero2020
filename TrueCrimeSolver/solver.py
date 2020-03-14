import pwn
from difflib import SequenceMatcher

def similar(a, b):
    return SequenceMatcher(None, a, b).ratio()

ADDRESS = '167.99.191.188'
PORT = 6344

conn = pwn.remote(ADDRESS, PORT)

# Database load
conn.recvline()

numberOfLine = int(conn.recvline().decode('utf-8').split(" ")[0])

# Tentatives
max_calls = int(conn.recvline().decode('utf-8').split(" ")[2])

conn.recvline()

header = [x.strip() for x in conn.recvline().decode('utf-8').split("|")][1:]

# Line
conn.recvline()

people = []

for _ in range(numberOfLine):
    people.append([x.strip() for x in conn.recvline().decode('utf-8').split("|")])

traits = []

for field in header[:max_calls - 1]:
    conn.sendline(field)

    traits.append(conn.recvline(timeout=5).decode('utf-8').strip())

score_people = []

for person in people:
    similar_sum = sum([similar(trait, person[i + 1]) for i, trait in enumerate(traits)])

    score_people.append((similar_sum, person))

score_people = sorted(score_people, key=lambda x: x[0])

conn.sendline(score_people[-1][1][0])

key = conn.recvline(timeout=5).decode('utf-8').strip()

print(key)

conn.close()