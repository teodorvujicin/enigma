#! /usr/bin/env bash

function encrypt_message() {
    message_to_encrypt=$1
    encrypted_message=""
    for (( i=0; i<${#message_to_encrypt}; i++ )); do
        current_character="${message_to_encrypt:$i:1}"

        if [ "$current_character" == " " ]; then
            encrypted_message+=" "
            continue
        fi

        current_character_ascii=$(printf "%d" "'$current_character")
        shifted_ascii_character=$(( (current_character_ascii - 65 + 3 + 26) % 26 + 65 ))
        shifted_character=$(printf "\\$(printf '%03o' "$shifted_ascii_character")")
        encrypted_message+=$shifted_character
    done
    echo "$encrypted_message"
}

function decrypt_message() {
    encrypted_message=$1
    message_to_decrypt=""
    for (( i=0; i<${#encrypted_message}; i++ )); do
        current_character="${encrypted_message:$i:1}"

        if [ "$current_character" == " " ]; then
            message_to_decrypt+=" "
            continue
        fi

        current_character_ascii=$(printf "%d" "'$current_character")
        shifted_ascii_character=$(( (current_character_ascii - 65 - 3 + 26) % 26 + 65 ))
        shifted_character=$(printf "\\$(printf '%03o' "$shifted_ascii_character")")
        message_to_decrypt+=$shifted_character
    done
    echo "$message_to_decrypt"
}

function say_welcome() {
    echo "Welcome to the Enigma!"
}

function say_goodbye() {
    echo "See you later!"
}

function print_menu() {
    echo "0. Exit"
    echo "1. Create a file"
    echo "2. Read a file"
    echo "3. Encrypt a file"
    echo "4. Decrypt a file"
    echo "Enter an option:"
}

function ask_for_filename() {
    echo "Enter the filename:"
}

function ask_for_message() {
    echo "Enter a message:"
}

function say_invalid_option() {
    echo "Invalid option!"
}

function check_filename_validity() {
    filename=$1
    valid_filename_pattern="^[A-Za-z.]+$"
    if [[ "$filename" =~ $valid_filename_pattern ]]; then
        echo 1
    else
        echo 0
    fi
}

function check_message_validity() {
    message=$1
    valid_message_pattern="^[A-Z ]+$"
    if [[ "$message" =~ $valid_message_pattern ]]; then
        echo 1
    else
        echo 0
    fi
}

function encrypt_file() {
    filename="$1"
    password="$2"
    openssl enc -aes-256-cbc -in "$filename" -out "$filename.enc" -pbkdf2 -pass "pass:$password"
    rm "$filename"
    echo "Success"
}

function decrypt_file() {
    filename="$1"
    password="$2"
    openssl enc -d -aes-256-cbc -in "$filename" -out "${filename%.txt.enc}.txt" -pbkdf2 -pass "pass:$password"

    if [ $? -ne 0 ]; then
        echo "Fail"
    else
        echo "Success"
        rm "$filename"
    fi
}

function encrypt_file_contents() {
    filename=$1
    if [ -e "$filename" ]; then
        echo "Enter password:"
        read password
        echo $(encrypt_file "$filename" "$password")
    else
        echo "File not found!"
    fi
}

function decrypt_file_contents() {
    filename=$1
    if [ -e "$filename" ]; then
        echo "Enter password:"
        read password
        echo $(decrypt_file "$filename" "$password")
    else
        echo "File not found!"
    fi
}

say_welcome
print_menu
read option
while true; do
    case $option in
        0)
            say_goodbye
            break
            ;;
        1)
            ask_for_filename
            read filename
            is_filename_valid=$(check_filename_validity "$filename")
            if [ "$is_filename_valid" -eq 1 ]; then
                ask_for_message
                read message
                is_message_valid=$(check_message_validity "$message")
                if [ "$is_message_valid" -eq 1 ]; then
                    echo "$message" > "$filename"
                    echo "The file was created successfully!"
                else
                    echo "This is not a valid message!"
                fi
            else
                echo "File name can contain letters and dots only!"
            fi
            ;;
        2)
            ask_for_filename
            read filename
            if [ -e "$filename" ]; then
                echo "File content:"
                cat "$filename"
                echo ""
            else
                echo "File not found!"
            fi
            ;;
        3)
            ask_for_filename
            read filename
            encrypt_file_contents "$filename"
            ;;
        4)
            ask_for_filename
            read filename
            decrypt_file_contents "$filename"
            ;;
        *)
            say_invalid_option
            ;;
    esac
    print_menu
    read option
done