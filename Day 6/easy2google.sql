-- Problem

-- A pharmacy chain wants to analyze its financial performance by identifying losses on drugs, 
-- where each drug is produced by exactly one manufacturer. A drug is loss-making 
-- when its cost of goods sold (cogs) exceeds its total sales. For each manufacturer that has 
-- at least one loss-making drug, report the number of loss-making drugs (drug_count) and the total monetary loss (total_loss) as an absolute value.

-- Output columns: manufacturer, drug_count, total_loss
-- Sort the results by total_loss in descending order.


-- Example 1

-- Input:

-- dls_drug_loss:

-- product_id	units_sold	total_sales	cogs	manufacturer	drug
-- 156	89514	3130097	3427421.73	Biogen	Acyclovir
-- 25	222331	2753546	2974975.36	AbbVie	Lamivudine and Zidovudine
-- 50	90484	2521023.73	2742445.9	Eli Lilly	Dermasorb TA Complete Kit
-- 98	110746	813188.82	140422.87	Biogen	Medi-Chord
-- Output:

-- manufacturer	drug_count	total_loss
-- Biogen	1	297324.73
-- AbbVie	1	221429.36
-- Eli Lilly	1	221422.17


select manufacturer,count(drug) as drug_count,ROUND((cogs-total_sales),2) as total_loss
from dls_drug_loss where cogs>total_sales group by manufacturer,total_loss order by total_loss desc;