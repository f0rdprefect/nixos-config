import datetime
import sys

def get_date_range(week_number):
    year = datetime.date.today().year
    start_date = datetime.datetime.strptime(f'{year}-W{week_number}-1', "%Y-W%W-%w").date()
    end_date = start_date + datetime.timedelta(days=6)
    return start_date, end_date

if len(sys.argv) != 2:
    print("Usage: python script.py <week_number>")
    sys.exit(1)

week_number = int(sys.argv[1])
start_date, end_date = get_date_range(week_number)
date_range = f"{start_date} - {end_date}"
print(date_range)
