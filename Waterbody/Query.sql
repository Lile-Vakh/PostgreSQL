--Write a SQL query that lists all projects that are not funded at all or are not fully funded.
--For these projects display the following columns: projectID, projectTitle, totalCost, availableFunds, missingFunds.
SELECT p.p_id, p.p_title, p.t_cost, 
	COALESCE(SUM(f.amount), 0) AS available_funds, 
	t_cost - COALESCE(SUM(f.amount), 0) AS missing_funds
	FROM project p
	LEFT JOIN finances f
	ON p.p_id = f.p_id
	GROUP BY p.p_id
	HAVING COALESCE(SUM(f.amount), 0) < p.t_cost;
