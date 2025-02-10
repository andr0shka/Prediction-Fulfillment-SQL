SELECT
  date,
  CASE
    WHEN SUM(cumulative_acc_rev_pre) = 0 THEN 0
    ELSE (SUM(cumulative_acc_rev) / SUM(cumulative_acc_rev_pre)) * 100
  END AS revenue_percentage
FROM (
  SELECT
    s.date AS date,
    SUM(SUM(p.price)) OVER (ORDER BY s.date) AS cumulative_acc_rev,
    0 AS cumulative_acc_rev_pre
  FROM
    `DA.order` o
  JOIN
    `DA.session` s ON o.ga_session_id = s.ga_session_id
  JOIN
    `DA.product` p ON o.item_id = p.item_id
  GROUP BY
    s.date


  UNION ALL


  SELECT
    rp.date AS date,
    0 AS cumulative_acc_rev,
    SUM(SUM(rp.predict)) OVER (ORDER BY rp.date) AS cumulative_acc_rev_pre
  FROM
    `DA.revenue_predict` rp
  GROUP BY
    rp.date
) combined
GROUP BY
  date
ORDER BY
  date;
