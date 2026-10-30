\# Data Directory



This folder stores raw, temporary and cleaned datasets used in the project.



\## raw



Contains the original source files:



\- orders\_data.csv

\- returns\_data.csv

\- people\_data.csv



Raw files are not committed to Git because they should remain unchanged and can increase repository size.



Dataset source:



https://www.kaggle.com/datasets/tahir1413/global-superstore-2016



\## interim



Contains temporary checkpoints created during data cleaning and validation.



\## processed



Contains final cleaned datasets used for SQL, Excel and Power BI analysis.



\## Important Rule



Never edit or overwrite files inside the raw folder.

