import numpy as np
import csv
import matplotlib.pyplot as plt
from sklearn.metrics import roc_curve

pca_result = np.load("pca_result.npy")
raw_result = np.load("raw_result.npy")
sda_result = np.load("sda_result.npy")

split_rule = np.load("split_rule.npy")
class_csv = open("classification_final.csv")
target = []
reader = csv.reader(class_csv)
head = next(reader)[2:]
for line in reader:
    target.append(line[2:])
target_np = np.array(target)
now_target = (target_np[:,0].astype(int)>0).astype(int)
test_label = now_target[split_rule[6000:]]

fpr_raw, tpr_raw, _ = roc_curve(test_label,raw_result[:,1])
fpr_pca, tpr_pca, _ = roc_curve(test_label,pca_result[:,1])
fpr_sda, tpr_sda, _ = roc_curve(test_label,sda_result[:,1])

plt.figure()
plt.plot(fpr_raw, tpr_raw, label='RAW')
plt.plot(fpr_pca, tpr_pca, label='PCA')
plt.plot(fpr_sda, tpr_sda, label='SDA')
plt.plot([0, 1], [0, 1], 'k--')
plt.xlim([0.0, 1])
plt.ylim([0.0, 1.05])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ROC curve')
plt.legend(loc="lower right")
plt.show()
