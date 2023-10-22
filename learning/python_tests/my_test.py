import datetime
from unittest.mock import Mock
import unittest

# Save a couple of test days
tuesday = datetime.datetime(year=2019, month=1, day=1)
saturday = datetime.datetime(year=2019, month=1, day=5)

datetime = Mock()


def is_weekday():
    today = datetime.datetime.today()
    print(str(today.weekday()))
    # Python's datetime library treats Monday as 0 and Sunday as 6
    return (0 <= today.weekday() < 5)


class TestCalendar(unittest.TestCase):
    def test_is_weekday(self):
        # Test a connection timeout
        datetime.datetime.today.return_value = tuesday
        self.assertTrue(is_weekday())


if __name__ == '__main__':
    unittest.main()
