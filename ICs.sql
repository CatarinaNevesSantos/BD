CREATE OR REPLACE FUNCTION verif_loop_categoria_proc()
RETURNS TRIGGER AS
$$
DECLARE atual varchar(80) := NEW.super_categoria;
BEGIN
    WHILE atual IS NOT NULL 
    LOOP
        IF atual = NEW.categoria
        THEN
            RAISE EXCEPTION 'Categoria "%" esta contida em si mesma', NEW.categoria
            USING HINT = 'Uma categoria nao pode estar contida dentro de si mesma';
        END IF;
        SELECT super_categoria INTO atual
        FROM tem_outra
        WHERE categoria = atual;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION verif_unidades_repostas_proc()
RETURNS TRIGGER AS
$$
DECLARE unidades_planograma int;
BEGIN
    SELECT unidades INTO unidades_planograma
    FROM planograma
    WHERE ean = NEW.ean AND nro = NEW.nro AND num_serie = NEW.num_serie AND fabricante = NEW.fabricante;

    IF unidades_planograma < NEW.unidades
    THEN
        RAISE EXCEPTION 'Unidades repostas (%) > Unidades planograma (%)', NEW.unidades, unidades_planograma
        USING HINT = 'Numero de unidades repostas nao pode exceder as unidades especificadas no planograma';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION verif_categoria_prateleiras_proc()
RETURNS TRIGGER AS
$$
DECLARE categoria_prateleira varchar(80);
DECLARE categorias_produto varchar(80);
BEGIN
    SELECT nome INTO categoria_prateleira
    FROM prateleira
    WHERE nro = NEW.nro AND num_serie = NEW.num_serie AND fabricante = NEW.fabricante;

    SELECT nome INTO categorias_produto
    FROM tem_categoria
    WHERE ean = NEW.ean;

    IF categoria_prateleira NOT IN (categorias_produto)
    THEN
        RAISE EXCEPTION 'Produto "%" nao compativel com prateleira % da IVM % do fabricante "%"', NEW.ean, NEW.nro, NEW.num_serie, NEW.fabricante
        USING HINT = 'Um produto so pode ser reposto numa prateleira que apresente pelo menos uma das categorias desse produto';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER verif_loop_categoria_trigger ON tem_outra;
CREATE TRIGGER verif_loop_categoria_trigger
AFTER UPDATE OR INSERT ON tem_outra
FOR EACH ROW EXECUTE PROCEDURE verif_loop_categoria_proc();

DROP TRIGGER verif_unidades_repostas_trigger ON evento_reposicao;
CREATE TRIGGER verif_unidades_repostas_trigger
AFTER INSERT ON evento_reposicao
FOR EACH ROW EXECUTE PROCEDURE verif_unidades_repostas_proc();

DROP TRIGGER verif_categoria_prateleiras_trigger ON evento_reposicao;
CREATE TRIGGER verif_categoria_prateleiras_trigger
AFTER INSERT ON evento_reposicao
FOR EACH ROW EXECUTE PROCEDURE verif_categoria_prateleiras_proc();