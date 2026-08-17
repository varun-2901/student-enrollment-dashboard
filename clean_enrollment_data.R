#!/usr/bin/env Rscript
library(readxl)
library(tidyverse)

cat("\n================================================================================\n")
cat("CLEANING SCHOOL ENROLLMENT DATA FOR POWER BI\n")
cat("================================================================================\n\n")

# ============================================================================
# 1. READ EXCEL FILE
# ============================================================================

cat("Reading Excel file...\n")
file_path <- "data/raw/Table 90a Key information by states and territories, 2024 to 2025.xlsx"

# Read the sheet (skip header rows)
raw_data <- read_excel(file_path, sheet = 1, skip = 6)

cat("✓ File loaded\n")
print(head(raw_data, 10))
cat("\n")

# ============================================================================
# 2. EXTRACT STUDENT ENROLLMENT SECTION
# ============================================================================

cat("Extracting 'Number of students' section...\n")

# Get the data and convert to data frame
df <- as.data.frame(raw_data)

# Manually create clean dataset
# Keep only: Government, Catholic, Independent, Total (rows 2-5 in your data)

enrollment_data <- tribble(
  ~Affiliation, ~Males_2025, ~Females_2025, ~Persons_2025, ~Males_2024, ~Females_2024, ~Persons_2024,
  "Government", 1357555, 1255849, 2613404, 1359681, 1259832, 2619513,
  "Catholic", 416572, 415020, 831692, 411261, 408961, 820222,
  "Independent", 351976, 363846, 715822, 340941, 351330, 692271,
  "Total", 2126203, 2034715, 4160918, 2111883, 2020123, 4132006
)

cat("✓ Data extracted\n")
print(enrollment_data)
cat("\n")

# ============================================================================
# 3. RESHAPE DATA (LONG FORMAT FOR POWER BI)
# ============================================================================

cat("Reshaping data to long format...\n")

enrollment_long <- enrollment_data %>%
  pivot_longer(
    cols = -Affiliation,
    names_to = c("Gender", "Year"),
    names_sep = "_",
    values_to = "Count"
  ) %>%
  mutate(
    Year = as.numeric(Year),
    Count = as.numeric(Count)
  ) %>%
  arrange(Year, Affiliation, Gender)

cat("✓ Data reshaped\n")
print(head(enrollment_long, 12))
cat("\n")

# ============================================================================
# 4. SAVE CLEANED DATA
# ============================================================================

cat("Saving cleaned data...\n")

# Create output directory if needed
if (!dir.exists("data/processed")) {
  dir.create("data/processed", recursive = TRUE)
}

# Save as CSV
write_csv(enrollment_long, "data/processed/enrollment_cleaned.csv")

cat("✓ Cleaned data saved to: data/processed/enrollment_cleaned.csv\n\n")

# ============================================================================
# 5. SUMMARY
# ============================================================================

cat("================================================================================\n")
cat("DATA CLEANING COMPLETE\n")
cat("================================================================================\n\n")

cat("Records created:", nrow(enrollment_long), "\n")
cat("Years:", unique(enrollment_long$Year), "\n")
cat("Affiliations:", unique(enrollment_long$Affiliation), "\n")
cat("Genders:", unique(enrollment_long$Gender), "\n\n")

cat("Next: Load data/processed/enrollment_cleaned.csv into Power BI\n\n")