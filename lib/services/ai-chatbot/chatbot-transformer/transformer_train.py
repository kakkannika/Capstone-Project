import json
import nltk
import numpy as np
import pandas as pd
import os
import joblib
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, classification_report
from sentence_transformers import SentenceTransformer

def load_dataset(json_paths):
    questions, tags, responses = [], [], []
    for path in json_paths:
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            for location in data['locations']:
                for intent in location['intents']:
                    if not isinstance(intent, dict):
                        continue
                    tag = intent.get('tag') or intent.get('intent_name')
                    if isinstance(tag, list):
                        tag = '_'.join(tag)
                    if not tag or 'questions' not in intent:
                        continue
                    for question in intent['questions']:
                        questions.append(question)
                        tags.append(tag)
                        responses.append(intent['responses'][0] if 'responses' in intent else "")
    return pd.DataFrame({"question": questions, "tag": tags, "answer": responses})

def preprocess_text(text):
    lemmatizer = WordNetLemmatizer()
    stop_words = set(stopwords.words('english')) - {'what', 'where', 'when', 'about', 'me'}
    words = nltk.word_tokenize(text.lower())
    cleaned = [lemmatizer.lemmatize(w) for w in words if w.isalnum() and w not in stop_words]
    return ' '.join(cleaned)

def train_sentence_transformer_model():
    nltk.download('punkt', quiet=True)
    nltk.download('wordnet', quiet=True)
    nltk.download('stopwords', quiet=True)
    json_paths = [
        "../chatbot-dataset/chatbot-qa-general.json",
        "../chatbot-dataset/chatbot-qa-place.json"
    ]
    df = load_dataset(json_paths)
    df['preprocessed'] = df['question'].apply(preprocess_text)
    tag_counts = df['tag'].value_counts()
    valid_tags = tag_counts[tag_counts >= 5].index
    filtered_df = df[df['tag'].isin(valid_tags)]
    if filtered_df.empty:
        filtered_df = df
    print("Loading Sentence Transformer Model")
    model_name = 'all-MiniLM-L6-v2'
    sentence_transformer = SentenceTransformer(model_name)
    print("Generating Embeddings")
    embeddings = sentence_transformer.encode(filtered_df['preprocessed'].tolist(), show_progress_bar=True)

    # Split the Data into Training and Testing Sets
    X_train, X_test, y_train, y_test = train_test_split(
        embeddings, filtered_df['tag'], test_size=0.2, random_state=42, stratify=filtered_df['tag'])
    print(f"Training Logistic Regression classifier")
    classifier = LogisticRegression(max_iter=1000)
    classifier.fit(X_train, y_train)
    print("Evaluating model:")
    y_pred = classifier.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    prec = precision_score(y_test, y_pred, average='weighted', zero_division=0)
    rec = recall_score(y_test, y_pred, average='weighted', zero_division=0)
    f1 = f1_score(y_test, y_pred, average='weighted', zero_division=0)

    print(f"\nSentence-Transformer Evaluation:\nAccuracy: {acc:.2f}\nPrecision: {prec:.2f}\nRecall: {rec:.2f}\nF1-score: {f1:.2f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, zero_division=0))

    os.makedirs("saved-model", exist_ok=True)
    joblib.dump(classifier, "saved-model/classifier.pkl")
    joblib.dump(sentence_transformer, "saved-model/sentence_transformer.pkl")
    return classifier, sentence_transformer

if __name__ == "__main__":
    train_sentence_transformer_model()