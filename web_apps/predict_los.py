### STREAMLIT FILE 
import os
import functools
import streamlit as st
import pandas as pd
import numpy as np
import pickle
from sklearn.metrics import mean_squared_error, r2_score
from catboost import CatBoostRegressor
from sklearn.preprocessing import StandardScaler, FunctionTransformer,OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
import warnings

###################
# TODO: GridSearch on models
# TODO: Pickle the best model.
# TODO: return here to ensure bug-free. Re-instert the preprocessor step
# TODO: Revise UI on streamlit.

model = pickle.load(open('../artifacts/catboost_model_regression_opt.pickle','rb'))
# preprocessor = pickle.load(open('../artifacts/preprocessor.pickle','rb'))

def predict_los(uploaded_df):
    input=uploaded_df
    # processed_input=preprocessor.fit_transform(input)
    prediction = model.predict(input)
    return prediction

def main(): 
      # giving the webpage a title 
    st.title('Predict Length of Stay')
    st.markdown('Upload the csv file containing the patient information post-operative. The output will be the predicted length of say.')
       
   # Assuming there's a file uploader to get the dataframe
    uploaded_file = st.file_uploader('Upload a file', type=['csv'])
    if uploaded_file is not None:
        df = pd.read_csv(uploaded_file)
        st.write("")
        st.write("This is the file your uploaded:")
        st.write(df)
        if st.button("Predict LOS"):
            output = predict_los(df)
            # Select the desired columns to display
            # For example, selecting columns 'category_id', 'age', 'sex'
            selected_columns = df[['category_id', 'age', 'sex']]

            # Combine the selected columns with the prediction output
            # Assuming output is a series or list with the same length as the DataFrame
            result_df = selected_columns.copy()
            result_df['Predicted Length of Stay'] = output

            # Use Streamlit's functions to display the output
            st.write("Predicted Length of Stay:")
            st.write(result_df)
     
if __name__=='__main__': 
    main() 
