import logging
import json
import nltk
import joblib
import warnings
import re
warnings.filterwarnings('ignore')
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from flask import Flask, request, jsonify
from flask_cors import CORS

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Setup basic logging
logging.basicConfig(level=logging.INFO)

# Download NLTK data
nltk.download('punkt', quiet=True)
nltk.download('wordnet', quiet=True)
nltk.download('stopwords', quiet=True)

# Load Model and Sentence Transformer
def load_model_and_transformer():
    """Load the trained model and Sentence Transformer."""
    model = joblib.load("saved-model/classifier.pkl")
    transformer = joblib.load("saved-model/sentence_transformer.pkl")
    logging.info("Success Loaded")
    return model, transformer
model, sentence_transformer = load_model_and_transformer()

# Dataset
def load_json_data(file_path):
    """Load JSON data from a file."""
    with open(file_path, "r", encoding='utf-8') as file:
        return json.load(file)
    
def build_response_map(general_data, place_data):
    """Create a dictionary mapping tags to responses from JSON data."""
    tag_response_map = {}
    for data in (general_data, place_data):
        for location in data.get('locations', []):
            for intent in location.get('intents', []):
                if isinstance(intent, dict) and 'tag' in intent:
                    tag = intent['tag']
                    if isinstance(tag, list):
                        tag = '_'.join(str(t) for t in tag)
                    response = intent['responses'][0] if intent.get('responses') else "Sorry, I don’t have an answer."
                    tag_response_map[tag] = response
                else:
                    logging.warning(f"Intent in location '{location.get('name', 'Unknown')}' is missing 'tag'. Skipping.")
    return tag_response_map

general_data = load_json_data("../chatbot-dataset/chatbot-qa-general.json")
place_data = load_json_data("../chatbot-dataset/chatbot-qa-place.json")
tag_response_map = build_response_map(general_data, place_data)

def preprocess_text(text):
    """Clean and preprocess text data."""
    if not isinstance(text, str):
        return ""
    text = text.lower()
    words = nltk.word_tokenize(text)
    lemmatizer = WordNetLemmatizer()
    words = [lemmatizer.lemmatize(word) for word in words]
    stop_words = set(stopwords.words('english')) - {'about', 'me', 'what', 'where', 'when'}
    words = [word for word in words if word not in stop_words]
    return ' '.join(words).strip()

def generate_response(user_input):
    """Predict intent and return corresponding response with confidence."""
    if not model or not sentence_transformer:
        return "Model or Sentence Transformer not loaded.", 0.0
    processed_input = preprocess_text(user_input)
    input_embedding = sentence_transformer.encode([processed_input])
    predicted_tag = model.predict(input_embedding)[0]
    confidence = model.predict_proba(input_embedding)[0].max()
    response = tag_response_map.get(predicted_tag, "Sorry, I don’t understand that.")
    return response, confidence

def validate_question(question):
    """Check if a question is a non-empty string."""
    return isinstance(question, str) and question.strip()

# Process questions
def process_questions(questions):
    """Generate responses for a list of questions with confidence scores."""
    responses = []
    for question in questions:
        if not validate_question(question):
            responses.append({"question": question, "error": "Invalid or empty question"})
        else:
            response, confidence = generate_response(question)
            responses.append({"question": question, "response": response, "confidence": float(confidence)})
    return responses

@app.route("/chat", methods=["POST"])
def chat():
    # Handle chat requests for single or multiple questions
    if not model or not sentence_transformer:
        logging.error("Model or Sentence Transformer unavailable.")
        return jsonify({"error": "Model or Sentence Transformer unavailable. Check server logs."}), 500

    data = request.get_json()
    if not data:
        logging.warning("Request body missing JSON data.")
        return jsonify({"error": "🙂 Request must contain JSON data"}), 400

    if "question" in data:
        questions = [data["question"]]
    elif "questions" in data:
        questions = data["questions"]
    else:
        logging.warning("Payload missing 'question' or 'questions' key.")
        return jsonify({"error": "Payload must contain 'question' or 'questions'"}), 400

    if not isinstance(questions, list) or not questions:
        logging.warning("Questions must be a non-empty list.")
        return jsonify({"error": "Questions must be a non-empty list"}), 400

    responses = process_questions(questions)
    logging.info(f"Processed {len(responses)} questions successfully.")
    return jsonify({"responses": responses})

if __name__ == "__main__":
    app.run(debug=True, port=5000)