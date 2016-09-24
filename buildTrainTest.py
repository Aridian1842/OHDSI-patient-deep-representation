import numpy as np
#from sklearn.neural_network import BernoulliRBM
from sklearn.decomposition import PCA
#from sklearn import preprocessing
#import Sda
import csv
from sklearn import metrics
#from sklearn.ensemble import RandomForestClassifier

# load result
print ("start loading dense matrix\n")
result = np.load("result_dense.npy")
print ("finish loading dense matrix\n")
# split rule
shuffle_split = np.array(range(len(result)))
np.random.shuffle(shuffle_split)
np.save("split_rule.npy",shuffle_split)

# split result and save
print ("start spliting result\n")
result_deep = result[shuffle_split[:5000],:]
result_train = result[shuffle_split[5000:7000],:]
result_test = result[shuffle_split[7000:],:]
result_train_test = result[shuffle_split[5000:],:]
np.save("raw_train.npy",result_train)
np.save("raw_test.npy",result_test)
print ("finish spliting result\n")

# pca
print ("start pca\n")
pca_model = PCA(n_components=500)
fit_pca = pca_model.fit(result_deep)
pca_train = fit_pca.transform(result_train)
pca_test = fit_pca.transform(result_test)
np.save("pca_train.npy",pca_train)
np.save("pca_test.npy",pca_test)
print ("finish pca\n")

# build target
#print ("start building target\n")
#class_csv = open("classification_final.csv")
#target = []
#reader = csv.reader(class_csv)
#head = next(reader)[2:]
#for line in reader:
#	target.append(line[2:])
#target_np = np.array(target)
#now_target = (target_np[:,0].astype(int)>0).astype(int)
#sda_target = now_target[shuffle_split[:5000]]
#train_target = now_target[shuffle_split[5000:7000]]
#test_target =  now_target[shuffle_split[7000:]]
#sda_target_2 = (sda_target==0).astype(int)
#sda_target = np.stack((sda_target, sda_target_2), axis=-1)
#print ("finish building target\n")

# deep learning
#print ("start sda\n")
#sda_train_test = Sda.test_Sda(result_deep,sda_target,result_train_test,result_train_test.shape[1],[5000,5000],500)
#sda_train = sda_train_test[:2000,:]
#sda_test = sda_train_test[2000:,:]
#np.save("sda_train.npy",sda_train)
#np.save("sda_test.npy",sda_test)
#print ("finish sda\n")

# classification
#print ("start random forest\n")
#print ("Disease: " + head[0])
#clf = RandomForestClassifier(n_estimators=100)
#clf.fit(raw_train,train_target)
#print("using RAW features:\n%s\n" % (metrics.classification_report(test_target,clf.predict(raw_test))))
#clf = RandomForestClassifier(n_estimators=100)
#clf.fit(sda_train,train_target)
#print("using SDA features:\n%s\n" % (metrics.classification_report(test_target,clf.predict(sda_test))))
#clf = RandomForestClassifier(n_estimators=100)
#clf.fit(pca_train,train_target)
#metrics.classification_report(test_target,clf.predict(pca_test))
#print("using PCA features:\n%s\n" % (metrics.classification_report(test_target,clf.predict(pca_test))))
#print ("finish random forest\n")
