DROP TABLE categoria CASCADE;
DROP TABLE categoria_simples CASCADE;
DROP TABLE super_categoria CASCADE;
DROP TABLE tem_outra CASCADE;
DROP TABLE produto CASCADE;
DROP TABLE tem_categoria CASCADE;
DROP TABLE ivm CASCADE;
DROP TABLE ponto_de_retalho CASCADE;
DROP TABLE instalada_em CASCADE;
DROP TABLE prateleira CASCADE;
DROP TABLE planograma CASCADE;
DROP TABLE retalhista CASCADE;
DROP TABLE responsavel_por CASCADE;
DROP TABLE evento_reposicao CASCADE;

----------------------------------------
-- Table Creation
----------------------------------------

CREATE TABLE categoria
    (nome varchar(80) not null unique,
     constraint pk_categoria primary key(nome));

CREATE TABLE categoria_simples
    (nome varchar(80) not null unique,
     constraint pk_categoria_simples primary key(nome),
     constraint fk_categoria_simples_nome foreign key(nome) references categoria(nome));

CREATE TABLE super_categoria
    (nome varchar(80) not null unique,
     constraint pk_super_categoria primary key(nome),
     constraint fk_super_categoria_nome foreign key(nome) references categoria(nome));

CREATE TABLE tem_outra
    (super_categoria varchar(80) not null,
     categoria varchar(80) not null unique,
     constraint pk_tem_outra primary key(categoria),
     constraint fk_tem_outra_super_categoria foreign key(super_categoria) references super_categoria(nome),
     constraint fk_tem_outra_categoria foreign key(categoria) references categoria(nome),
     check (super_categoria != categoria));

CREATE TABLE produto
    (ean char(13) not null unique, 
     cat varchar(80) not null,
     descr varchar(80) not null,
     constraint pk_produto primary key(ean),
     constraint fk_produto_cat foreign key(cat) references categoria(nome));

CREATE TABLE tem_categoria
    (ean char(13) not null,
     nome varchar(80) not null,
     constraint pk_tem_categoria primary key(ean, nome),
     constraint fk_tem_categoria_ean foreign key(ean) references produto(ean),
     constraint fk_tem_categoria_nome foreign key(nome) references categoria(nome));

CREATE TABLE ivm
    (num_serie varchar(13) not null,
     fabricante varchar(80) not null,
     constraint pk_ivm primary key(num_serie,fabricante));

CREATE TABLE ponto_de_retalho
    (nome varchar(80) not null unique,
     distrito varchar(80),
     concelho varchar(80),
     constraint pk_ponto_de_retalho primary key(nome));

CREATE TABLE instalada_em
    (num_serie varchar(13) not null,
     fabricante varchar(80) not null,
     local varchar(80) not null,
     constraint pk_instalada_em primary key(num_serie,fabricante),
     constraint fk_instalada_em_num_serie_fabricante foreign key(num_serie,fabricante) references ivm(num_serie,fabricante),
     constraint fk_instalada_em_local foreign key(local) references ponto_de_retalho(nome));

CREATE TABLE prateleira 
    (nro int not null,
     num_serie varchar(13) not null,
     fabricante varchar(80) not null,
     altura int not null,
     nome varchar(80) not null,
     constraint pk_prateleira primary key(nro,num_serie,fabricante),
     constraint fk_prateleira_num_serie_fabricante foreign key(num_serie,fabricante) references ivm(num_serie,fabricante),
     constraint fk_prateleira_nome foreign key(nome) references categoria(nome)); 

CREATE TABLE planograma
    (ean char(13) not null,
     nro int not null,
     num_serie varchar(13) not null,
     fabricante varchar(80) not null,
     faces int not null,
     unidades int not null,
     loc int not null,
     constraint pk_planograma primary key(ean,nro,num_serie,fabricante),
     constraint fk_planograma_ean foreign key(ean) references produto(ean),
     constraint fk_planograma_nro_num_serie_fabricante foreign key(nro,num_serie,fabricante) references prateleira(nro,num_serie,fabricante));

CREATE TABLE retalhista
    (tin varchar(13) not null unique,
     nome varchar(80) not null unique,
     constraint pk_retalhista primary key(tin));

CREATE TABLE responsavel_por
    (nome_cat varchar(80) not null,
     tin varchar(13) not null,
     num_serie varchar(13) not null,
     fabricante varchar(80) not null,
     constraint pk_responsavel_por primary key(num_serie,fabricante),
     constraint fk_responsavel_por_num_serie_fabricante foreign key(num_serie,fabricante) references ivm(num_serie,fabricante),
     constraint fk_responsavel_por_tin foreign key(tin) references retalhista(tin),
     constraint fk_responsavel_por_nome_cat foreign key(nome_cat) references categoria(nome));

CREATE TABLE evento_reposicao
    (ean char(13) not null,
     nro int not null,
     num_serie varchar(13) not null,
     fabricante varchar(80) not null,
     instante timestamp not null,
     unidades int not null,
     tin varchar(13) not null,
     constraint pk_evento_reposicao primary key(ean,nro,num_serie,fabricante,instante),
     constraint fk_evento_reposicao_ean_nro_num_serie_fabricante foreign key(ean,nro,num_serie,fabricante) references planograma(ean,nro,num_serie,fabricante),
     constraint fk_evento_resposicao_tin foreign key(tin) references retalhista(tin));

----------------------------------------
-- Populate Relations
----------------------------------------

INSERT INTO categoria VALUES ('categoria 1');
INSERT INTO categoria VALUES ('categoria 2');
INSERT INTO categoria VALUES ('categoria 3');
INSERT INTO categoria VALUES ('categoria 4');

