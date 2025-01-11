.data 
    welcome_msg:          .asciiz "Welcome to the Guess Game!\n\n"
    option_msg:           .asciiz "Please choose your game:\n\n(1) Guess the Number\n(2) Guess the Word\n\nEnter your choice (1 or 2): "
    guess_number_msg:     .asciiz "\nYou have chosen to play 'Guess the Number'. Let's get started!\n\n"
    guess_word_msg:       .asciiz "\nYou have chosen to play 'Guess the Word'. Let's get started!\n\n"
    scrambled_word:       .asciiz "Scrambled word: ipms\n"   # Scrambled version of "mips"
    guess_prompt:         .asciiz "Enter your guess: "
    word_success:         .asciiz "Congratulations! You guessed the word correctly!\n\n"
    word_fail:            .asciiz "Incorrect guess. Please try again.\n\n"
    out_of_trials:        .asciiz "You have no trials left. Game Over.\n\n"
    play_again_prompt:    .asciiz "Would you like to play again? (Y/N): "
    good_bye_msg:         .asciiz "\nThank you for playing! Keep up the great work, and remember: Success is just around the corner. Goodbye!\n"

    buffer:               .space 32  # Buffer to store user input
    hidden_word:          .asciiz "mips" # Correct word for the "guess the word" game

.text
    .globl main
main:
    # Show a welcoming message to the user
    li $v0, 4
    la $a0, welcome_msg
    syscall

    # Ask the user to choose between two games
    li $v0, 4
    la $a0, option_msg
    syscall

    li $v0, 5
    syscall                # Read user input (1 or 2)
    move $t0, $v0          # Store the choice in $t0

    # If the user selects '1', start guessing the number game
    beq $t0, 1, guess_the_number
    # If the user selects '2', start guessing the word game
    beq $t0, 2, guess_the_word
    # If the user didn't choose 1 or 2, prompt again
    j main

# Game 1: Guess the Number (A basic demonstration of number guessing)
guess_the_number:
    li $v0, 4
    la $a0, guess_number_msg
    syscall

    # Set the number of trials (5 trials)
    li $t1, 5  
    # Define the correct number to guess (in this case, 42)
    li $t2, 42  

guess_number_loop:
    # Ask the user for a guess
    li $v0, 4
    la $a0, guess_prompt
    syscall

    # Read the user's input
    li $v0, 5
    syscall
    move $t3, $v0  # Store the user's guess

    # Check if the guess is correct (is it 42?)
    beq $t3, $t2, guess_number_correct

    # If the guess is incorrect, inform the user
    li $v0, 4
    la $a0, word_fail
    syscall

    # Decrease the number of trials by 1
    subi $t1, $t1, 1
    bgtz $t1, guess_number_loop  # If trials left, loop

    # If out of trials, inform the user and end the game
    li $v0, 4
    la $a0, out_of_trials
    syscall
    j play_again

guess_number_correct:
    # If the guess is correct, congratulate the user
    li $v0, 4
    la $a0, word_success
    syscall
    j play_again

# Game 2: Guess the Word
guess_the_word:
    li $v0, 4
    la $a0, guess_word_msg
    syscall

    # Initialize number of trials (5)
    li $t1, 5

guess_word_loop:
    # Display the scrambled word
    li $v0, 4
    la $a0, scrambled_word
    syscall

    # Prompt for user input
    li $v0, 4
    la $a0, guess_prompt
    syscall

    # Read user input for the guess
    li $v0, 8
    la $a0, buffer
    li $a1, 32  # Max input length
    syscall

    # Compare the input with the correct word "mips"
    la $t3, hidden_word     # Load address of correct word ("mips")
    la $t4, buffer          # Load address of user input

    # Initialize a flag to check if the guess is correct (0 = correct)
    li $t5, 0

compare_chars:
    lb $t6, 0($t3)          # Load byte from correct word
    lb $t7, 0($t4)          # Load byte from user input

    # If characters match, continue checking next character
    beq $t6, $t7, next_char

    # If mismatch, set flag to 1 (incorrect)
    li $t5, 1               # Set mismatch flag (1 = incorrect)
    j end_compare

next_char:
    addi $t3, $t3, 1        # Move to next character in correct word
    addi $t4, $t4, 1        # Move to next character in user input
    lb $t6, 0($t3)          # Load next character from correct word
    bnez $t6, compare_chars # If not end of string, continue comparing

end_compare:
    # If flag is 0, the word is correct
    beq $t5, 0, word_correct  # If flag is 0, input is correct

    # Incorrect guess
    li $v0, 4
    la $a0, word_fail
    syscall
    subi $t1, $t1, 1         # Decrease trials count
    bgtz $t1, guess_word_loop # If trials left, loop again

    # If out of trials, end game
    li $v0, 4
    la $a0, out_of_trials
    syscall
    j play_again

word_correct:
    # If the word is guessed correctly, congratulate the user
    li $v0, 4
    la $a0, word_success
    syscall
    j play_again

# Ask user if they want to play again
play_again:
    li $v0, 4
    la $a0, play_again_prompt
    syscall

    # Read user response
    li $v0, 8
    la $a0, buffer
    li $a1, 32
    syscall

    # Convert the input to uppercase for uniformity
    lb $t0, buffer          # Load the first byte of the input
    li $t1, 97              # ASCII for lowercase 'a'
    li $t2, 122             # ASCII for lowercase 'z'

    # Check if the input is lowercase
    blt $t0, $t1, check_upper
    bgt $t0, $t2, check_upper

    # Convert to uppercase
    subi $t0, $t0, 32

check_upper:
    # Now compare the uppercase version of the input with 'Y' or 'N'
    li $t1, 89              # ASCII for 'Y'
    li $t2, 78              # ASCII for 'N'

    # If user enters 'Y' (upper or lower), restart the game
    beq $t0, $t1, main
    # If user enters 'N' (upper or lower), exit the program
    beq $t0, $t2, exit

    # If invalid input, ask again
    j play_again

# Motivational farewell message
exit:
    li $v0, 4
    la $a0, good_bye_msg
    syscall

    li $v0, 10            # Exit the program
    syscall