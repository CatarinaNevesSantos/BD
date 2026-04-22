SELECT
    COALESCE(concelho, 'total') as concelho,
    dia_semana,
    SUM(unidades)
FROM vendas
WHERE ano BETWEEN 2020 AND 2021
GROUP BY ROLLUP(dia_semana, concelho)
HAVING (dia_semana IS NULL AND concelho IS NULL) OR (dia_semana IS NOT NULL AND concelho IS NOT NULL);

SELECT 
    COALESCE(concelho, 'total') as concelho,    
    cat,
    dia_semana,
    SUM(unidades)
FROM vendas
WHERE distrito = 'Lisboa'
GROUP BY ROLLUP(concelho, cat, dia_semana)
HAVING (concelho IS NULL AND cat IS NULL AND dia_semana IS NULL) OR (concelho IS NOT NULL AND cat IS NOT NULL AND dia_semana IS NOT NULL);