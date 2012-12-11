#!/bin/bash

# Split input data into testing set and training set
cat data.txt | python -c "import random, sys ; lines = [line.rstrip('\n') for line in sys.stdin] ; random.shuffle(lines) ; print '\n'.join(lines)" > randorder.txt
head -`wc -l data.txt | awk '{ lines=$1 } END { printf "%.0f\n", 0.8*lines }'` randorder.txt > train.txt
tail -`wc -l data.txt | awk '{ lines=$1 } END { printf "%.0f\n", lines - 0.8*lines }'` randorder.txt > test.txt

# Train model
vw --kill_cache --cache_file train.cache --data train.txt --passes 10 --final_regressor model.vw

# Test model
vw --initial_regressor model.vw --testonly --data test.txt --predictions predictions.txt

# Evaluate results
python - <<EOF
with open('data.txt', 'r') as f:
  truth = {label: (warm == '1') for (warm, weight, label) in [line.split('|', 1)[0].split(None, 3) for line in f]}

with open('predictions.txt', 'r') as f:
  predictions = {label: (float(warmth) >= 0.5) for (warmth, label) in [line.strip().split() for line in f]}

correct = 0
for (color, warm) in predictions.iteritems():
  if truth[color] == warm:
    print color + ' OK!'
    correct += 1
  else:
    print color + ' wrong!'
print str((100.0 * correct) / len(predictions)) + '% correct'
EOF