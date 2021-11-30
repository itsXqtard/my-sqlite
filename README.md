
# MySqlLite

This is a basic ruby SQLite implementation of the SQLite database library. The basic functionality includes 4 operations;
SELECT, INSERT, UPDATE and DELETE.


## Features

- Query all rows from a csv file to display or you query for a specific row with some matching criteria
- Sort by ascending or descending for select statements
- Joining two tables together using select statements
- Insert a row into a csv file
- Update all rows or a single row in a csv file
- Delete all data or a single row in csv file
- Autocomplete files like how on the command-line works.
- Up arrow to bring last query executed


## FAQ

#### How do I test the MySQLiteRequest?

There are two parts to my code. It's separated into a `evaluator` and `parser`.
The `evaluator` is where you will find the code for `MySqliteRequest` and  
`parser` you will find the code for `MySqliteCLI`

In the `MySqliteRequest` I have provided some testing code. You may use it if you like.  
Please uncomment which test you would like to test and test it individually. It is not meant to be  
tested in bulk. Once you are done testing that specific functionality comment that code back and  
uncomment the next test.

You will also notice some of the functions take in extra parameters for the test. 

For select test and update test the second parameter is to toggle whether you want to test the where clause.  
For the join test the second parameter is to toggle whether you want to test the where clause and  
then the third parameter is to toggle where you want to test the order by clause

-----

**Below is for the `MySqliteCLI`**

The following will be using the nba_player_data.csv and nba_players.csv for CLI

**NOTE: For values in an insert statement that are more than one word must be enclosed in a single quote.  
Same goes for values to the right of the assignment operator for an update statement.**

#### How to insert a new row?
-----
Syntax

`INSERT INTO table (column1, column2) VALUES (value1, value2);`

Example 

```
INSERT INTO dataset/nba_player_data.csv (name,year_start,year_end,position,height,weight,birth_date,college) 
VALUES ('First Last',2021,2011,F-C,5-02,130,'January 01, 2021','Qwasar Silicon Valley');
```

#### How to select data from csv file?
-----

Syntax

`SELECT column1, column2, ... FROM table;`
or `SELECT column1, column2, ... FROM table WHERE column1 = value1;`
 
**Example**

All Rows
```
SELECT * FROM dataset/nba_player_data.csv;
```

Specific Row
```
SELECT name, year_start FROM dataset/nba_player_data.csv WHERE name = 'First Last';
```


#### How to join two tables together?
-----

Syntax  
`SELECT columnA, ... FROM tableA JOIN tableB ON columnA=columnB;` or  

WHERE  
`SELECT columnA, ... FROM tableA JOIN tableB ON columnA=columnB WHERE columnA=value;` or  

ORDER BY [ASC or DESC]  
`SELECT columnA, ... FROM tableA JOIN tableB ON columnA=columnB WHERE columnA=value ORDER BY columnA ASC|DESC;`

**Example**
```
SELECT Player, name, year_start, college, height FROM dataset/nba_player_data.csv JOIN dataset/nba_players.csv ON college=collage;
or
SELECT Player, name, year_start, college, height FROM dataset/nba_player_data.csv JOIN dataset/nba_players.csv ON college=collage  WHERE college='Duke University';
or 
SELECT Player, name, year_start, college, height FROM dataset/nba_player_data.csv JOIN dataset/nba_players.csv ON college=collage  WHERE college='Duke University' ORDER BY height ASC;
```


#### How to update a row?
-----

Syntax

`UPDATE table SET column1 = value1, column2 = value2, ...;`

**Example**

```
UPDATE dataset/nba_player_data_lite.csv
SET name = 'Last First', year_start = 2022 WHERE name = 'First Last';
```

or

```
UPDATE dataset/nba_player_data_lite.csv
SET name = 'Last First', year_start = 2022;
```

#### How to delete from a csv file?
-----

Syntax

`DELETE table WHERE column1 = value1;`

**Example**

```
DELETE dataset/nba_player_data.csv WHERE name='Last First';
```

## Authors

- [@Quang Doan](https://git.us.qwasar.io/doan_q)


## Version History


* 0.1
    * Initial Release