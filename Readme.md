# Overview

Prolonged Hospital Length of Stay (PLOS) is an indicator of deteriorated efficiency in Quality of Care `1`. In addition, it has considerable implications on surgical unit operation. PLOS is a high driver for surgery cancellations. One goal of public health management is to reduce PLOS by identifying its most relevant predictors and initiating mitigations early in the care pathway. The objective of this project is to explore Machine Learning (ML) models that best predict PLOS and then deploy the model. The successful proof of concept will see a hospital operation leader upload (anonymous) information and receive a risk profile and predicted LOS for the patients on the ward.  

# Hypothesis

The post-oparative legnth of stay (LOS) and correspondingly, the risk of prolonged length of stay, can be accurately predicted at the time of admission to the recovery ward. Data points test the hypothesis include select patient demographic, surgey logistic information, and clinical information at the conclusion of the procedure.   

# Dataset

The INSPIRE dataset is a publicly available research dataset in perioperative medicine, which includes approximately 130,000 cases who underwent anesthesia for surgery at an academic institution in South Korea between 2011 and 2020. This dataset includes patient characteristics such as age, sex, physical status classification, diagnosis, surgical procedure code, department, and type of anesthesia. It also includes vital signs in the operating theatre, general wards, and intensive care units (ICUs), laboratory results from six months before admission to six months after discharge, and medication during hospitalization. `2`

# Methods
 * [ ] Database preparation
 * [ ] Exploratory Data Analysis (EDA)
 * [ ] Pre-processing
 * [ ] Models
   * [ ] Linear Regression
   * [ ] Random Forest
   * [ ] Extra Trees
   * [ ] XGBoost
   * [ ] CatBoost
 * [ ] Deployment
  
# Database preparation

The primary data set contains three main tables of interest (operation, vitals, and lab) Record counts can be seen in the below schema. Associated tables were joined to include descrptions for the the main tables to include human-readable labels. By way of example, the prodecure (surgery) names in Operations table were provided as the ICD-10 Procedure Coding Standard. 

The dataframe used for exploratory data analysis was comprised from a series of subqueries and joins between the three database tables. The following rationale and considerations were employed:

1. All surgeries must appear in the final data table. Op_id is the primary key and there are 128,000 records. This was a quality check used through out the dataframe development.  
2. Subject_ID is not unique. There is a 1-many relationship between subject and operation (a subject may have >1 surgey on the same admission)  
3. Vitals timing: vitals are taken at the time of discharge from Operating Room in ~50% of operations. If there was no exact match between vital chart_time and OR_out, then the minimum of absolute value of vitals either before or after OR_out were used.   
4. Vitals scope: the data set has over 30 vitals. However, given many of these vitals are limited in scope to the operation itself (ie. gas mix and flow rate). Furthermore, additional features have performance implications on the database. As a result, the vitals scope was reduced to approximately 15.  
5. Labs timing: timing of lab tests followed a similar approach to the vitals. It should be noted that lab results are collected with reduced frequency than vitals. A 'backstop' should be considered in the event that 'nearest' lab results are several days after the procedure. 
6. Labs scope: In the interests of maintaining performance, the lab test scope was contrained to ~15 tests. These tests are the most common and and therefore will lead to the lowest chance of null values.   

Postgres Queries:  
 Queries used in the preparation of the data can be found in the [query](_src\query) folder.
 Files include: 
 * ADD_LABS.sql - creates the 'labs_in_hospital_filter' table containing list of lab results related to subjects. 
 * ADD_VITALS.sql - creates the 'vitals_in_hospital_filter' table which contains the vitals related to each operation_id. 
 * clean_ICD_tables - used to join ICD10 descriptions to operations table. 

## Intermediate Data File Summary

> Notebook: [0.Data_import](_src\0.Data_import.ipynb)

The following csv files are generated through the data import, scoping, and feature engineering steps prior to Modelling. These maybe found in the [_data](_data) folder

