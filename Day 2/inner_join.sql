--Question 1
--Find the domestic and international sales for each movie 
select m.Title,b.Domestic_sales,b.International_sales from movies m inner join Boxoffice b on m.id=b.Movie_id;

--o/p
-- Query Results
-- Title	Domestic_sales	International_sales
-- Finding Nemo	380843261	555900000
-- Monsters University	268492764	475066843
-- Ratatouille	206445654	417277164
-- Cars 2	191452396	368400000
-- Toy Story 2	245852179	239163000
-- The Incredibles	261441092	370001000
-- WALL-E	223808164	297503696
-- Toy Story 3	415004880	648167031
-- Toy Story	191796233	170162503
-- Cars	244082982	217900167
-- Up	293004164	438338580
-- Monsters, Inc.	289916256	272900000
-- A Bug's Life	162798565	200600000
-- Brave	237283207	301700000


--question 2 Show the sales numbers for each movie that did better internationally rather than domestically 
select m.Title,b.International_sales,b.Domestic_sales from movies m inner join Boxoffice b on m.id=b.Movie_id where b.International_sales > b.Domestic_sales;

--o/p
-- Title	International_sales	Domestic_sales
-- Finding Nemo	555900000	380843261
-- Monsters University	475066843	268492764
-- Ratatouille	417277164	206445654
-- Cars 2	368400000	191452396
-- The Incredibles	370001000	261441092
-- WALL-E	297503696	223808164
-- Toy Story 3	648167031	415004880
-- Up	438338580	293004164
-- A Bug's Life	200600000	162798565
-- Brave	301700000	237283207


--question 3 List all the movies by their ratings in descending order
select m.Title,b.rating from movies m inner join Boxoffice b on m.id=b.Movie_id order by b.rating desc

--o/p
-- Title	Rating
-- WALL-E	8.5
-- Toy Story 3	8.4
-- Toy Story	8.3
-- Up	8.3
-- Finding Nemo	8.2
-- Monsters, Inc.	8.1
-- Ratatouille	8
-- The Incredibles	8
-- Toy Story 2	7.9
-- Monsters University	7.4
