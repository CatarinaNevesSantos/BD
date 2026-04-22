
SELECT tin, COUNT(DISTINCT cat)
FROM evento_reposicao NATURAL JOIN produto
GROUP BY tin
HAVING COUNT(DISTINCT cat) >= ALL (
    SELECT COUNT(DISTINCT cat)
    FROM evento_reposicao NATURAL JOIN produto
    GROUP BY tin
);

SELECT ret.nome 
FROM (categoria_simples c JOIN responsavel_por res ON c.nome = res.nome_cat) q JOIN retalhista ret ON q.tin = ret.tin; 

SELECT ean 
FROM produto
WHERE ean NOT IN (SELECT ean FROM evento_reposicao);

SELECT DISTINCT ean
FROM evento_reposicao e
WHERE (SELECT tin FROM evento_reposicao WHERE tin != e.tin AND ean = e.ean) IS NULL;