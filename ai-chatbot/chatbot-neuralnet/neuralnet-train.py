import numpy as np
import json
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
from nltk_utils import bag_of_words, tokenize, stem
from model import NeuralNet
from pathlib import Path
import sys
import warnings
warnings.filterwarnings("ignore")
from sklearn.model_selection import train_test_split
from sklearn.metrics import precision_score, recall_score, f1_score
sys.stdout.reconfigure(encoding='utf-8')

# Loading Dataset
def load_json_file(filepath):
    return json.loads(Path(filepath).read_text(encoding='utf-8'))
data1 = load_json_file('../chatbot-dataset/chatbot-qa-place.json')
data2 = load_json_file('../chatbot-dataset/chatbot-qa-general.json')
combined_locations = data1['locations'] + data2['locations']

# Dataset Preparation and Intent Extraction
all_words = []
tags = []
xy = []
skipped_intents = 0  
for location in combined_locations:
    for intent in location['intents']:
        if 'tag' not in intent:
            skipped_intents += 1
            continue
        else:
            tag = intent['tag']
        if isinstance(tag, list):
            if len(tag) > 0:
                tag = tag[0]
            else:
                skipped_intents += 1
                continue
        elif not isinstance(tag, str):
            skipped_intents += 1
            continue
        tags.append(tag)
        for question in intent['questions']:
            w = tokenize(question)
            print(f"Question: {question}, Tokenized: {w}")
            stemmed_w = [stem(word) for word in w]
            print(f"Stemmed: {stemmed_w}")
            all_words.extend(stemmed_w)
            xy.append((stemmed_w, tag))
print(len(xy), "patterns")
print(len(tags), "tags:", tags)
print(len(all_words), "unique stemmed words:", all_words)

# NLP Preprocessing Techniques
ignore_words = ['?', '.', '!']
all_words = [word for word in all_words if word not in ignore_words]
all_words = sorted(set(all_words))
tags = sorted(set(tags))

# Create Training Data
X_train = []
y_train = []
for (pattern_sentence, tag) in xy:
    bag = bag_of_words(pattern_sentence, all_words)
    print(f"Pattern: {pattern_sentence}, BoW (non-zero indices): {np.where(bag > 0)[0]}")
    X_train.append(bag)
    label = tags.index(tag)
    y_train.append(label)
X_train = np.array(X_train)
y_train = np.array(y_train)

# Hyper-Parameters
num_epochs = 1000
batch_size = 8
learning_rate = 0.001
input_size = len(X_train[0])
hidden_size = 8
output_size = len(tags)
print(input_size, output_size)

# Split the data into training and test sets (80% train, 20% test)
X_train_split, X_test, y_train_split, y_test = train_test_split(X_train, y_train, test_size=0.2, random_state=42)

# Dataset and DataLoader Creation
class ChatDataset(Dataset):
    def __init__(self, x_data, y_data):
        self.n_samples = len(x_data)
        self.x_data = x_data
        self.y_data = y_data

    def __getitem__(self, index):
        return self.x_data[index], self.y_data[index]

    def __len__(self):
        return self.n_samples

# Update instantiation with data
train_dataset = ChatDataset(X_train_split, y_train_split)
test_dataset = ChatDataset(X_test, y_test)

# Create data loaders
train_loader = DataLoader(dataset=train_dataset, batch_size=batch_size, shuffle=True, num_workers=0)
test_loader = DataLoader(dataset=test_dataset, batch_size=batch_size, shuffle=False, num_workers=0)

# Model Initialization
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = NeuralNet(input_size, hidden_size, output_size).to(device)
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)

# Train Model
for epoch in range(num_epochs):
    model.train()
    for (words, labels) in train_loader:
        words = words.to(device)
        labels = labels.to(dtype=torch.long).to(device)
        outputs = model(words)
        loss = criterion(outputs, labels)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
    
    if (epoch + 1) % 100 == 0:
        print(f'Epoch [{epoch+1}/{num_epochs}], Loss: {loss.item():.4f}')

print(f'Final Loss: {loss.item():.4f}')

# Test Model with Comprehensive Metrics
threshold = 0.75
all_preds = []
all_labels = []
all_probs = []

model.eval()
with torch.no_grad():
    for (words, labels) in test_loader:
        words = words.to(device)
        labels = labels.to(dtype=torch.long).to(device)
        outputs = model(words)
        probs = torch.softmax(outputs, dim=1)
        max_probs, predicted = torch.max(probs, dim=1)
        
        all_preds.extend(predicted.cpu().numpy())
        all_labels.extend(labels.cpu().numpy())
        all_probs.extend(max_probs.cpu().numpy())

# Calculate Metrics
correct = sum(1 for i in range(len(all_labels)) if all_probs[i] > threshold and all_preds[i] == all_labels[i])
total = len(all_labels)
accuracy = 100 * correct / total

# Thresholded predictions for precision, recall, F1-score
thresholded_preds = [p if prob > threshold else -1 for p, prob in zip(all_preds, all_probs)]
valid_indices = [i for i, p in enumerate(thresholded_preds) if p != -1]
valid_preds = [thresholded_preds[i] for i in valid_indices]
valid_labels = [all_labels[i] for i in valid_indices]

if valid_preds:
    precision = precision_score(valid_labels, valid_preds, average='weighted', zero_division=0)
    recall = recall_score(valid_labels, valid_preds, average='weighted', zero_division=0)
    f1 = f1_score(valid_labels, valid_preds, average='weighted', zero_division=0)
else:
    precision, recall, f1 = 0, 0, 0

print(f'Accuracy: {accuracy:.2f}%')
print(f'Precision: {precision:.2f}')
print(f'Recall: {recall:.2f}')
print(f'F1-Score: {f1:.2f}')

# Save Model
data = {
    "model_state": model.state_dict(),
    "input_size": input_size,
    "hidden_size": hidden_size,
    "output_size": output_size,
    "all_words": all_words,
    "tags": tags,
    "intents": combined_locations
}
FILE = "saved-model/data.pth"
torch.save(data, FILE)
print(f'Training and Evaluation Completed.')