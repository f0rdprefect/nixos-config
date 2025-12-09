import datetime
import sys

def get_week_number(date_string):
    try:
        date = datetime.datetime.strptime(date_string, '%Y-%m-%d').date()
    except ValueError:
        try:
            date = datetime.datetime.strptime(f'{datetime.date.today().year}-{date_string}', '%Y-%m-%d').date()
        except ValueError:
            print('Invalid date format. Please use yyyy-mm-dd or mm-dd.')
            sys.exit(1)
    return date.isocalendar()[1]

if len(sys.argv) != 2:
    print("Usage: python script.py <date>")
    sys.exit(1)

week_number = get_week_number(sys.argv[1])
print(week_number)
