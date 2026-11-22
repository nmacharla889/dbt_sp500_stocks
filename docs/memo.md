# Which S&P 500 sectors paid best for the risk taken? (2010–2024)

Nikhil · [github.com/nmacharla889/dbt_sp500_stocks](https://github.com/nmacharla889/dbt_sp500_stocks) · November 2026

## The question

For 11 stock market sectors, I measured the return earned for each unit of volatility (how much prices swing week to week). A higher score means more reward for the same bumpy ride. Which sectors scored best from 2010 to 2024, and did the leaders stay the same in each 5-year period (2010–14, 2015–19, 2020–24)?

## The answer

- **There is no clear winner.** The top six sectors scored between 0.91 and 0.98. A 15-year score is uncertain by about ±0.3, so these six are a near tie. Ranking them would mean reading noise.
- **One change stands out.** Consumer Defensive (groceries, household goods) fell from 1.82 in 2010–14 to 0.23 in 2020–24. The 95% range for that drop is −2.82 to −0.36, so it is very unlikely to be zero.
- **It is a strong lead, not proof.** When you test 11 sectors, one can pass by luck. A stricter check that allows for this gives −3.27 to +0.08, which just includes zero. I also chose this comparison after seeing the chart.

## Why you can trust the numbers

- 78 automated data checks run on every change, in a dbt pipeline on Databricks that GitHub runs automatically.
- I recalculated every result separately in Python. If it does not match the pipeline exactly, the run stops.
- To see how much each score could move by chance, a script rebuilt the 15 years 2,000 times from random 8-week chunks of the real data and recalculated the scores each time (a block bootstrap).
- A separate test calculates weekly returns a second way and fails if the two disagree.

## What limits it

- **Only 172 of 502 companies have prices** (45% of the index by value). The gaps are in the source file itself and are spread evenly across company sizes and sectors, so they make the results thinner but not skewed. Apple, JPMorgan and ExxonMobil are among the missing.
- **Only today's companies.** Firms that left the index since 2010 are missing, which makes returns look better than they were. The results compare sectors; they do not measure real returns.
- **Today's sector labels** are applied all the way back to 2010.
- **Small sectors:** Energy (5 stocks), Basic Materials (7) and Utilities (9) can be moved by one company.
- **Every stock counts equally,** unlike the real index, which gives big companies more weight.
- **No cash return is subtracted,** so the score is simpler than the standard Sharpe ratio.

## What I would do next

1. Download prices for all 502 companies again with yfinance.
2. Build a version weighted by company size, like the real index.
3. Subtract a cash (risk-free) rate and see if the order changes.

## What I found and fixed along the way

Three problems passed every test I had. The weekly return mixed prices adjusted for dividends and splits with unadjusted ones, so Chevron showed a 36% weekly fall when it had dropped 2.5%. One test could never fail because of how it was written. And the pipeline read its input files in a way that only worked because they already existed, so it would have broken in a fresh setup. I found all three by recalculating numbers independently and asking what would happen in a clean environment, not by trusting green tests.
