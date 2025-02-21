from flask import Flask, request, render_template_string, session, redirect, url_for
import os
import re
import requests

app = Flask(__name__)
app.secret_key = 'your_secret_key_here'  # Replace with a secure random key for production

WORDLIST_PATH = "wordlewords"
WORDLE_URL = "https://raw.githubusercontent.com/tabatkins/wordle-list/main/words"

# Caching word list in memory
word_list_cache = None

# HTML Templates
FORM_HTML = """
<!doctype html>
<html>
<head>
    <title>Wordle Solver</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; text-align: center; padding: 20px; }
        h1 { color: #333; }
        form { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0px 0px 10px 0px #aaa; display: inline-block; }
        input, label { display: block; margin: 10px auto; }
        input[type="submit"] { background: #28a745; color: white; padding: 10px 20px; border: none; cursor: pointer; }
        input[type="submit"]:hover { background: #218838; }
        a { display: block; margin-top: 10px; color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Wordle Solver</h1>
    <form action="{{ url_for('solve') }}" method="post">
        <label for="username">Username:</label>
        <input type="text" id="username" name="username" required>
        <h3>Enter letter ranges for each of the 5 letters:</h3>
        {% for i in range(1,6) %}
            <label for="letter{{i}}">Letter {{i}} range (e.g., a-z or a-df-z):</label>
            <input type="text" id="letter{{i}}" name="letter{{i}}" required>
        {% endfor %}
        <label for="elim_letters">Letters to eliminate (optional):</label>
        <input type="text" id="elim_letters" name="elim_letters" value="{{ session.get('elim_letters', '') }}">
        <label for="exists_letters">Letters known to exist (optional):</label>
        <input type="text" id="exists_letters" name="exists_letters">
        <input type="submit" value="Solve">
    </form>
    {% if session.get('elim_letters') %}
        <p>Eliminated Letters: {{ session.get('elim_letters') }}</p>
        <a href="{{ url_for('reset') }}">Clear Eliminated Letters</a>
    {% endif %}
</body>
</html>
"""

RESULT_HTML = """
<!doctype html>
<html>
<head>
    <title>Wordle Solver - Results</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; text-align: center; padding: 20px; }
        h1 { color: #333; }
        div { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0px 0px 10px 0px #aaa; display: inline-block; }
        ul { text-align: left; }
        a { display: block; margin-top: 10px; color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Wordle Solver - Results</h1>
    <div>
        <p><strong>Username:</strong> {{ username }}</p>
        {% if session.get('elim_letters') %}
            <p><strong>Eliminated Letters:</strong> {{ session.get('elim_letters') }}</p>
        {% endif %}
        <h3>Suggestions:</h3>
        {% if suggestions %}
            <ul>
            {% for word in suggestions %}
                <li>{{ word }}</li>
            {% endfor %}
            </ul>
        {% else %}
            <p>No words found matching your criteria.</p>
        {% endif %}
        <a href="{{ url_for('index') }}">Try again</a>
    </div>
</body>
</html>
"""

def download_dictionary():
    """Downloads the word list if not present."""
    try:
        response = requests.get(WORDLE_URL, timeout=10)
        response.raise_for_status()
        with open(WORDLIST_PATH, "w") as f:
            f.write(response.text)
        return True
    except requests.RequestException as e:
        print("Failed to download dictionary:", e)
        return False

def load_dictionary():
    """Loads the word list from file and caches it."""
    global word_list_cache
    if word_list_cache is not None:
        return word_list_cache
    if not os.path.exists(WORDLIST_PATH):
        print("Dictionary not found. Downloading...")
        if not download_dictionary():
            return []
    with open(WORDLIST_PATH, "r") as f:
        word_list_cache = [line.strip() for line in f if line.strip()]
    return word_list_cache

def build_regex(letter_ranges):
    """Creates a regex pattern based on letter constraints."""
    return re.compile("^" + "".join(f"[{rng}]" for rng in letter_ranges) + "$", re.IGNORECASE)

def filter_words(words, pattern, eliminated, exists):
    """Filters words based on regex pattern, eliminated, and existing letters in a single pass."""
    return [word for word in words if pattern.match(word) and not any(char in word for char in eliminated) and all(letter in word for letter in exists)]

@app.route("/", methods=["GET"])
def index():
    return render_template_string(FORM_HTML)

@app.route("/solve", methods=["POST"])
def solve():
    username = request.form.get("username", "").strip()
    letter_ranges = [request.form.get(f"letter{i}", "").strip() for i in range(1, 6)]
    eliminated = session.get("elim_letters", "") + request.form.get("elim_letters", "").strip().lower()
    eliminated = "".join(set(eliminated))  # Remove duplicates
    session["elim_letters"] = eliminated
    exists_letters = request.form.get("exists_letters", "").strip()

    words = load_dictionary()
    pattern = build_regex(letter_ranges)
    suggestions = filter_words(words, pattern, eliminated, exists_letters)

    return render_template_string(RESULT_HTML, username=username, suggestions=suggestions)

@app.route("/reset", methods=["GET"])
def reset():
    session.pop("elim_letters", None)
    return redirect(url_for("index"))

if __name__ == "__main__":
    load_dictionary()  # Pre-load dictionary
    app.run(host="0.0.0.0", port=5000)
