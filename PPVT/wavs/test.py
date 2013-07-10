import os
import csv


wavs = []
jpgs = []

for file in os.listdir("."):
    if file.endswith(".wav"):
        wavs.append(file)

for file in os.listdir("../jpgs"):
    if file.endswith(".jpg"):
        jpgs.append(file)
        
with open('../wordList_new.csv') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    file_contents =  [x for x in reader]
    trial_imgs = [x[0] for x in file_contents]
    trial_wavs = [x[1] for x in file_contents]
    trial_wavs += [x[2] for x in file_contents]
    
wavs = [x.split('.')[0] for x in wavs]
jpgs = [x.split('.')[0] for x in jpgs]

print "No Wave File\n\n"

for wav in sorted(list(set(trial_wavs))):
    if wav not in wavs:
        print wav
        
print "\n\nNo Img File\n\n"

for img in sorted(trial_imgs):
    if img not in jpgs:
        print img
