#!/usr/bin/python3

from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request, redirect, url_for
import psycopg2
import psycopg2.extras

## SGBD configs
from config import DB_HOST, DB_DATABASE, DB_USER, DB_PASSWORD
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (DB_HOST, DB_DATABASE, DB_USER, DB_PASSWORD)

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/categorias")
def ver_categorias():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        if request.args.get('super_categoria'):
            # Query vai buscar todas as sub-categorias (diretas) da categoria que selecionamos.
            query = "SELECT\
                        categoria,\
                        CASE WHEN categoria IN (SELECT nome FROM super_categoria) THEN 'super' ELSE 'simples' END\
                        FROM tem_outra\
                        WHERE super_categoria = %s;"
            data = (request.args['super_categoria'],)
            cursor.execute(query, data)
        else:
            # Query vai buscar super categorias.
            query = "SELECT\
                        nome, \
                        CASE WHEN nome IN (SELECT nome FROM super_categoria) THEN 'super' ELSE 'simples' END\
                     FROM categoria\
                     WHERE nome NOT IN (SELECT categoria FROM tem_outra);"
            cursor.execute(query)
        return render_template("categorias.html", cursor=cursor, super_categoria=request.args.get('super_categoria'))
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/categorias/adicionar", methods = [ "POST" ])
def adicionar_categoria():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cursor.execute("INSERT INTO categoria VALUES (%s)", (request.form["nome"],))
        if request.form["tipo"] == "simples":
            cursor.execute("INSERT INTO categoria_simples VALUES (%s)", (request.form["nome"],))
        else:
            cursor.execute("INSERT INTO super_categoria VALUES (%s)", (request.form["nome"],))
        if request.form.get("super_categoria"):
            cursor.execute("INSERT INTO tem_outra VALUES (%s, %s)", (request.form["super_categoria"], request.form["nome"]))
        dbConn.commit()
        return redirect(url_for('ver_categorias'))
    except Exception as e:
        dbConn.rollback()
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/categorias/remover", methods = [ "POST" ])
def remover_categoria():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        cursor.execute("DELETE FROM tem_outra WHERE categoria = %s OR super_categoria = %s", (request.form["nome"], request.form["nome"]))
        cursor.execute("DELETE FROM tem_categoria WHERE nome = %s", (request.form["nome"],))
        cursor.execute("DELETE FROM evento_reposicao WHERE ean IN (SELECT ean FROM produto WHERE cat = %s)", (request.form["nome"],))
        cursor.execute("DELETE FROM planograma WHERE ean IN (SELECT ean FROM produto WHERE cat = %s)\
                            OR (nro, num_serie, fabricante) IN (SELECT nro, num_serie, fabricante FROM prateleira WHERE nome = %s)",\
                        (request.form["nome"], request.form["nome"]))
        cursor.execute("DELETE FROM responsavel_por WHERE nome_cat = %s", (request.form["nome"],))
        cursor.execute("DELETE FROM produto WHERE cat = %s", (request.form["nome"],))
        cursor.execute("DELETE FROM prateleira WHERE nome = %s", (request.form["nome"],))
        cursor.execute("DELETE FROM super_categoria WHERE nome = %s", (request.form["nome"],))
        cursor.execute("DELETE FROM categoria_simples WHERE nome = %s", (request.form["nome"],))
        cursor.execute("DELETE FROM categoria WHERE nome = %s", (request.form["nome"],))
        dbConn.commit()
        return redirect(url_for('ver_categorias'))
    except Exception as e:
        dbConn.rollback()
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/retalhistas")
def ver_retalhistas():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        query = "SELECT tin, nome FROM retalhista"
        cursor.execute(query)
        return render_template("retalhistas.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/retalhistas/adicionar", methods = [ "POST" ])
def adicionar_retalhista():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cursor.execute("INSERT INTO retalhista VALUES (%s, %s)", (request.form["tin"], request.form["nome"]))
        dbConn.commit()
        return redirect(url_for('ver_retalhistas'))
    except Exception as e:
        dbConn.rollback()
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/retalhistas/remover", methods = [ "POST" ])
def remover_retalhista():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cursor.execute("DELETE FROM evento_reposicao WHERE tin = %s", (request.form["tin"],))
        cursor.execute("DELETE FROM responsavel_por WHERE tin = %s", (request.form["tin"],))
        cursor.execute("DELETE FROM retalhista WHERE tin = %s", (request.form["tin"],))
        dbConn.commit()
        return redirect(url_for('ver_retalhistas'))
    except Exception as e:
        dbConn.rollback()
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/ivms")
def ver_ivms():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM ivm;"
        cursor.execute(query)
        return render_template("ivms.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/reposicoes")
def ver_reposicoes():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT ean, nro, instante, unidades, tin FROM evento_reposicao WHERE num_serie = %s AND fabricante = %s;"
        data = (request.args['num_serie'], request.args['fabricante'])
        cursor.execute(query, data)
        return render_template("reposicoes_por_ivm.html", cursor=cursor, num_serie=request.args['num_serie'], fabricante=request.args['fabricante'])
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/reposicoes/categoria")
def ver_reposicoes_por_categoria():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT cat, SUM(unidades) AS unidades FROM evento_reposicao NATURAL JOIN produto WHERE num_serie = %s AND fabricante = %s GROUP BY cat;"
        data = (request.args['num_serie'], request.args['fabricante'])
        cursor.execute(query, data)
        return render_template("reposicoes_por_ivm_por_categoria.html", cursor=cursor, num_serie=request.args['num_serie'], fabricante=request.args['fabricante'])
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

CGIHandler().run(app)