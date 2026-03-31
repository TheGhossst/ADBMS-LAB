# XML + XPath Cheatsheet (Detailed)

## 📘 1. What is XML?
- XML (eXtensible Markup Language) is used to **store and transport data**
- You define your own tags (unlike HTML)
- Focus: **data structure, not presentation**

### XML vs HTML
| Feature | HTML | XML |
|--------|------|-----|
| Purpose | Display | Data storage |
| Tags | Predefined | User-defined |
| Strictness | Lenient | Strict |

---

## 🧩 2. Basic XML Structure

```xml
<student>
    <name>Riley</name>
    <age>22</age>
</student>
```

### Rules:
- Must have **one root element**
- Tags must be **properly closed**
- Tags are **case-sensitive**
- Must be **properly nested**

---

## ⚠️ 3. Common Errors

❌ Invalid:
```xml
<student>
    <name>Riley</name>
</Student>
```

✔️ Reason:
- Case mismatch (`student` vs `Student`)

---

## 🧩 4. Elements vs Attributes

### Elements
```xml
<student>
    <name>Riley</name>
</student>
```

### Attributes
```xml
<student name="Riley"/>
```

### When to use?
| Use | Choose |
|-----|--------|
| Structured data | Elements |
| Metadata | Attributes |

---

## 🧩 5. Self-closing Tags

```xml
<book/>
```

Equivalent to:
```xml
<book></book>
```

---

## 📘 6. DTD (Document Type Definition)

Defines structure of XML

### Example:
```xml
<!DOCTYPE bookstore [
    <!ELEMENT bookstore (book+)>
    <!ELEMENT book (title, author, price, discount?)>
    <!ELEMENT title (#PCDATA)>
    <!ELEMENT author (#PCDATA)>
    <!ELEMENT price (#PCDATA)>
    <!ELEMENT discount (#PCDATA)>
]>
```

---

## 🧠 DTD Operators

| Symbol | Meaning | Example |
|--------|--------|--------|
| `?` | Optional (0 or 1) | price? |
| `+` | One or more | book+ |
| `*` | Zero or more | book* |
| `,` | Sequence | (a, b, c) |
| `|` | Choice | (a | b) |

---

## 🧠 DTD Important Notes
- Order matters in sequences
- No real data types (everything is text)
- Cannot enforce numeric constraints

---

## 📘 7. XPath Basics

XPath is used to **navigate XML documents**

Think:
- XML = Tree
- XPath = Path navigation

---

## 🧩 XPath Syntax

### Root selection
```xpath
/bookstore
```

### Select child elements
```xpath
/bookstore/book
```

### Select all descendants
```xpath
//book
```

### Select specific elements
```xpath
//title
```

---

## 🧩 Filtering (Predicates)

```xpath
/bookstore/book[price=700]
```

👉 Like SQL:
```sql
SELECT * FROM book WHERE price = 700
```

---

## 🧩 Selecting after filter

```xpath
/bookstore/book[price=700]/title
```

---

## 🧩 Indexing

```xpath
/bookstore/book[1]        # first
/bookstore/book[last()]  # last
```

⚠️ Index starts from **1 (not 0)**

---

## 🧩 Attributes in XPath

### Select attribute
```xpath
//book/@price
```

### Filter using attribute
```xpath
//book[@price=500]
```

---

## ⚠️ Boolean vs Node Results

### Node selection
```xpath
/bookstore/book[price=700]
```

### Boolean result
```xpath
price=700
```

Returns:
- true()
- false()

---

## 🧠 Mental Models

- XML = Tree structure
- XPath = Navigation path
- DTD = Structure rules (like interface)

---

## 🚀 What’s Next

- XPath → XQuery (SQL-like queries for XML)
