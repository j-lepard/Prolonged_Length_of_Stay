from xgboost import XGBRegressor

# Create an XGBoost regressor
xgb_regressor = XGBRegressor(tree_method='gpu_hist')

# Check if GPU support is available
print(f"Is GPU available: {xgb_regressor._is_gpu_available()}")

