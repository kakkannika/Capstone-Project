from flask import Flask, request, jsonify
import joblib
import nltk
import re
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer

# Download necessary NLTK data (only needed once)
nltk.download('punkt')
nltk.download('wordnet')
nltk.download('stopwords')

# Load trained model and vectorizer
model = joblib.load("model/qa_model.pkl")
vectorizer = joblib.load("model/qa_vectorizer.pkl")
data = joblib.load("model/qa_features.pkl")
df = data['df']

# Preprocessing function
def preprocess_text(text):
    if not isinstance(text, str):
        return ""
    text = text.lower()
    text = re.sub(r'[^\w\s]', '', text)
    words = nltk.word_tokenize(text)
    lemmatizer = WordNetLemmatizer()
    words = [lemmatizer.lemmatize(word) for word in words]
    stop_words = set(stopwords.words('english'))
    words = [word for word in words if word not in stop_words]
    return ' '.join(words).strip()

# Flask app
app = Flask(__name__)

@app.route('/chat', methods=['POST'])
def chat():
    questions = request.json.get('questions', [])
    
    if not isinstance(questions, list) or not questions:
        return jsonify({"error": "Please provide a list of questions."}), 400

    results = []

    for question in questions:
        preprocessed = preprocess_text(question)
        vec_input = vectorizer.transform([preprocessed])
        prediction = model.predict(vec_input)[0]
        
        # Get answer associated with the tag
        answers = df[df['tag'] == prediction]['answer'].values
        answer = answers[0] if len(answers) > 0 else "Sorry, I don't have an answer for that."

        # Ordered response
        results.append({
            "question": question,
            "predicted_tag": prediction,
            "answer": answer
        })
    return jsonify(results)

if __name__ == '__main__':
    app.run(debug=True)