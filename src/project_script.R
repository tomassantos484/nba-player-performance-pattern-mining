# --------------------------------------------
# 0) Installing and loading required packages
# --------------------------------------------

#install.packages("arules")
#install.packages("arulesViz")
#install.packages("dplyr")

library(arules)
library(arulesViz)
library(dplyr)

# -----------------------------
# 1) Load dataset
# -----------------------------

bbData <- read.csv(file = "/Users/themi/Downloads/all_seasons.csv")

# Quick sanity checks (mirrors your initial exploration)
cat("Rows:", nrow(bbData), " | Cols:", ncol(bbData), "\n\n")
print(head(bbData))
cat("\nStructure:\n")
str(bbData)
cat("\nSummary:\n")
print(summary(bbData))

# -----------------------------
# 2) Basic cleaning + renaming
# -----------------------------
bbData <- na.omit(bbData)

# Rename columns as per your workflow
bbData <- bbData %>%
  rename(team = team_abbreviation) %>%
  rename(height = player_height, weight = player_weight)

# -----------------------------
# 3) Select essential columns
# -----------------------------
# Matches the "essential columns" list in your report
essential_cols <- c(
  "team", "age", "height", "weight", "gp",
  "pts", "reb", "ast",
  "net_rating", "oreb_pct", "dreb_pct",
  "usg_pct", "ts_pct", "ast_pct"
)

missing_cols <- setdiff(essential_cols, colnames(bbData))
if (length(missing_cols) > 0) {
  stop(paste("Missing expected columns in dataset:", paste(missing_cols, collapse = ", ")))
}

bbDataImportant <- bbData[, essential_cols]

# Keep players who played at least 20 games (~1/4 season)
bbDataImportant <- subset(bbDataImportant, gp >= 20)

# Clean empty strings -> NA (defensive)
bbDataImportant[bbDataImportant == ""] <- NA
bbDataImportant <- na.omit(bbDataImportant)

cat("\nAfter cleaning + gp filter:\n")
cat("Rows:", nrow(bbDataImportant), " | Cols:", ncol(bbDataImportant), "\n")
cat("NA count:", sum(is.na(bbDataImportant)), "\n")

# -----------------------------
# 4) Discretization (binning)
# -----------------------------

# Age (17–24 young, 25–30 prime, 31–45 veteran)
bbDataImportant$age <- cut(
  bbDataImportant$age,
  breaks = c(17, 24, 30, 45),
  labels = c("Young", "Prime", "Veteran"),
  include.lowest = TRUE
)

# Height/Weight (tertiles)
bbDataImportant$height <- cut(bbDataImportant$height, breaks = 3, labels = c("Short", "Medium", "Tall"))
bbDataImportant$weight <- cut(bbDataImportant$weight, breaks = 3, labels = c("Light", "Medium", "Heavy"))

# Core box score stats (tertiles)
bbDataImportant$pts <- cut(bbDataImportant$pts, breaks = 3, labels = c("Low", "Medium", "High"))
bbDataImportant$reb <- cut(bbDataImportant$reb, breaks = 3, labels = c("Low", "Medium", "High"))
bbDataImportant$ast <- cut(bbDataImportant$ast, breaks = 3, labels = c("Low", "Medium", "High"))

# Net rating
bbDataImportant$net_rating <- cut(
  bbDataImportant$net_rating,
  breaks = c(-50, -5, 5, 50),
  labels = c("Negative", "Average", "Positive"),
  include.lowest = TRUE
)

# Offensive reb %
bbDataImportant$oreb_pct <- cut(
  bbDataImportant$oreb_pct,
  breaks = c(0, 0.05, 0.10, 0.25),
  labels = c("Low", "Medium", "High"),
  include.lowest = TRUE
)

# Defensive reb %
bbDataImportant$dreb_pct <- cut(
  bbDataImportant$dreb_pct,
  breaks = c(0, 0.10, 0.20, 0.40),
  labels = c("Low", "Medium", "High"),
  include.lowest = TRUE
)

# Usage %
bbDataImportant$usg_pct <- cut(
  bbDataImportant$usg_pct,
  breaks = c(0, 0.18, 0.25, 0.40),
  labels = c("Low", "Medium", "High"),
  include.lowest = TRUE
)

# True shooting % 
bbDataImportant$ts_pct <- cut(
  bbDataImportant$ts_pct,
  breaks = c(0, 0.52, 0.60, 0.70),
  labels = c("LowEff", "Solid", "Elite"),
  include.lowest = TRUE
)

# Assist % (playmaking rate)
bbDataImportant$ast_pct <- cut(
  bbDataImportant$ast_pct,
  breaks = c(0, 0.10, 0.25, 0.50),
  labels = c("Low", "Medium", "High"),
  include.lowest = TRUE
)

# Drop any rows that became NA from binning edge cases
bbDataImportant <- na.omit(bbDataImportant)

# Convert to factors (required for transactions cleanly)
bbDataImportant <- as.data.frame(lapply(bbDataImportant, as.factor))

# -----------------------------
# 5) Convert to transactions
# -----------------------------
transactions <- as(bbDataImportant, "transactions")
cat("\nTransactions summary:\n")
print(summary(transactions))

# -------------------------------------
# 6) Apriori runs + inspection helpers
# -------------------------------------
inspect_top_rules <- function(rules_obj, n = 10) {
  cat("\nTop rules by CONFIDENCE:\n")
  inspect(sort(rules_obj, by = "confidence")[1:n])
  
  cat("\nTop rules by LIFT:\n")
  inspect(sort(rules_obj, by = "lift")[1:n])
}

run_apriori <- function(trans, supp, conf, minlen) {
  cat("\n--------------------------------------------------\n")
  cat("Running Apriori with supp =", supp, "| conf =", conf, "| minlen =", minlen, "\n")
  rules_obj <- apriori(trans, parameter = list(supp = supp, conf = conf, minlen = minlen))
  cat("Rule summary:\n")
  print(summary(rules_obj))
  inspect_top_rules(rules_obj, n = 10)
  return(rules_obj)
}

# --------------------
# 7) Execute runs
# --------------------
# Run 1: 5% support, 60% confidence, minlen 2
rules_1 <- run_apriori(transactions, supp = 0.05, conf = 0.60, minlen = 2)

# Run 2: 10% support, 70% confidence, minlen 2
rules_2 <- run_apriori(transactions, supp = 0.10, conf = 0.70, minlen = 2)

# Run 3: 7% support, 65% confidence, minlen 3
rules_3 <- run_apriori(transactions, supp = 0.07, conf = 0.65, minlen = 3)

# Run 4: 10% support, 70% confidence, minlen 3
rules_4 <- run_apriori(transactions, supp = 0.10, conf = 0.70, minlen = 3)

# Run 5 (Final): 15% support, 80% confidence, minlen 2
rules_5 <- run_apriori(transactions, supp = 0.15, conf = 0.80, minlen = 2)

# ----------------------------------------------
# 8) Save cleaned dataset and final rules output
# ----------------------------------------------
out_dir <- file.path("data", "processed")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# Save cleaned + discretized dataset used for transactions
write.csv(
  bbDataImportant,
  file.path(out_dir, "all_seasons_cleaned.csv"),
  row.names = FALSE
)

# Save final rules output
write.csv(as
          (rules_5, "data.frame"), 
          file.path(out_dir, "apriori_rules_final.csv"),
          row.names = FALSE)
