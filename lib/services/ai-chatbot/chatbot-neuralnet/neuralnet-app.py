from flask import Flask, request, jsonify
import torch
import torch.nn as nn
import random
import numpy as np
from nltk_utils import tokenize, bag_of_words, stem
from model import NeuralNet

# Initialize Flask App
app = Flask(__name__)

# Load Model Data
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# Load the Trained Model
data = torch.load("saved-model/data.pth")
input_size = data["input_size"]
hidden_size = data["hidden_size"]
output_size = data["output_size"]
all_words = data['all_words']
tags = data['tags']
model_state = data["model_state"]
intents = data["intents"]

# Load the Model
model = NeuralNet(input_size, hidden_size, output_size).to(device)
model.load_state_dict(model_state)
model.eval()

# Normalize Input
def normalize_input(msg):
    msg = msg.lower().strip()
    # Example Replacement for Common Mistakes
    if "hell" in msg or "hi" in msg or "hey" in msg:
        msg = "hello"
    msg = msg.replace("whether", "weather")
    msg = msg.replace("phnompenh", "phnom penh")
    msg = msg.replace("independence monument", "Independence Monument")
    msg = msg.replace("national museum", "National Museum")
    return msg

@app.route('/chat', methods=['POST'])
def chat():
    # Validate Request
    if not request.json or 'messages' not in request.json:
        return jsonify({"error": "No messages provided"}), 400
    messages = request.json['messages']
    responses = []
    for sentence in messages:
        sentence = sentence.strip()
        if not sentence:
            responses.append({
                "response": "Please provide a valid message.",
                "intent": "invalid",
                "confidence": 0.0
            })
            continue
        # Preprocess the Input
        normalized_input = normalize_input(sentence)
        tokens = tokenize(normalized_input)
        stemmed_tokens = [stem(token) for token in tokens]
        X = bag_of_words(stemmed_tokens, all_words)
        X = X.reshape(1, X.shape[0])
        X = torch.from_numpy(X).to(device, dtype=torch.float32)

        # Predict Intent
        with torch.no_grad():
            output = model(X)
            probs = torch.softmax(output, dim=1)
            _, predicted = torch.max(probs, dim=1)
            tag = tags[predicted.item()]
            prob = probs[0][predicted.item()]

        # Respond Based on the Confidence
        if prob.item() > 0.5:
            found = False
            for location in intents:
                for intent in location['intents']:
                    if 'tag' in intent and tag == intent['tag']:
                        responses.append({
                            "response": random.choice(intent['responses']),
                            "intent": tag,
                            "confidence": prob.item()
                        })
                        found = True
                        break
                if found:
                    break
            if not found:
                responses.append({
                    "response": "Sorry, I do not have details on that.",
                    "intent": tag,
                    "confidence": prob.item()
                })
        else:
            responses.append({
                "response": "Sorry, I do not understand.",
                "intent": "unknown",
                "confidence": prob.item()
            })
    return jsonify({"responses": responses})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)