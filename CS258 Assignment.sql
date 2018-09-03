/*The INVENTORY table tracks which products are in stock, how much they cost,
and how much of the item there is in stock. ProductID and likely ProductDesc 
will be unique for each row, but since ProductID is a foreign key in 
ORDER_PRODUCTS, we'll make ProductID our PRIMARY KEY to enable us to join these
two tables together and treat ProductDesc as a normal, attribute though it is
potentially a candidate key. We also impose a nonzero constraint on ProductID and 
ProductPrice, and set ProductStockAmount to be greater than or equal to zero to
avoid storing negative values that would not make sense.*/


CREATE TABLE INVENTORY (
ProductID integer PRIMARY KEY,
ProductDesc varchar(30),
ProductPrice numeric(8,2),
ProductStockAmount integer,
CHECK(ProductID > 0 AND ProductPrice > 0 AND ProductStockAmount >= 0));


/*The ORDER table tracks orders that have been made, the method of purchase, 
whether or not the order has been completed yet, and the date the order was 
placed. OrderID will be unique for each row and is a foreign key in 
ORDER_PRODUCTS, DELIVERIES, COLLECTIONS, and STAFF_ORDERS, so we will designate
it as our PRIMARY KEY as its a unique identifier and will allow us to join the
ORDER table with the aforementioned tables. We impose a nonzero constraint on
OrderID, and impose a constraint on OrderType that it is one of 'InStore', 
'Collection', or 'Delivery' as specified in the requirements analysis.*/


CREATE TABLE ORDERS (
OrderID integer PRIMARY KEY,
OrderType varchar(30),
OrderCompleted integer,
OrderPlaced Date,
CHECK(OrderID > 0),
CHECK(OrderType = 'InStore' OR OrderType = 'Collection' OR OrderType = 'Delivery'),
CHECK(OrderCompleted = 0 or OrderCompleted = 1));


/*The ORDER_PRODUCTS tracks what is actually contained in each order, by combining
the OrderIDs with the ProductIDs and tracking the quantity of the product
purchased in each order. In this instance our PRIMARY KEY will consist of both
OrderID and ProductID, as there will be duplication of either OrderID or 
ProductID individually in the rows, but the combination of the two will give us
a unique identifying tuple. It's worth noting that OrderID and ProductID are both
FOREIGN KEYS from the ORDERS and INVENTORY tables respectively. We impose a 
nonzero constraint on all of the attributes in the table; OrderId, ProductID, 
and ProductQuantity.*/


CREATE TABLE ORDER_PRODUCTS (
OrderID integer,
ProductID integer,
ProductQuantity integer,
CHECK(OrderID > 0 AND ProductID > 0 AND ProductQuantity > 0),
PRIMARY KEY(OrderID,ProductID),
FOREIGN KEY(OrderID) REFERENCES ORDERS(OrderID)
ON DELETE CASCADE,
FOREIGN KEY(ProductID) REFERENCES INVENTORY(ProductID)
ON DELETE CASCADE);


/*The DELIVERIES table tracks all orders made that are deliveries, and alongside
storing the OrderID and DeliveryDate, it contains identifying information about
the customer who has placed the order (their name and address). Our PRIMARY KEY
will be OrderID as it will be a unique identifier unlike the other attributes
(it is very likely the same customer will make multiple orders over a given
timeframe, and there will be more than one delivery per day). It is also a 
FOREIGN KEY for the ORDERS table. We impose a nonzero constraint on OrderID.*/


CREATE TABLE DELIVERIES (
OrderID integer PRIMARY KEY,
FName varchar(30),
LName varchar(30),
House varchar(30),
Street varchar(30),
City varchar(30),
DeliveryDate Date,
CHECK(OrderID > 0),
FOREIGN KEY(OrderID) REFERENCES ORDERS(OrderID)
ON DELETE CASCADE);


/*The COLLECTIONS table tracks all orders made that are collections, and alongside
storing the OrderID and CollectionDate, it contains identifying information 
about the customer who has placed the order (their first and last name). Our
PRIMARY KEY will be OrderID as it will be a unique identifier unlike the other 
attributes (it is very likely the same customer will make multiple orders over a 
given timeframe, and there will be more than one collection per day). It is also
a FOREIGN KEY for the ORDERS table. We impose a nonzero constraint on OrderID.*/


CREATE TABLE COLLECTIONS (
OrderID integer PRIMARY KEY,
FName varchar(30),
LName varchar(30),
CollectionDate Date,
CHECK(OrderID > 0),
FOREIGN KEY(OrderID) REFERENCES ORDERS(OrderID)
ON DELETE CASCADE);


/*The STAFF table tracks all members of staff by storing their StaffID, first name,
and last name. Our PRIMARY KEY will be StaffID as it will be a unique identifier,
unlike FName and LName where there could be duplicate rows (staff members with
the same first or last name). We impose a nonzero constraint on StaffID.*/


CREATE TABLE STAFF (
StaffID integer PRIMARY KEY,
FName varchar(30),
LName varchar(30),
CHECK(StaffID > 0));


/*The STAFF_ORDERS table tracks which orders can be attributed to which members of
staff, which is helpful for understanding staff sales performance. Our PRIMARY
KEY will be OrderID since it will be a unique identifier, as each order can only
be associated with one member of staff (as laid out in the requirements 
analysis). If multiple staff members could be responsible for a single order
(which is likely in the real world, as one member of staff could show a customer
where an item is and upsell it, and another member of staff could process
the transaction), then we would make the PRIMARY KEY a combination of both
StaffID and OrderID. It's important to note that OrderID is a FOREIGN KEY for
the ORDERS table, and StaffID is a FOREIGN KEY for the STAFF table. We impose a
nonzero constraint on both OrderID and StaffID.*/


CREATE TABLE STAFF_ORDERS (
StaffID integer,
OrderID integer,
PRIMARY KEY(StaffID,OrderID),
FOREIGN KEY(OrderID) REFERENCES ORDERS(OrderID)
ON DELETE CASCADE,
FOREIGN KEY(StaffID) REFERENCES STAFF(StaffID)
ON DELETE CASCADE);

/*Creating a sequence for our OrderID column*/
CREATE SEQUENCE ORDERS_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;