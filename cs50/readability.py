# For problem set 6 https://cs50.harvard.edu/x/2022/psets/6/credit/
# Returns the readability grade of a string calculated using its Coleman–Liau index score

from cs50 import get_string
import re


def main():

    # Ask user for input text
    while True:
        text = get_string("Input Text: ")
        if len(text) > 0:
            break

    # Grade the text using its Coleman–Liau index score
    grade(colemanliau_index(text))


def count_letters(text):
    # regex for counting letters, individual word-characters per capture group
    re_letters = re.compile(r'\w')
    # Find all letters in the text
    letters = re.findall(re_letters, text)
    # return number of letters
    return len(letters)


def count_words(text):
    # regex for counting words, at least 1 non-whitespace character per capture group
    re_words = re.compile(r'\S+')
    # Find all words in the text
    words = re.findall(re_words, text)
    # return number of words
    return len(words)


def count_sentences(text):
    # regex for counting sentences, ! or . or ? per capture group
    re_sentences = re.compile(r'!|\.|\?')
    # Find all sentences in the text
    sentences = re.findall(re_sentences, text)
    # return number of sentences
    return len(sentences)


def colemanliau_index(text):
    # Calculate number of words in the text
    words = count_words(text)
    # Calculate L coefficient, the average number of letters per 100 words in the text
    L = count_letters(text) / words * 100
    # Calculate S coefficient, the average number of sentences per 100 words in the text
    S = count_sentences(text) / words * 100
    # calculate and return the coleman-liau index of the text
    return 0.0588 * L - 0.296 * S - 15.8


def grade(index):
    # prints the grade of a string calculated from the index
    if index < 1:
        print("Before Grade 1")
    elif index < 16:
        print("Grade", round(index))
    else:
        print("Grade 16+")


main()