|Step |File Name|Description|
|-----|--------------|--------------|
|1a.  |operations_pcd|	Raw Operations Table. Not joined to Labs or Vitals. |
|1b.  |vitals_in_hospital_filter|	Raw Vitals Table - filtered for those vitals that are clsoest to the OR END time|
|1c.  |labs_in_hospital_filter|	Raw LAbs Table - filtered for those vitals that are clsoest to the OR END time|
|2. |operations_fulldata|	Operations Table JOINED to Labs and Vitals (contains duplicates due to absence of unique key|
|3.| operations_fulldata_nodup|	Operations Table JOINED to Labs and Vitals (duplicates removed on 'op_id', 'subject_id', 'hadm_id'. Retain first occurrence|
| || |
|4a.|category_VOL|	Top X surgery categories by Volume as specificed in variable. |
|4b. |category_STD|	Top X surgery categories by Standard Deviation in LOS|
||||	
|5. |operations_inscope_CATEGORIES|	Finalized list - PRIOR to pre-proccessing and feature selection. |
|6.| **operatons_imputed_CLEAN** | File has engineered features: LOS, Prolonged LOS (y/n),OR duration, Anesthesia duration, ICU visit (y/n)|
|7.| operations_1hot_encoded | Encoded categorical features for use within PCA (feature reduction)|

</br>
</br>

  
# Exploratory Data Analysis
</br>

## Understanding the 'Surgical suite Operation'

> Notebook: [01.EDA_1_Volume](_src\01.EDA_1_Volume.ipynb)  
> Notebook: [02.EDA_2_LOS](_src\02.EDA_2_LOS.ipynb)

The objective of the first component of the project is to review the data and gain an understanding of the patient and provider flow. Given the complexity and number of clinical and non-clinical features in the dataset, a visualization dashboard was created to support analysis. The Power BI dashboard can also be used post-deployment as a potential interface for data ingestion and/or a performance dashboard. 

**Lines of inquiry:**

1. What are most common surgeries (category/specific)?
2. What is the distribution of surgery (OR) durations for each surgery category? 
3. What is the time distribution for patient populations, surgery type, etc?
4. Does a visit to the ICU seem to have any correlation to a prolonged LOS? 
5. Is there a correlation between LOS and patient age, length of time under anesthesia, or surgical duration?  
</br>

**Power BI Dashboard:**

![Power BI page 1](_images/PowerBI_page1.png)

![Power BI page 2](_images/PowerBI_page2.png)

## Understanding the Features

One of the first tasks in reviewing features is to identify features with a significant portion of null values. There are predominantly two alternatives when nulls are found: 

1) Drop the feature if the null count is 'significant'
2) Impute the missing values if the null count is 'acceptable'

The Vitals table and Lab info table contained serveal features with a large number of nulls. These are identified below and subsequently dropped from data frame. 

|Vitals Table | Lab Result Table|
|-------|----------|
|<center><img src="_images/VITALS_nulls_toDrop.png" alt="_images/VITALS_nulls_toDrop.png" style="height: auto; width:50%;"/>|<center><img src="_images/Labs_toDrop.png" alt="_images/Labs_toDrop.png" style="height: auto; width:50%;"/>|
 
</br>
</br>



# Pre-processing and Feature Engineering

> Notebook: [04.EDA_4_outliers_impute](_src\04.EDA_4_outliers_impute.ipynb)

The original data set contained de-identified timestamps at various points in their care journey. In accordance with best practice, these times were normalized against the patient's admission time to the hospital.Several features were calculated using these time stamps. 

### Operations

Time stamps were used to calculate (engineer):
* Length of Stay (discharge time - OR end time)
* Operation duration (or_end - or_start)
* Anesthesia duration (an_end - an_start)
* Flag (0/1) if subject went to ICU post op (icu_in != 0)
* Flag (0/1) if the LOS for a subject was an outlier.

### Impute Features

In working dataset, there instances (features) where there some null values that required 'filling' (imputing). Fortunately, most of these null values were clinical results (lab results or vitals), not operational measures or Length of Stay.

An effort was taken the group the subjects first by age, sex and ASA, then immpute the necessary values (average / mode). By way of example, the average white blood cell count (wbc) for 50 year old, Males, of ASA 2 wasq used to impute the missing value for sujects meeting the same grouping. This process was repeated for all other missing values.   

### Correlelation

Linear regression was initiall pusued for the modelling. Accordingly, correlation coefficients and a heatmap was created to visualize the relationship. The heatmap is presented in the PowerBI dashboard and below. 


<center><img src="_images/regression_heatmap.png" alt="_images/regression_heatmap.png" style="height: auto; width:50%;"/></center>  

## Principle Component Analysis

>Notebook: [05.PCA](_src\05.PCA.ipynb)

`NOTE: PCA was performed in the intial project iteration, but later excluded from final models`  

Following categorical encoding (one-hot), there were >160 features within the dataset. The majority of the features were a result of encoding the surgery type and the clinicial (vitals/labs)features. 

A single PCA would not be appropriate to reduce the features. Elected to group features into 4 catergories and identify optimatl principle components then most influential features within. 

