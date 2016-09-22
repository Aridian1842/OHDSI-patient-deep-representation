# import package
import csv
import numpy as np
from scipy.sparse import coo_matrix

# go through three csv given csv name
def processdata (csv_name,prefix) :
    global now_feature
    global feature_index
    print ("In "+ csv_name)
    print ("loading")
    data = open(csv_name)
    reader = csv.reader(data)
    next(reader, None)
    next(reader, None)

    print ("in processing...")
    for (num,line) in enumerate(reader):
        try:
            now_person = map_person_index[line[0]]
        except:
            print("!!!!!Look Here!!!!!")
            print("Person id "+ line[0] + " is not in the classification table on line"+ str(num))
            continue
        tmp_feature = prefix + line[1]
        if tmp_feature == now_feature:
            result.append([now_person,feature_index,line[2]])
        else:
            now_feature = tmp_feature
            feature_index += 1
            writer.writerow([str(feature_index), now_feature])
            feature_list.append(now_feature)
            result.append([now_person,feature_index,line[2]])
    data.close()

# build patient map through classification
print ("loading classification csv")
classification_csv = open("D:\databasefile\Yuqi\deeplearning_0910\classification_final.csv")

print ("Using classification csv to build person_id & index map")
person_num = 0
reader = csv.reader(classification_csv)
next(reader, None)
next(reader, None)
map_person_index = dict()
for line in reader:
    map_person_index[line[0]] = person_num
    person_num += 1

print ("Prepare variables")
feature_list = []
feature_index = -1
now_feature = ""
result = []
index_feature_csv = open("index_feature_map.csv","w")
writer = csv.writer(index_feature_csv)

print ("Diagnose process")
processdata("D:\databasefile\Yuqi\deeplearning_0910\diagnose_final.csv","diag_")

print ("Drug process")
processdata("D:\databasefile\Yuqi\deeplearning_0910\drug_final.csv","drug_")

print ("Procedure process")
processdata("D:\databasefile\Yuqi\deeplearning_0910\procedure_final.csv","pro_")

# close feature writer
index_feature_csv.close()

# create sparse matrix of numpy
print ("Trans result to numpy")
result_np = np.array(result)
np.save("D:\databasefile\Yuqi\deeplearning_0910\result_sparse.npy",result_np)

# trans sparse matrix to dense matrix
print ("trans sparse to dense")
result_sparse = coo_matrix((result_np[:,2],(result_np[:,0],result_np[:,1])))
result_dense = result_sparse.toarray()

# save dense matrix with format npy
print ("saving dense matrix\n")
np.save("D:\databasefile\Yuqi\deeplearning_0910\result_dense.npy",result_dense)
