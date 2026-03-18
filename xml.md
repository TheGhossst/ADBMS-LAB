# XQuery Equivalent of SQL Operations

## 1. SELECT

### SELECT * FROM account
```xquery
for $a in /bank/account/row
return $a
```

### SELECT account_number FROM account
```xquery
for $a in /bank/account/row
return $a/account_number/text()
```

### SELECT * FROM account WHERE balance > 50000
```xquery
for $a in /bank/account/row
where $a/balance > 50000
return $a
```

### SELECT account_number, balance FROM account WHERE branch_name="Panaji_Main"
```xquery
for $a in /bank/account/row
where $a/branch_name = "Panaji_Main"
return
  <result>
    {$a/account_number}
    {$a/balance}
  </result>
```

### SELECT DISTINCT branch_name FROM account
```xquery
distinct-values(/bank/account/row/branch_name)
```

### SELECT COUNT(*)
```xquery
count(/bank/account/row)
```

### SELECT SUM(balance)
```xquery
sum(/bank/account/row/balance)
```

---

## 2. INSERT
```xquery
insert node
<row>
  <account_number>A2000</account_number>
  <balance>50000</balance>
  <branch_name>Panaji_Main</branch_name>
</row>
into /bank/account
```

---

## 3. UPDATE
```xquery
for $a in /bank/account/row
where $a/account_number = "A1001"
return
  replace value of node $a/balance with 99999
```

---

## 4. ALTER (Simulated)
```xquery
for $a in /bank/account/row
return
  insert node <account_type>Savings</account_type> into $a
```

---

## 5. DELETE
```xquery
for $a in /bank/account/row
where $a/account_number = "A1001"
return
  delete node $a
```

---

## 6. DROP
```xquery
delete node /bank/account
```

---

## 7. TRUNCATE
```xquery
for $r in /bank/account/row
return delete node $r
```

---

## 8. JOIN
```xquery
for $a in /bank/account/row,
    $d in /bank/depositor/row
where $a/account_number = $d/account_number
return
  <result>
    {$d/customer_name}
    {$a/account_number}
    {$a/balance}
  </result>
```

---

## 9. GROUP BY
```xquery
for $b in distinct-values(/bank/account/row/branch_name)
return
  <group>
    <branch>{$b}</branch>
    <total_balance>
      {sum(/bank/account/row[branch_name=$b]/balance)}
    </total_balance>
  </group>
```

---

## 10. ORDER BY
```xquery
for $a in /bank/account/row
order by $a/balance descending
return $a
```

---

## 11. LIMIT
```xquery
for $a at $pos in /bank/account/row
where $pos <= 5
return $a
```

---

## 12. EXISTS
```xquery
exists(/bank/account/row[balance > 90000])
```

---

## 13. LIKE
```xquery
for $c in /bank/customer/row
where contains($c/customer_name, "Riley")
return $c
```

---

## 14. IN
```xquery
for $a in /bank/account/row
where $a/branch_name = ("Panaji_Main", "Mapusa_Br")
return $a
```

---

## 15. BETWEEN
```xquery
for $a in /bank/account/row
where $a/balance >= 10000 and $a/balance <= 50000
return $a
```

---

## 16. NESTED QUERY
```xquery
for $a in /bank/account/row
where $a/branch_name =
      /bank/branch/row[assets > 5000000]/branch_name
return $a
```

---

## 17. HAVING
```xquery
for $b in distinct-values(/bank/account/row/branch_name)
let $total := sum(/bank/account/row[branch_name=$b]/balance)
where $total > 100000
return
  <branch>
    <name>{$b}</name>
    <total>{$total}</total>
  </branch>
```
