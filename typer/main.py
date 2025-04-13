import typer

print("Welcome to the Speed Typing Challenge!")
print("Type the words and hit enter within the time limit!")

level = 1
max_levels = 5

while level <= max_levels:
    typer.level_intro(level)
    mode, num_words, time_limit = typer.get_level_config(level)
    
    success = True
    for round_num in range(1, 4):  # Three rounds per level
        print(f"Round {round_num}")
        phrase = typer.pick_random_words(num_words, mode)
        if not typer.play_round(phrase, time_limit):
            print("Oops! You missed that one.")
            success = False
            break

    if not success:
        break

    print(f"✅ Level {level} complete!\n")
    level += 1

typer.game_summary(level)
print("🔥 Great job! Get ready for the next level.")
