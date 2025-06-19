SELECT e.name,
       md.date,
       md.source_url,
       substr(md.text,
              instr(lower(md.text),'tariff')-50,
              70) AS context
FROM   meeting_documents md
JOIN   entities e USING (entity_id)
WHERE  lower(md.text) LIKE '%tariff%'
ORDER  BY md.date
LIMIT 10;