Feature categories: 
* Demographic - height, weight, ASA
* Operation - logisitics of the operation iteself
* Procedure - the type of operations by PCD category (heart, ears, feet)
* Clinical - vital signs and laboratory results taken as proximal to the end of operation time stamp. 

### Initial PCA (N count): 
* demographic_columns, 'N': 2
* operation_columns, 'N': 6
* clinical_columns, 'N': 6
* procedure_columns, 'N': 6

![Alt text](_images/PCA_skree_plots.svg)


### PCA Interpretation and Impact on Feature Selection

**Hyperparameters:**
| Feature Group | N |
|---------------|---|
|demographic_columns| 2|
| operation_columns |4|
| clinical_columns| 4|
| procedure_columns| 4|


Demographics: 

> <center><img src="_images/PCA_Demo_features_selected.svg" alt="" style="height: auto; width:40%;"/>  </center>
  
Operations: 
> <center><img src="_images/PCA_ Operation_features_selected.svg" alt="" style="height: auto; width:40%;"/> </center>

Procedure:   
><center> <img src="_images/PCA_Procedure_features_selected.svg" alt="" style="height: auto; width:40%;"/> </center>


Clinicial: 
><center><img src="_images/PCA_Clinical_features_selected.svg" alt="" style="height: auto; width:40%;"/> </center>

### Impact of PCA on Feature Selection:   

The most impactful 47 features of the original, encoded data set have been identified and the four-phased Principle Component Analysis. The original data set contained 170 features. These have now been reduced to 47. 

The features selected for future analysis and inclusion in the modelling are provide below with a description: 

><center><img src="_images/PCA_FINAL_features_selected.svg" alt="" style="height:auto; width:40%;"/> </center>  

<br>
<br>
<br>

# Machine Learning Models

## Regression or Classification?

>Notebook: [06.Regression_Model](_src\06.Regression_Model_CatBoost.ipynb)  
>Notebook: [07.Category_Model](_src\07.Category_Model_CatBoost.ipynb)

Model selection, either 'regression' or 'categorization' was contemplated throughout the project. A regression problem (ie predict the length of days) would provide the most utility for a hospital manager and involved the fewest assumptions from the data scientist. Said differently, a discrete LOS prediction could be used under varying operational conditions. However, given the diversity of the dataset features it was anticpated to be 'imprecise'.  

On the alternative, a categorical classification (within window or prolonged LOS) could potentially allow for more flexibility in the model. However, such a model also depends upon hard-coded assumptions to define a prolonged LOS. The model is rendered useless if the circumstances change or the definition of 'prolonged'.

In an effort to cover address both pros/cons.... we did both! :: a regression model and a classification model.

## Training 

### Data Split

The ~100,000 records and corresponding Features (X) in the dataframe were split into a `Training` Set (80% of total). These were used to train the models.The `Validation` set was a further 20% split of Traning Set. Validation sets are user fine-tune hyperparameters, select models, and monitor training progress. Lastly the `Testing` Set consisted of 20% of total. The Testing set is used to evaluate the final model's performance on unseen data and estimate its generalization performance. Finally, in the categocial model, an additional parameter `stratify` was specified to mitigate any class imbalance between PLOS and LOS. 
><center><img src="_images/train_test_val_split.png" alt="" style="height:auto; width:40%;"/> </center>  

### Scaling / Normalization

Following the split into Train/Validaiton/Test data sets, features in the X (predictors) were scaled. The Standardscalar was used on numerical fields to ensure bias was not introduced into the training. Values in the Y data sets were not scaled. 

## Regression Models
### Baseline Evaluation

Linear Regression models used in the proejct included the following, and were initially evaluated using R-squared and RMSE (Root Mean Squared Error). 

- Linear Regression
- Random Forest
- ExtraTrees
- XGBoost
- CatBoost (meow!)

The baseline model performace was 'underwhelming'. An alternative model, CatBoost was identified and selected as it was known to accomodate categorical features well. Considering many of the features were a result of the 1-hot encoding, it gave optimism. 

|Model| R-squared |RMSE |  
|-----|-----------|-----|
|LinearRegression|-29046|9515250466|  
|RandomForest|0.49|  3.99|
|ExtraTrees|0.48|  4.03|
|XGB|0.49|4.00| 
|CatBoost|0.52|3.884|

