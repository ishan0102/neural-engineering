# Signal Analysis in Practice (HW 1)
- visualization, filtering, classification -> take training data and visualize it, extract relevant features to increase separability, train a classifier on best features and measure against test data (confusion matrix/AUC)
- for signal processing we should use band pass filtering (select relevant frequencies) and fourier transform (explore conjunction btwn time/frequency domain)
- we care about feature extraction and the temporal nature of the data (should only use samples from a certain set of continguous days, not the future) which implies a nonstationary distribution
	- generally in ML all data is generated by a stationary source, but this is not the case for neuro
	- we cannot randomly partition our data, we need to respect this temporal nature