"""Plays a game where the user types random words within a time limit."""

import random
import time
import word_bank

def play_round(words, seconds):
    """Returns True if the user successfully completed the round."""
    # Run a stopwatch for the time it takes the user to respond.
    start = time.time()
    response = input("(" + str(seconds) + " seconds) " + words + "\n")
    stop = time.time()

    # Fail the round if a word is mispelled or if time runs out.
    within_time_limit = stop - start < seconds
    return response == words and within_time_limit

def pick_random_words(num_words, word_length):
    """Returns a random phrase containing the given number of words.""" 
    words = ""
    for word in range(num_words):
        word = get_random_word(word_length)
        words = words + " " + word

    return words.strip()

def get_random_word(mode):
    """Returns a random word with a word length based on the given mode."""
    if mode == "hard":
        words = word_bank.hard_words
    elif mode == "medium":
        words = word_bank.medium_words
    else:
        words = word_bank.easy_words

    return random.choice(words)

def get_level_config(level):
    """Returns (word_mode, num_words, time_limit) for a given level."""
    if level == 1:
        return ("easy", 1, 10)
    elif level == 2:
        return ("easy", 2, 9)
    elif level == 3:
        return ("medium", 2, 8)
    elif level == 4:
        return ("hard", 3, 7)
    elif level == 5:
        return ("hard", 4, 6)
    else:
        return ("hard", 4, 5)  # Extra challenge mode

def level_intro(level):
    print(f"\n🚀 Level {level} begins! Get ready...\n")

def game_summary(level_reached):
    print("\n🎉 Game Over!")
    print(f"You reached level {level_reached}. Well done!")

