# XQuery Cheat Sheet - Bank Database

## 1. Select All Accounts

``` xquery
for $a in /mysqldump/database/table_data[@name="account"]/row
return $a
```

## 2. Select Account Numbers

``` xquery
for $a in /mysqldump/database/table_data[@name="account"]/row
return $a/field[@name="account_number"]
```

## 3. Conditional Query (Balance \> 20000)

``` xquery
for $a in /mysqldump/database/table_data[@name="account"]/row
where $a/field[@name="balance"] > 20000
return $a
```

## 4. Join (Account + Branch)

``` xquery
for $a in /mysqldump/database/table_data[@name="account"]/row,
    $b in /mysqldump/database/table_data[@name="branch"]/row
where $a/field[@name="branch_name"] = $b/field[@name="branch_name"]
return
<result>
  {$a/field[@name="account_number"]}
  {$b/field[@name="branch_city"]}
</result>
```

## 5. Group By (Total Balance per Branch)

``` xquery
for $b in distinct-values(
    /mysqldump/database/table_data[@name="account"]/row/field[@name="branch_name"]
)
return
<branch>
  <name>{$b}</name>
  <total>{
    sum(
      /mysqldump/database/table_data[@name="account"]/row[
        field[@name="branch_name"] = $b
      ]/field[@name="balance"]
    )
  }</total>
</branch>
```

## 6. Order By Balance (Descending)

``` xquery
for $a in /mysqldump/database/table_data[@name="account"]/row
order by $a/field[@name="balance"] descending
return $a
```

## 7. Count Accounts

``` xquery
count(/mysqldump/database/table_data[@name="account"]/row)
```

## 8. Exists (Customers with Accounts)

``` xquery
for $c in /mysqldump/database/table_data[@name="customer"]/row
where exists(
    /mysqldump/database/table_data[@name="depositor"]/row[
        field[@name="customer_name"] = $c/field[@name="customer_name"]
    ]
)
return $c
```

## 9. Distinct Branch Names

``` xquery
distinct-values(
/mysqldump/database/table_data[@name="account"]/row/field[@name="branch_name"]
)
```

## 10. Sum of All Balances

``` xquery
sum(/mysqldump/database/table_data[@name="account"]/row/field[@name="balance"])
```
