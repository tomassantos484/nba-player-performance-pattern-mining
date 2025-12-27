# Discovering Performance Patterns in NBA Player Data (1996-2022) 🏀

# Overview
This project applies association rule mining using the Apriori algorithm to NBA player performance data, uncovering frequently co-occurring statistical patterns that reflect real-world roles, tendencies, and positional responsibilities in professional basketball.

The analysis was completed as a graduate-level mini project for CUS 610 (Data Science Concepts and Methods) and focuses on interpretability over prediction, demonstrating how pattern mining techniques can extract meaningful insights from complex sports datasets.

---

## Objectives
The primary objectives of this project were to:
- Apply the Apriori algorithm to NBA player box score data
- Identify frequent itemsets and strong association rules
- Evaluate rules using support, confidence, and lift
-Interpret discovered patterns in the context of real-world NBA gameplay

---

## Dataset
- Source: [NBA Players dataset — Justinas Cirtautas (Kaggle)](https://www.kaggle.com/datasets/justinas/nba-players-data)
- Seasons Covered: 1996–97 through 2021–22
- Initial Scope: All recorded NBA players across 26 seasons

---

## Preprocessing & Filtering
To ensure meaningful and stable patterns:
- Players with fewer than 20 games played were removed to avoid small-sample noise
- Nulls, empty strings, and invalid values were removed
- After cleaning, the dataset contained ~10,679 player-season records

---

## Selected Features
The following attributes were retained due to their relevance to basketball performance and role differentiation:
- Team
- Age
- Height, Weight
- Games Played (gp)
- Points (pts), Rebounds (reb), Assists (ast)
- Net Rating
- Offensive & Defensive Rebound Percentage
- Usage Percentage
- True Shooting Percentage
- Assist Percentage

---

## Data Transformation

To enable association rule mining:
- Continuous variables were discretized into categorical bins
- Basketball-specific thresholds were used where appropriate:

  - True Shooting % > 60% → Elite

  - Usage % > 25% → High Usage

- All attributes were converted to factors

- Each player-season was treated as a transaction

- Each categorical attribute became an item

- The fully cleaned and discretized dataset is saved to:
  ```bash
  data/processed/all_seasons_cleaned.csv

---

## Methods:
- Association Rule Mining
- Apriori algorithm (arules)
- Rule Evaluation Metrics:
  - Support
  - Confidence
  - Lift

---

## Key Findings
- Rules with 100% confidence confirmed consistency between total metrics (e.g., assist percentage and total assists).
- Height and weight strongly influenced role-based tendencies:
  - Taller and heavier players consistently exhibited low assist rates.
  - Lighter players demonstrated lower rebounding rates, aligning with guard roles.

- High-lift rules highlighted distinct positional behaviors, reinforcing how physical attributes shape statistical outcomes.
- Discovered patterns closely align with historical and modern NBA gameplay, validating Apriori as a useful exploratory tool in sports analytics.
- The final set of association rules is saved to:
  ```bash
  data/processed/apriori_rules_final.csv

---

## Repository Structure
```
nba-player-performance-pattern-mining/
│
├── data/
│   ├── raw/                # Original Kaggle dataset
│   └── processed/          # Cleaned dataset and final rules
│
├── src/
│   └── apriori_analysis.R  # Fully reproducible analysis script
│
├── report/
│   └── TSY_NBA_Apriori_Report.pdf # Full report detailing all findings and the most interesting association rules
│
├── README.md
└── .gitignore
```

---

## Reproducibility
To reproduce the analysis:

1. Clone the repository
   ```bash
     git clone https://github.com/tomassantos484/nba-player-performance-pattern-mining.git

2. Open the project in RStudio or desired IDE
3. Install and load required packages
   ```bash
     source("environment/packages.R")
   
4. Run the analysis
    ```bash
    source("src/project_script.R")

---

## Tools & Technologies
- R
- RStudio
- arules, arulesViz
- dplyr


## Author
[**Tomas Santos Yciano — Connect with me on LinkedIn!**](https://www.linkedin.com/in/tjsy/)

## License
This project is released under the MIT License.
The dataset is provided by Kaggle and subject to its original licensing terms.
