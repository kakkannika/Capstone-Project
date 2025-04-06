import json
import re
import nltk
import numpy as np
import pandas as pd
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, precision_score, recall_score, f1_score
import os
import joblib

def load_dataset(json_paths):
    """Load and process JSON data from multiple files."""
    questions = []
    tags = []
    responses = []
    
    for path in json_paths:
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            for location in data['locations']:
                for intent in location['intents']:
                    if isinstance(intent, list):
                        tag = intent[0]
                        if isinstance(tag, list):
                            tag = '_'.join(str(t) for t in tag)
                        if len(intent) > 1 and isinstance(intent[1], list):
                            for question in intent[1]:
                                questions.append(question)
                                tags.append(tag)
                                response = ""
                                if len(intent) > 2 and isinstance(intent[2], list) and intent[2]:
                                    response = intent[2][0]
                                responses.append(response)
                    elif isinstance(intent, dict) and 'tag' in intent:
                        tag = intent['tag']
                        if isinstance(tag, list):
                            tag = '_'.join(str(t) for t in tag)
                        if 'questions' in intent and isinstance(intent['questions'], list):
                            for question in intent['questions']:
                                questions.append(question)
                                tags.append(tag)
                                response = ""
                                if 'responses' in intent and intent['responses']:
                                    response = intent['responses'][0]
                                responses.append(response)
    
    # Create DataFrame
    return pd.DataFrame({"question": questions, "tag": tags, "answer": responses})


def preprocess_text(text):
    """Clean and preprocess text data."""
    if not isinstance(text, str):
        return ""
        
    # Convert to lowercase
    text = text.lower()
    
    # Remove punctuation
    text = re.sub(r'[^\w\s]', '', text)
    
    # Tokenize
    words = nltk.word_tokenize(text)
    
    # Lemmatize
    lemmatizer = WordNetLemmatizer()
    words = [lemmatizer.lemmatize(word) for word in words]
    
    # Remove stopwords
    stop_words = set(stopwords.words('english'))
    words = [word for word in words if word not in stop_words]
    
    # Rejoin words
    text = ' '.join(words).strip()
    
    return text


def train_qa_model():
    # Download NLTK resources
    nltk.download('punkt')
    nltk.download('wordnet')
    nltk.download('stopwords')
    
    # Paths to JSON datasets
    json_paths = [
        "chatbot-qa-general.json",
        "chatbot-qa-place.json"
    ]
    
    print("Loading dataset...")
    df = load_dataset(json_paths)
    print(f"Loaded {len(df)} question-answer pairs")
    
    # Preprocess questions
    print("Preprocessing questions...")
    df['preprocessed_questions'] = df['question'].apply(preprocess_text)
    
    # Remove tags with too few examples
    tag_counts = df['tag'].value_counts()
    valid_tags = tag_counts[tag_counts >= 5].index
    filtered_df = df[df['tag'].isin(valid_tags)]
    
    if len(filtered_df) == 0:
        print("Warning: No valid tags with 5 or more examples. Using all data.")
        filtered_df = df
    
    print(f"Training with {len(filtered_df)} examples across {len(filtered_df['tag'].unique())} tags")
    
    # TF-IDF Vectorization / Hyper-Parameters
    print("Vectorizing text...")
    tfidf_vectorizer = TfidfVectorizer(
        ngram_range=(1, 2), # Extract text features using unigrams and bigrams to capture individual words and short phrases
        max_features=3000,   
        min_df=2,           
        stop_words='english'
    )
    X = tfidf_vectorizer.fit_transform(filtered_df['preprocessed_questions'])
    
    # Split into training and testing datasets
    print("Splitting data into train and test sets...")
    X_train, X_test, y_train, y_test = train_test_split(
        X, filtered_df['tag'], test_size=0.2, random_state=42, stratify=filtered_df['tag'])
    
    print(f"Training samples: {X_train.shape[0]}")
    print(f"Testing samples: {X_test.shape[0]}")
    
    # Training a Random Forest Classifier with improved settings
    print("Training Random Forest Model")
    model = RandomForestClassifier(
        n_estimators=200,
        max_depth=None,
        min_samples_split=2,
        random_state=42,
        class_weight='balanced'  # Handle class imbalance
    )
    model.fit(X_train, y_train)
    
    # Make predictions on the testing set
    print("Evaluating model...")
    y_pred = model.predict(X_test)
    
    # Calculate evaluation metrics
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred, average='weighted', zero_division=0)
    recall = recall_score(y_test, y_pred, average='weighted', zero_division=0)
    f1 = f1_score(y_test, y_pred, average='weighted', zero_division=0)
    
    print("\nEvaluation Metrics:")
    print(f"Accuracy:  {accuracy:.2f}")
    print(f"Precision: {precision:.2f}")
    print(f"Recall:    {recall:.2f}")
    print(f"F1-Score:  {f1:.2f}")
    
    print("\nDetailed Classification Report:")
    print(classification_report(y_test, y_pred, zero_division=0))
    
    # Save model and vectorizer
    print("Saving model and vectorizer...")
    os.makedirs("model", exist_ok=True)
    joblib.dump(model, "model/qa_model.pkl")
    joblib.dump(tfidf_vectorizer, "model/qa_vectorizer.pkl")
    
    # Also save preprocessed data features for later use
    joblib.dump({
        'X': X,
        'df': filtered_df
    }, "model/qa_features.pkl")
    
    print("Training complete. Model saved to model/qa_model.pkl")
    
    return model, tfidf_vectorizer, X, filtered_df


if __name__ == "__main__":
    train_qa_model()