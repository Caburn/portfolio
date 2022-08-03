# For problem set  https://cs50.harvard.edu/x/2022/psets/6/credit/
# Asks the user for a credit card number and checks if it is valid using 
# Luhn's algorithm and determines which card provider it belongs to 

from cs50 import get_int
import re


def main():

    # Ask user for input number as an int and stores it as a str
    card = str(get_int("Number: "))

    # Regex patters for Amex, Mastercard and Visa that check for the correct
    # starting numbers and correct lengths.
    re_amex = re.compile(r'^(?:34|37)\d{13}$')
    re_mastercard = re.compile(r'^5[1-5]\d{14}$')
    re_visa = re.compile(r'^4(?:\d{12}|\d{15})$')

    # First check if number is valid accoarding to the Luhn algorithm
    if (luhn(card)):
        # Check if card is valid amex number and print
        if (re.search(re_amex, card)):
            print("AMEX")
        # Check if card is valid mastercard number and print
        elif (re.search(re_mastercard, card)):
            print("MASTERCARD")
        # Check if card is valid visa number and print
        elif (re.search(re_visa, card)):
            print("VISA")
        # Otherwise the card is invalid
        else:
            print("INVALID")
    # Otherwise the card is invalid
    else:
        print("INVALID")


def luhn(number):
    # Runs the Luhn algorithm on the number and return True if the number is valid

    # First convert the number to a string, just in case this function is not given a string
    number = str(number)

    # Step 1
    # Initialise empty digits string
    digits = ""
    # Loop over every other digit in the number, starting with the number's second to last digit
    for digit in number[-2::-2]:
        # Multiply the digit by 2 and add it to the string of digits
        digits += str(int(digit) * 2)

    # Step 2
    # Initialise sum int of 0
    sum = 0
    # Loop over all digits in from the result of Step 1
    for digit in digits:
        # Add each digit to the sum
        sum += int(digit)

    # Step 3
    # Loop over every other digit in the number, startign with the number's last digit
    for digit in number[::-2]:
        # Add each digit to the sum
        sum += int(digit)

    # Step 4
    # If the sum ends in a 0 then return True, otherwise return False
    if sum % 10 == 0:
        return True
    else:
        return False


main()