> CatBoost :  
> CatBoost is designed specifically with a focus on categorical feature handling. It uses a specialized method for encoding categorical variables called "Ordered Target Encoding." CatBoost automatically detects and encodes categorical features without manual intervention (ie 1-hot encoding). It also includes techniques like "Ordered Boosting" and "Bayesian Regularization" to improve performance and reduce overfitting [catboost.ai](https://catboost.ai/).


### Hyperparameter Tuning

Catboost ensemble model showed the most promise and was selected for optimization and hyperparameter tuning. A Grid Search method (as opposed to Random Search) was used to tune the algorithm. 

For following grid paramaters were evaluated: 
> ![Alt text](_images/grid_params_CatBoost.png)

**Result of Grid Search yielded:**

> ![Alt text](_images/optimized/CatBoostRegressor_tuned_1category.png)

### Evaluation of Optimized Regression Model

The CatBoost regression model yieled an RMSE of 0.4375. The model's performance can be visualized in the following charts. 

>Residual Plot:  
><center><img src="_images\regression_residuals.png" alt="" style="height:auto; width:40%;"/> </center>  
  

>Regression Actual vs Predicted:   
><center><img src="_images\regression_actual_vs_pred.png" alt="" style="height:auto; width:40%;"/> </center>

>Regression Residual Histogram:   
><center><img src="_images\regression_residuals_histo.png" alt="" style="height:auto; width:40%;"/> </center>


## Categorization Models

Categorization models used in the proejct included the following, and were initially evaluated using Accuracy. 
- Logistic Regression
- Random Forest
- ExtraTrees
- XGBoost
- CatBoost (meow!)


### Baseline Evaluation

|Model|Accuracy |  
|-----|-----|
|LogisticRegression| 0.823|
|RandomForestClassifier|0.830|
|ExtraTreesClassifier|0.830|
|XGBClassifier|0.832|

### Confusion Matrix & ROC/AUC Baseline (Logistic Regression)
|Confusion Matrix | ROC|
|-----------------|-----|
|<img src="_images\logregress_confusion.png" alt="" style="height:50%; width:auto;"/> |<center><img src="_images\logregress_ROC.png" alt="" style="height:50%; width:auto;"/>|

### Hyperparameter Tuning (CatBoost)

bestTest = 0.3349154585
bestIteration = 65
Shrink model to first 66 iterations.
Accuracy base model: 0.8468930694681978  


### Evaluation of Optimized Regression Model (CatBoost)
|Confusion Matrix | ROC|
|-----------------|-----|
|<img src="_images\cat_confusion_optimize.png" alt="" style="height:50%; width:auto;"/> |<center><img src="_images\catboost_ROC_opt.png" alt="" style="height:50%; width:auto;"/>|

Summary of Models:
|Model_Name|	Sensitivity	|Specificity	|Accuracy|
|----------|--------------|-------------|--------|
|Logistic Regression|	0.649092	|0.928775|	0.82|
|CatBoostClassifier	|0.732444	|0.912169	|0.85|
|CatBoostClassifier-Optimized|	0.724130|	0.919694	|0.85|

# Deployment

>Notebook: [08.Deployment](_src\08.DeploymentTesting.ipynb)

The two CatBoost models have been prepared for deployment using Pickle. Model export, import and uploading of new data were demonstrated to successfully. Finally, an output dataframe with the model predictions is saved as .csv 

A sample output of two LOS predictions is shown below: 

|category_id	|age	|sex	|weight|	Predicted LOS (days)	|Predicted PLOS|
|-------------|------|----|------|-------------------------|-------------|
|	0GT	|90	|F	|80	|3.228563|	0
|	0GT	|60	|F	|50|	1.898183	|0

# Conclusion

The ability to predict length of stay and/or identify subjects at risk of prolonged LOS immediately following a surgical procedure has significatn operational and patient care implications. The models in this project have shown a reliable model is within the realm of "possible", but with more validation work required. 

The regression model was able to predict a LOS, but with admitedly underwhelming metrics (R2 ~0.5). The categorization model demonstrated acceptable metrics (Specificiy and Sensitivity of 0.72 and 0.91 respectively). That said, a subject with 'dummy' information that by all rational accounts should have seen an extended LOS, was not predicted as such. In that example: the patient was 95 years old, a resting hear rate of 20, in the OR for 300min, undergoing a heart-related procedure and had a visit to ICU... was not predicted to have a PLOS. Perhaps this is an example of where what makes 'sense' is proven incorrect by science.
 

# Future Considerations

* [ ] Introduce deep learning models (additional compute required)
* [ ] Create an 'intermediate' categorization - currently either LOS (very specific) and Prolonged (binary). Create bins to represent 'degree' of PLOS
* [ ] Broaden data set - currently constrained to INSPIRE. Include other data sets such as MIMIC, PMSI,HiRID,AUMC
* [ ] UI/UX, deployment, and interface with EMR considerations
