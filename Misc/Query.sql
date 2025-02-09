--Follow the family tree of Gentle motherline
WITH RECURSIVE motherline AS (
	SELECT horsename, mother
		FROM horse
		WHERE horsename = 'Gentle'
	UNION ALL
	SELECT h.horsename, h.mother
		FROM horse h
		INNER JOIN motherline m
		ON h.horsename = m.mother
)
	SELECT * FROM motherline;

--Follow the family tree of Gentle father and mother
WITH RECURSIVE fatherline AS (
	SELECT horsename, father AS parent
		FROM horse
		WHERE horsename = 'Gentle'
	UNION ALL
	SELECT h.horsename, h.father
		FROM horse h
		INNER JOIN fatherline f
		ON h.horsename = f.parent
), motherline AS (
	SELECT horsename, mother AS parent
		FROM horse
		WHERE horsename = 'Gentle'
	UNION ALL
	SELECT h.horsename, h.mother
		FROM horse h
		INNER JOIN motherline m
		ON h.horsename = m.parent
) 
	SELECT * FROM fatherline
	UNION ALL
	SELECT * FROM motherline;

--Write 2 queries that use this index as covering index. "Index only scan"
EXPLAIN SELECT a FROM three_cols_pk
	WHERE a BETWEEN 20 AND 30;

EXPLAIN SELECT a, c FROM three_cols_pk
	WHERE a BETWEEN 20 AND 30
	AND c > 1.3;

--Write one query that could use the index as covering index but the 
--execution does not use the index as covering index, anyway. Explain, why.
EXPLAIN SELECT a, b, c FROM three_cols_pk
	WHERE a BETWEEN 20 AND 30
	AND c > 1.3;

--Write one query that cannot use the index as covering index.
EXPLAIN SELECT a, b FROM three_cols_pk
	WHERE a BETWEEN 20 AND 30
	AND c > 1.3;



