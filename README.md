# SRWC

1. Training phase

1.1 Copy the dataset into the folder "data"
1.2 Open the folder "training"

a/ ISIC2017 dataset
- Open and Run "recurse_dwt_isic17_mela.m"
- Open and Run "recurse_dwt_isic17_malignant.m"
- Open and Run "recurse_dwt_isic17_final.m".

b/ Other datasets
- Open and Run "recurse_dwt_sub.m".
NOTE: AFTER TRAINING, YOU WILL OBTAIN THE ".MAT" FILE IN FOLDER "DATA", WHICH WILL BE USED AS THE INPUT OF THE TEST PHASE. 

2. Test phase
a/ ISIC2017 dataset
- Open and Run "main_isic17_final.m" in the main branch. 

b/ Other datasets
- Open and Run "main.m" in the main branch. 
