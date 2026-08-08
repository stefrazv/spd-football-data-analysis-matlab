# Statistical Analysis and Machine Learning on Football Data (MATLAB)

[🔗 Click here to view the Visual Project Presentation (Canva)](https://canva.link/idei3y20utbc25e)

## Project Overview

This project presents a statistical analysis of professional football players' performance, covering the entire workflow from raw data preprocessing to the implementation of a machine learning model.

The project was developed as part of the Statistics and Data Processing (SPD) course, for which it received the highest grade. It aims to answer the following questions:
* Is there a statistical relationship between physical attributes, such as height, and on-field performance?
* How does athletic performance compare, in terms of distribution, to biological attributes?
* Can a machine learning algorithm predict a player's position (forward, midfielder, or defender) based solely on their statistical profile?

## Dataset & Preprocessing

The data was extracted from a public CC0 dataset sourced from Transfermarkt and involved joining two files — performance statistics and physical profiles — using an inner join. To ensure data quality and statistical relevance, the dataset was preprocessed as follows:
* **Goalkeepers excluded:** Goalkeeper metrics differ substantially from those of outfield players. Including them would distort the analysis.
* **Relevance filters:** Only players with at least 90 minutes played and a valid height between 150 and 210 cm were retained.
* **Missing value imputation:** NaN values for goals and assists were replaced with 0.
* **Sampling:** The final dataset was randomly reduced to 120,000 records for statistical robustness.

## Key Insights

### 1. Biology vs. Performance (Distribution Analysis)
* **Height (biology)** follows an approximately symmetric distribution, highly concentrated around the mean value of 180.8 cm.
* **Goals (performance)** follow a positively skewed distribution. Most players score 1–2 goals, while a small number of elite forwards pull the mean upward.

### 2. Elite Forwards as Statistical Outliers
The distribution of goals was analyzed using the boxplot method, with the upper bound defined as:

$$Upper\ Bound = Q_3 + 1.5 \times IQR$$

Central forwards produced positive outliers reaching up to 41 goals, representing exceptional goalscorers whose performance falls well outside the typical statistical range.

### 3. Height Does Not Determine Performance
Pearson correlation analysis demonstrated that height has negligible correlations with offensive performance ($r = 0.01$ with goals; $r = -0.10$ with assists).

## Applied Inferential Statistics

### Central Limit Theorem (CLT)
Empirically demonstrated using 3,000 samples of size $n = 50$. The sample means converged toward a normal distribution, supporting the use of parametric tests.

### 95% Confidence Interval
Using the Student's t-distribution, the true mean height of professional football players was estimated to lie between **178.13 cm and 182.87 cm**.

### Hypothesis Testing (Two-Tailed t-test)
The following hypotheses were tested:
* $H_0: \mu = 180\text{ cm}$
* $H_1: \mu \neq 180\text{ cm}$

The test rejected $H_0$ ($p < 0.05$). Although the difference between the observed mean (180.8 cm) and the hypothesized value (180 cm) is statistically significant, it is practically negligible on the pitch.

## Machine Learning: Model Selection & Experiments

1. **k-Nearest Neighbors (kNN, k=5) — Main Model (`01_main_analysis_knn.m`):**
   * **Predictors:** Goals, assists, yellow cards, minutes played, height.
   * **Accuracy:** **53.77%**.
2. **Naive Bayes with Feature Discretization (`02_naive_bayes_binning.m`):**
   * Features were discretized into domain-specific bins. Accuracy was lower than kNN due to the strong feature independence assumption.
3. **2D Naive Bayes Decision Boundary (`03_naive_bayes_2d_viz.m`):**
   * Only goals and assists were used to plot decision boundaries visually.

## How to Run the Code

1. Clone this repository to your local machine.
2. The preprocessed dataset (`set_date_fotbal_final.csv`) is located in the `/data` folder.
3. Open MATLAB, navigate to the `/scripts` folder, and run any of the models:
   * `01_main_analysis_knn.m` — Main script containing the full analysis and the final kNN model.
   * `02_naive_bayes_binning.m` — Alternative Naive Bayes implementation.
   * `03_naive_bayes_2d_viz.m` — Experimental 2D feature visualization.

## Project Developed By
**Paraschiv Călin-Andrei & Cloșcă Ștefan-Răzvan**
