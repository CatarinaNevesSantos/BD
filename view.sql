DROP VIEW vendas;
CREATE VIEW vendas AS
SELECT ean,
       cat,
       EXTRACT(YEAR FROM instante) AS ano,
       EXTRACT(QUARTER FROM instante) AS trimestre,
       EXTRACT(MONTH FROM instante) AS mes,
       EXTRACT(DAY FROM instante) AS dia_mes,
       EXTRACT(DOW FROM instante) AS dia_semana,
       distrito,
       concelho,
       unidades
FROM
    (evento_reposicao NATURAL JOIN produto NATURAL JOIN instalada_em)
    JOIN ponto_de_retalho ON local = nome;