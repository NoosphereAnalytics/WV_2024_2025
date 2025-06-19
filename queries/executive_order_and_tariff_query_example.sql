-- An example search for executive orders.

WITH hits AS (
  SELECT e.name,
         md.date,
         md.filename,
         md.source_url,
         md.text,                    -- keep original-case text
         lower(md.text) AS ltxt      -- lowercase copy for searching
  FROM   meeting_documents md
  JOIN   entities e USING (entity_id)
  WHERE  ltxt LIKE '%executive order%'
     OR  ltxt LIKE '%tariff%'
)
SELECT name,
       date,
       filename,
       source_url,

       CASE
         WHEN instr(ltxt,'executive order') > 0 THEN
              substr(text,
                     max(1, instr(ltxt,'executive order')-100),
                     100 + length('executive order') + 100)
         ELSE
              substr(text,
                     max(1, instr(ltxt,'tariff')-100),
                     100 + length('tariff') + 100)
       END AS snippet
FROM   hits
ORDER  BY date;
