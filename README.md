# spd-football-data-analysis-matlab
Statistical Analysis and Machine Learning on Football Data (SPD Project)

# Football Player Analytics & Position Classification (MATLAB)

[🔗 Click here to view the Visual Project Presentation (Canva)](https://canva.link/idei3y20utbc25e)

## Project overview

This project presents a statistical analysis of professional football players' performance, covering the entire workflow from raw data preprocessing to the implementation of a machine learning model.

The project was developed as part of the Statistics and Data Processing (SPD) course, for which it received the highest grade. It aims to answer the following questions:

* Is there a statistical relationship between physical attributes, such as height, and on-field performance?
* How does athletic performance compare, in terms of distribution, to biological attributes?
* Can a machine learning algorithm predict a player's position (forward, midfielder, or defender) based solely on their statistical profile?

## Dataset & preprocessing

The data was extracted from a public CC0 dataset sourced from Transfermarkt and involved joining two files — performance statistics and physical profiles — using an inner join.

To ensure data quality and statistical relevance, the dataset was preprocessed as follows:

* **Goalkeepers excluded:** Goalkeeper metrics differ substantially from those of outfield players, particularly because goals and assists are not recorded in the same way. Including goalkeepers would therefore have distorted the analysis by artificially lowering the overall averages.
* **Relevance filters:** Only players with at least 90 minutes played and a valid height between 150 and 210 cm were retained.
* **Missing value imputation:** NaN values for goals and assists were replaced with 0, as the absence of a reported value indicates no recorded action rather than a system error.
* **Sampling:** The final dataset was randomly reduced to 120,000 records, providing a substantial sample size for statistical robustness.

## Key insights

### 1. Biology vs. performance (distribution analysis)

The contrast between the two distributions is particularly interesting:

* **Height (biology)** follows an approximately symmetric distribution, where the mean, median, and mode are relatively close. Height is highly concentrated around the mean value of 180.8 cm.
* **Goals (performance)** follow a positively skewed distribution, where the mean is greater than the median, which is greater than the mode. Exceptional scoring performance is rare and not uniformly distributed. Most players score 1–2 goals, while a small number of elite forwards pull the mean upward.

### 2. Elite forwards as statistical outliers (boxplot)

The distribution of goals was analyzed using the boxplot method, with the upper bound defined as:

**upper bound = Q3 + 1.5 × IQR**

The results show that:

* Defenders and defensive midfielders are concentrated in the 0–2 goal range.
* Central forwards produced positive outliers reaching up to 41 goals.

These outliers are not data errors. Instead, they represent exceptional goalscorers whose performance falls well outside the typical statistical range of the dataset.

### 3. Height does not determine performance (heatmap)

Pearson correlation analysis, based on a 4 × 4 correlation matrix, demonstrated that height has negligible correlations with offensive performance:

* **r = 0.01** with goals
* **r = −0.10** with assists

These results suggest that height alone is not a meaningful predictor of offensive output.

## Applied inferential statistics

### Central Limit Theorem (CLT)

The Central Limit Theorem was empirically demonstrated using 3,000 samples of size *n* = 50. Despite the positively skewed distribution of goals, the sample means converged toward a normal distribution, supporting the use of parametric statistical tests.

### 95% confidence interval

Using the Student's *t*-distribution, with unknown population variance, the true mean height of professional football players was estimated to lie between **178.13 cm and 182.87 cm**.

### Hypothesis testing (two-tailed *t*-test)

The following hypotheses were tested:

* **H₀:** μ = 180 cm
* **H₁:** μ ≠ 180 cm

The test rejected H₀ (*p* < 0.05).

An important distinction should be made between statistical and practical significance. Although the 0.8 cm difference between the observed mean height (180.8 cm) and the hypothesized value (180 cm) is statistically significant due to the very large sample size (*n* = 120,000), the difference is practically negligible on the football pitch.

## Machine learning: k-nearest neighbors (kNN)

A k-nearest neighbors (kNN) algorithm with **k = 5** was implemented to classify players into three broad positional categories: **forward, midfielder, and defender**.

The model used only numerical metrics:

* goals
* assists
* cards
* minutes played
* height

### Model configuration

* **Data split:** 70% training / 30% testing
* **Standardization:** The data was standardized (`Standardize = true`) to prevent the `minutes_played` variable, which can reach approximately 3,400, from dominating the Euclidean distance relative to smaller-scale variables such as goals, which range from 0 to 50.
* **Accuracy:** The model achieved an accuracy of **53.77%**.

### Interpretation

Although an accuracy of 53.77% may appear moderate, it substantially outperforms the approximately **33% random baseline** for a three-class classification problem.

The confusion matrix shows that the algorithm performs particularly well at identifying forwards, with an accuracy of **67.1%**, while midfielders are more frequently misclassified, with an accuracy of **35.2%**.

This can be explained by the natural overlap between positional roles. For example, an attacking midfielder may have statistical characteristics similar to those of a forward, while a defensive midfielder may resemble a defender. Therefore, the overlap between classes reflects the complexity of real-world football rather than being solely a consequence of limitations in the algorithm.

## How to run

1. Clone this repository.
2. Download the dataset from Kaggle and rename/process it according to the script, or use the `set_date_fotbal_final.csv` file if it is included.
3. Open MATLAB and run the `main.m` script (or the specified script name).

## Project developed by

**Paraschiv Călin-Andrei & Cloșcă Ștefan-Răzvan**