INSERT INTO produto VALUES ('0000000000001','categoria 1','produto 1');
INSERT INTO produto VALUES ('0000000000002','categoria 2','produto 2');
INSERT INTO produto VALUES ('0000000000003','categoria 3','produto 3');
INSERT INTO produto VALUES ('0000000000004','categoria 4','produto 4');
INSERT INTO produto VALUES ('0000000000005','categoria 1','produto 5');
INSERT INTO produto VALUES ('0000000000006','categoria 2','produto 6');
INSERT INTO produto VALUES ('0000000000007','categoria 3','produto 7');
INSERT INTO produto VALUES ('0000000000008','categoria 4','produto 8');
INSERT INTO produto VALUES ('0000000000009','categoria 1','chocolate');
INSERT INTO produto VALUES ('0000000000010','categoria 2','leite');
INSERT INTO produto VALUES ('0000000000011','categoria 3','batatas');
INSERT INTO produto VALUES ('0000000000012','categoria 4','cereais');

INSERT INTO categoria_simples VALUES ('categoria 1');
INSERT INTO categoria_simples VALUES ('categoria 2');

INSERT INTO super_categoria VALUES ('categoria 3');
INSERT INTO super_categoria VALUES ('categoria 4');

INSERT INTO tem_categoria VALUES ('0000000000001','categoria 1');
INSERT INTO tem_categoria VALUES ('0000000000002','categoria 2');
INSERT INTO tem_categoria VALUES ('0000000000003','categoria 3');
INSERT INTO tem_categoria VALUES ('0000000000004','categoria 4');
INSERT INTO tem_categoria VALUES ('0000000000005','categoria 1');
INSERT INTO tem_categoria VALUES ('0000000000006','categoria 2');
INSERT INTO tem_categoria VALUES ('0000000000007','categoria 3');
INSERT INTO tem_categoria VALUES ('0000000000008','categoria 4');

INSERT INTO tem_outra VALUES('categoria 3','categoria 2');
INSERT INTO tem_outra VALUES('categoria 4','categoria 3');

INSERT INTO ivm VALUES('0000000000001','fabricante 1');
INSERT INTO ivm VALUES('0000000000002','fabricante 1');
INSERT INTO ivm VALUES('0000000000001','fabricante 2');

INSERT INTO ponto_de_retalho VALUES('ponto 1','Lisboa','concelho 1');
INSERT INTO ponto_de_retalho VALUES('ponto 2','distrito 2','concelho 2');

INSERT INTO instalada_em VALUES ('0000000000001','fabricante 1','ponto 1');
INSERT INTO instalada_em VALUES ('0000000000002','fabricante 1','ponto 2');
INSERT INTO instalada_em VALUES ('0000000000001','fabricante 2','ponto 1');

INSERT INTO prateleira VALUES (1,'0000000000001','fabricante 1',30,'categoria 1');
INSERT INTO prateleira VALUES (2,'0000000000001','fabricante 1',20,'categoria 2');
INSERT INTO prateleira VALUES (3,'0000000000001','fabricante 1',15,'categoria 4');
INSERT INTO prateleira VALUES (1,'0000000000002','fabricante 1',40,'categoria 2');
INSERT INTO prateleira VALUES (2,'0000000000002','fabricante 1',30,'categoria 3');
INSERT INTO prateleira VALUES (3,'0000000000002','fabricante 1',30,'categoria 4');
INSERT INTO prateleira VALUES (1,'0000000000001','fabricante 2',20,'categoria 1');
INSERT INTO prateleira VALUES (2,'0000000000001','fabricante 2',30,'categoria 3');
INSERT INTO prateleira VALUES (3,'0000000000001','fabricante 2',20,'categoria 1');

INSERT INTO planograma VALUES ('0000000000001',1,'0000000000001','fabricante 1',4,8,0);
INSERT INTO planograma VALUES ('0000000000002',2,'0000000000001','fabricante 1',5,9,1);
INSERT INTO planograma VALUES ('0000000000003',3,'0000000000001','fabricante 1',8,9,2);
INSERT INTO planograma VALUES ('0000000000004',1,'0000000000002','fabricante 1',4,8,0);
INSERT INTO planograma VALUES ('0000000000005',2,'0000000000002','fabricante 1',4,8,1);
INSERT INTO planograma VALUES ('0000000000006',3,'0000000000002','fabricante 1',4,8,2);
INSERT INTO planograma VALUES ('0000000000007',1,'0000000000001','fabricante 2',4,8,0);
INSERT INTO planograma VALUES ('0000000000008',2,'0000000000001','fabricante 2',4,8,1);
INSERT INTO planograma VALUES ('0000000000001',3,'0000000000001','fabricante 2',4,8,2);

INSERT INTO retalhista VALUES ('0001','Catarina');
INSERT INTO retalhista VALUES ('0002','Diogo');
INSERT INTO retalhista VALUES ('0003','Ricardo');

INSERT INTO responsavel_por VALUES ('categoria 1','0001','0000000000001','fabricante 1');
INSERT INTO responsavel_por VALUES ('categoria 4','0002','0000000000002','fabricante 1');
INSERT INTO responsavel_por VALUES ('categoria 3','0002','0000000000001','fabricante 2');

INSERT INTO evento_reposicao VALUES ('0000000000001',1,'0000000000001','fabricante 1','2020-01-04',6,'0001');
INSERT INTO evento_reposicao VALUES ('0000000000002',2,'0000000000001','fabricante 1','2021-05-23',2,'0001');
INSERT INTO evento_reposicao VALUES ('0000000000002',2,'0000000000001','fabricante 1','2021-09-12',3,'0002');