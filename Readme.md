#PricePDA

Hey all, this is a modified version of a product I deployed while working for a startup (published here with their permission, of course).  The concept is that there users are smaller retailers, and they can compare the prices of their products with major companies in their field.  Here are some features.

## Backgrid
This site uses Backgrid.js to display data.  Several changes were made to the design, mostly to allow for complex formatting.  Several variables have to be calculated dynamically on the front end based on what data the user wishes to display.

## Ruby XL
One of the cool things PricePda has is the abilty to download and upload data from excel files.  If you want to check out these features, sample spreadsheets with filled out data have been provided for you.

## Frontend Routing
There are two types of accounts, user and admins.  Admins have access to the ability to upload products of their choice to the site and add in prices for each company each month.  Users don't have access to these features; the site wouldn't be cery useful if anyone could just change a competitors product.  On the backbone end of the site, if we try to access any admin features it kicks us back to the homepage.